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
}