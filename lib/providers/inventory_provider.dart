import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../services/crud_service.dart';
import '../controllers/inventory_controller.dart';
import '../models/ingredient_model.dart';

class InventoryProvider extends ChangeNotifier {
  final CrudService _crud = CrudService();
  late final InventoryController controller = InventoryController(_crud);

  List<Ingredient> ingredients = [];
  List<String> lowStockIngredientIds = [];

  void listenToIngredients() {
    _crud.streamCollection('ingredients').listen((snapshot) {
      ingredients = snapshot.docs
          .map((doc) => Ingredient.fromMap(doc.id, doc.data()))
          .toList();
      notifyListeners();
    });
  }

  void flagLowStock(List<String> ingredientIds) {
    lowStockIngredientIds = ingredientIds;
    notifyListeners();
  }

  Future<void> addIngredient({required String name, required int qty}) async {
    await _crud.create('ingredients', {
      'ingredientName': name,
      'ingredientQty': qty,
      'ingredientExpiry': false,
    });
  }

  Future<void> updateIngredient(
    Ingredient ingredient, {
    required String name,
    required int qty,
  }) async {
    await _crud.update('ingredients', ingredient.ingredientId, {
      'ingredientName': name,
      'ingredientQty': qty,
    });
  }

  /// Marks an ingredient expired: zeroes its usable quantity (Objective #8
  /// — "remove them from usable inventory") and writes a matching losses
  /// doc, atomically, so a partial failure can't leave one without the other.
  Future<void> markExpired(Ingredient ingredient) async {
    final lostQty = ingredient.ingredientQty;

    await _crud.instance.runTransaction((txn) async {
      final ref = _crud.collection('ingredients').doc(ingredient.ingredientId);

      txn.update(ref, {
        'ingredientExpiry': true,
        'ingredientQty': 0,
      });

      final lossRef = _crud.collection('losses').doc();
      txn.set(lossRef, {
        'itemId': ingredient.ingredientId,
        'lossQty': lostQty,
        'lossReason': 'expired',
        'lossDate': Timestamp.now(),
      });
    });
  }
}