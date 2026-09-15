/// One line of a product's recipe: how much of a given ingredient
/// is consumed per single unit of this product sold.
class RecipeIngredient {
  final String ingredientId;
  final double qtyPerUnit;

  RecipeIngredient({required this.ingredientId, required this.qtyPerUnit});

  factory RecipeIngredient.fromMap(Map<String, dynamic> map) {
    return RecipeIngredient(
      ingredientId: map['ingredientId'] as String,
      qtyPerUnit: (map['qtyPerUnit'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ingredientId': ingredientId,
      'qtyPerUnit': qtyPerUnit,
    };
  }
}

class Product {
  final String productId; // Firestore doc IDs are String, not Integer as in the Data Dictionary
  final String productName;
  final double productPrice;
  final List<RecipeIngredient> recipeIngredients;

  Product({
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.recipeIngredients,
  });

  factory Product.fromMap(String id, Map<String, dynamic> map) {
    final rawList = (map['recipeIngredients'] as List<dynamic>? ?? []);
    return Product(
      productId: id,
      productName: map['productName'] as String? ?? '',
      productPrice: (map['productPrice'] as num?)?.toDouble() ?? 0.0,
      recipeIngredients: rawList
          .map((e) => RecipeIngredient.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productName': productName,
      'productPrice': productPrice,
      'recipeIngredients': recipeIngredients.map((r) => r.toMap()).toList(),
    };
  }
}