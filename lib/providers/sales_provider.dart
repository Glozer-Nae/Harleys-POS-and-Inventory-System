import 'package:flutter/foundation.dart';
import '../services/crud_service.dart';
import '../controllers/sales_controller.dart';
import '../models/product_model.dart';
import 'inventory_provider.dart';

class SalesProvider extends ChangeNotifier {
  final CrudService _crud = CrudService();
  final InventoryProvider inventoryProvider;

  late final SalesController _salesController = SalesController(
    _crud,
    inventoryProvider.controller,
  );

  bool isProcessing = false;
  String? lastError;

  SalesProvider({required this.inventoryProvider});

  Future<bool> checkout(List<MapEntry<Product, int>> cart) async {
    isProcessing = true;
    lastError = null;
    notifyListeners();

    final result = await _salesController.processSale(cartItems: cart);

    isProcessing = false;
    if (result.success) {
      inventoryProvider.flagLowStock(result.lowStockIngredientIds);
    } else {
      lastError = result.errorMessage;
    }
    notifyListeners();
    return result.success;
  }
}