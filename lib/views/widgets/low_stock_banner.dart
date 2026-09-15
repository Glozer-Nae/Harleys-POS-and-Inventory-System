import 'package:flutter/material.dart';

/// Orange banner shown at the top of InventoryScreen when one or more
/// ingredients have fallen to lowStockThreshold servings or below.
class LowStockBanner extends StatelessWidget {
  final int count;

  const LowStockBanner({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      color: Colors.orange.shade100,
      padding: const EdgeInsets.all(12),
      child: Text(
        '$count ingredient(s) running low.',
        style: TextStyle(color: Colors.orange.shade900),
      ),
    );
  }
}