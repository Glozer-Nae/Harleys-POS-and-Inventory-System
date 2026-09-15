import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/crud_service.dart';

class InsufficientStockException implements Exception {
  final String message;
  InsufficientStockException(this.message);
  @override
  String toString() => message;
}

/// Handles ingredient-quantity math for the "sell one or more products ->
/// deduct their recipe ingredients" scenario.
///
/// Works on an already-aggregated map of ingredientId -> total quantity
/// needed across the WHOLE sale (built by SalesController), so an
/// ingredient shared by multiple cart items is read, checked, and written
/// exactly ONCE per sale — never once per product.
class InventoryController {
  final CrudService _crud;

  /// Per Objective #7: notify when only 5 or fewer servings remain.
  static const int lowStockThreshold = 5;

  InventoryController(this._crud);

  /// Step 1 (read + validate). [neededPerIngredientId] must already be the
  /// SUM of every recipe requirement across every item in the cart. Reads
  /// each ingredient exactly once and checks there's enough stock for the
  /// combined total. Throws [InsufficientStockException] if any ingredient
  /// falls short.
  ///
  /// Firestore transactions require ALL reads to happen before ANY writes,
  /// so this must run to completion before applyDeductions() writes anything.
  Future<Map<String, DocumentSnapshot<Map<String, dynamic>>>>
      readAndValidateIngredients(
    Transaction txn,
    Map<String, double> neededPerIngredientId,
  ) async {
    final snapshots = <String, DocumentSnapshot<Map<String, dynamic>>>{};

    for (final ingredientId in neededPerIngredientId.keys) {
      final ref = _crud.collection('ingredients').doc(ingredientId);
      final snap = await txn.get(ref);

      if (!snap.exists) {
        throw InsufficientStockException(
          'Ingredient $ingredientId does not exist.',
        );
      }

      final currentQty = (snap.data()?['ingredientQty'] as num?)?.toInt() ?? 0;
      final needed = neededPerIngredientId[ingredientId]!.ceil();

      if (currentQty < needed) {
        final name = snap.data()?['ingredientName'] ?? ingredientId;
        throw InsufficientStockException(
          'Not enough $name. Have $currentQty, need $needed.',
        );
      }

      snapshots[ingredientId] = snap;
    }

    return snapshots;
  }

  /// Step 2 (write). Deducts each ingredient's TOTAL needed quantity for
  /// the whole sale exactly once, logs the movement to ingredientUsage,
  /// and returns any ingredientIds that fell to lowStockThreshold servings
  /// or below.
  ///
  /// [ratePerIngredientId] maps ingredientId -> the qtyPerUnit to use for
  /// the "servings remaining" estimate. When an ingredient is shared by
  /// multiple dishes with different recipe rates, SalesController passes
  /// in the HIGHEST rate seen in this cart, so the estimate stays
  /// conservative rather than silently under-warning.
  List<String> applyDeductions(
    Transaction txn,
    Map<String, double> neededPerIngredientId,
    Map<String, DocumentSnapshot<Map<String, dynamic>>> snapshots,
    Map<String, double> ratePerIngredientId,
  ) {
    final lowStockIngredientIds = <String>[];

    for (final ingredientId in neededPerIngredientId.keys) {
      final snap = snapshots[ingredientId]!;
      final currentQty = (snap.data()?['ingredientQty'] as num?)?.toInt() ?? 0;
      final needed = neededPerIngredientId[ingredientId]!.ceil();
      final newQty = currentQty - needed;

      // The actual inventory deduction — exactly one write per ingredient
      // per sale, regardless of how many products in the cart use it.
      txn.update(snap.reference, {'ingredientQty': newQty});

      final rate = ratePerIngredientId[ingredientId] ?? 1;
      final remainingServings = rate > 0 ? (newQty / rate).floor() : newQty;
      if (remainingServings <= lowStockThreshold) {
        lowStockIngredientIds.add(ingredientId);
      }

      // Record the movement for ingredientUsage reporting.
      final usageRef = _crud.collection('ingredientUsage').doc();
      txn.set(usageRef, {
        'ingredientId': ingredientId,
        'usageQty': needed,
        'usageDate': Timestamp.now(),
      });
    }

    return lowStockIngredientIds;
  }
}