import 'package:flutter/material.dart';
import '../models/ingredient.dart';

/// One row in the inventory list. Shows a warning icon if low stock,
/// or an error icon if expired.
class IngredientListTile extends StatelessWidget {
  final Ingredient ingredient;
  final bool isLowStock;
  final VoidCallback onTap;

  const IngredientListTile({
    super.key,
    required this.ingredient,
    required this.isLowStock,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(ingredient.ingredientName),
      subtitle: Text('Qty: ${ingredient.ingredientQty}'),
      trailing: isLowStock
          ? const Icon(Icons.warning, color: Colors.orange)
          : (ingredient.ingredientExpiry
              ? const Icon(Icons.error, color: Colors.red)
              : null),
      onTap: onTap,
    );
  }
}