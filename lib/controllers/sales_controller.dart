import '../services/crud_service.dart';
import '../models/product_model.dart';
import '../models/sales_transaction_model.dart';
import 'inventory_controller.dart';

class SaleResult {
  final bool success;
  final String? errorMessage;
  final List<String> lowStockIngredientIds;

  SaleResult.success(this.lowStockIngredientIds)
      : success = true,
        errorMessage = null;

  SaleResult.failure(this.errorMessage)
      : success = false,
        lowStockIngredientIds = const [];
}

class SalesController {
  final CrudService _crud;
  final InventoryController _inventory;

  SalesController(this._crud, this._inventory);

  /// Customer buys [cartItems] (product + quantity pairs). Writes the
  /// salesTransaction doc AND deducts every recipe ingredient, all inside
  /// ONE Firestore transaction.
  ///
  /// Ingredient requirements are summed ACROSS every item in the cart
  /// before any read, check, or write happens. If two products in the same
  /// order share an ingredient, that ingredient is read, validated, and
  /// deducted exactly ONCE using the combined total.
  Future<SaleResult> processSale({
    required List<MapEntry<Product, int>> cartItems,
  }) async {
    if (cartItems.isEmpty) {
      return SaleResult.failure('Cannot process an empty sale.');
    }

    try {
      final lowStock = await _crud.instance.runTransaction<List<String>>(
        (txn) async {
          // 1. Aggregate: total quantity needed per ingredientId across
          //    every line in the cart, BEFORE any read/write happens.
          final neededPerIngredientId = <String, double>{};
          final maxRatePerIngredientId = <String, double>{};

          for (final entry in cartItems) {
            final product = entry.key;
            final qty = entry.value;
            for (final recipe in product.recipeIngredients) {
              neededPerIngredientId[recipe.ingredientId] =
                  (neededPerIngredientId[recipe.ingredientId] ?? 0) +
                      recipe.qtyPerUnit * qty;

              final currentMax = maxRatePerIngredientId[recipe.ingredientId];
              if (currentMax == null || recipe.qtyPerUnit > currentMax) {
                maxRatePerIngredientId[recipe.ingredientId] = recipe.qtyPerUnit;
              }
            }
          }

          // 2. Read + validate every unique ingredient ONCE.
          final snapshots = await _inventory.readAndValidateIngredients(
            txn,
            neededPerIngredientId,
          );

          // 3. Deduct every unique ingredient ONCE.
          final lowStockIds = _inventory.applyDeductions(
            txn,
            neededPerIngredientId,
            snapshots,
            maxRatePerIngredientId,
          );

          // 4. Build and write the sale itself, in the same atomic unit.
          double totalAmount = 0;
          int totalQty = 0;
          final soldItems = <SoldItem>[];

          for (final entry in cartItems) {
            final product = entry.key;
            final qty = entry.value;
            totalAmount += product.productPrice * qty;
            totalQty += qty;
            soldItems.add(SoldItem(
              productId: product.productId,
              quantitySold: qty,
              unitPrice: product.productPrice,
            ));
          }

          final salesRef = _crud.collection('salesTransaction').doc();
          final transaction = SalesTransaction(
            salesTransId: salesRef.id,
            salesTransAmount: totalAmount,
            salesTransQty: totalQty,
            salesTransDate: DateTime.now(),
            items: soldItems,
          );
          txn.set(salesRef, transaction.toMap());

          return lowStockIds;
        },
      );

      return SaleResult.success(lowStock);
    } on InsufficientStockException catch (e) {
      return SaleResult.failure(e.message);
    } catch (e) {
      return SaleResult.failure('Sale failed: $e');
    }
  }
}