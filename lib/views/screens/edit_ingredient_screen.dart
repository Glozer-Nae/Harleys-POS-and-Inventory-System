import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/ingredient_model.dart';
import '../../providers/inventory_provider.dart';
import '../widgets/confirm_changes_dialog.dart';


class EditIngredientScreen extends StatefulWidget {
  final Ingredient ingredient;

  const EditIngredientScreen({super.key, required this.ingredient});

  @override
  State<EditIngredientScreen> createState() => _EditIngredientScreenState();
}

class _EditIngredientScreenState extends State<EditIngredientScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _qtyController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.ingredient.ingredientName);
    _qtyController = TextEditingController(text: widget.ingredient.ingredientQty.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  Future<void> _confirmAndSave() async {
    final name = _nameController.text.trim();
    final qty = int.tryParse(_qtyController.text.trim());

    if (name.isEmpty || qty == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid name and quantity.')),
      );
      return;
    }

    final confirmed = await showConfirmChangesDialog(
      context,
      message: 'Save "$name" with quantity $qty?',
    );

    if (!confirmed) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No Changes')),
        );
      }
      return;
    }

    setState(() => _isSaving = true);
    try {
      await context.read<InventoryProvider>().updateIngredient(
            widget.ingredient,
            name: name,
            qty: qty,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Changes Saved!')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Ingredient')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Ingredient Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _qtyController,
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            _isSaving
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _confirmAndSave,
                    child: const Text('Save'),
                  ),
          ],
        ),
      ),
    );
  }
}