import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/inventory_provider.dart';
import '../widgets/low_stock_banner.dart';
import '../widgets/ingredient_list_tile.dart';
import 'add_ingredient_screen.dart';
import 'ingredient_detail_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<InventoryProvider>().listenToIngredients();
  }

  @override
  Widget build(BuildContext context) {
    final inventory = context.watch<InventoryProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Inventory')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddIngredientScreen()),
        ),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          LowStockBanner(count: inventory.lowStockIngredientIds.length),
          Expanded(
            child: inventory.ingredients.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: inventory.ingredients.length,
                    itemBuilder: (context, index) {
                      final ingredient = inventory.ingredients[index];
                      return IngredientListTile(
                        ingredient: ingredient,
                        isLowStock: inventory.lowStockIngredientIds
                            .contains(ingredient.ingredientId),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                IngredientDetailScreen(ingredient: ingredient),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}