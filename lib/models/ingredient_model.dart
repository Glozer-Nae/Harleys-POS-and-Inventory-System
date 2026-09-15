class Ingredient {
  final String ingredientId;
  final String ingredientName;
  final bool ingredientExpiry;
  final int ingredientQty;

  Ingredient({
    required this.ingredientId,
    required this.ingredientName,
    required this.ingredientExpiry,
    required this.ingredientQty,
  });

  factory Ingredient.fromMap(String id, Map<String, dynamic> map) {
    return Ingredient(
      ingredientId: id,
      ingredientName: map['ingredientName'] as String? ?? '',
      ingredientExpiry: map['ingredientExpiry'] as bool? ?? false,
      ingredientQty: (map['ingredientQty'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ingredientName': ingredientName,
      'ingredientExpiry': ingredientExpiry,
      'ingredientQty': ingredientQty,
    };
  }
}