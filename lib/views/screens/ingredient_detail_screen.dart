import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/ingredient_model.dart';
import '../../providers/inventory_provider.dart';
import 'edit_ingredient_screen.dart';

class IngredientDetailScreen extends StatelessWidget {
  final Ingredient ingredient;

  const IngredientDetailScreen({super.key, required this.ingredient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(ingredient.ingredientName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => EditIngredientScreen(ingredient: ingredient),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quantity on hand: ${ingredient.ingredientQty}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text(
              ingredient.ingredientExpiry ? 'Status: Expired' : 'Status: Usable',
              style: TextStyle(
                fontSize: 16,
                color: ingredient.ingredientExpiry ? Colors.red : Colors.green,
              ),
            ),
            const SizedBox(height: 24),
            if (!ingredient.ingredientExpiry)
              ElevatedButton(
                onPressed: () => _markExpired(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Mark as Expired'),
              )
            else
              const Text(
                'Full loss recording (deduct + log to losses) is Phase 6 — not built yet.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _markExpired(BuildContext context) async {
    // Flowchart: Is Product expired? -> Yes -> Create Report (Phase 7,
    // not built yet — currently just flags the ingredient).
    await context.read<InventoryProvider>().markExpired(ingredient);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Marked as expired.')),
      );
      Navigator.of(context).pop();
    }
  }
}