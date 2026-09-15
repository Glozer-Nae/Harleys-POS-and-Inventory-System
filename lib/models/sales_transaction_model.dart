import 'package:cloud_firestore/cloud_firestore.dart';

/// One product line within a sale. Not in the submitted Data Dictionary —
/// added so a deduction can be traced back to which product caused it.
class SoldItem {
  final String productId;
  final int quantitySold;
  final double unitPrice;

  SoldItem({
    required this.productId,
    required this.quantitySold,
    required this.unitPrice,
  });

  factory SoldItem.fromMap(Map<String, dynamic> map) {
    return SoldItem(
      productId: map['productId'] as String,
      quantitySold: (map['quantitySold'] as num).toInt(),
      unitPrice: (map['unitPrice'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'quantitySold': quantitySold,
      'unitPrice': unitPrice,
    };
  }
}

class SalesTransaction {
  final String salesTransId;
  final double salesTransAmount;
  final int salesTransQty;
  final DateTime salesTransDate;
  final List<SoldItem> items;

  SalesTransaction({
    required this.salesTransId,
    required this.salesTransAmount,
    required this.salesTransQty,
    required this.salesTransDate,
    required this.items,
  });

  factory SalesTransaction.fromMap(String id, Map<String, dynamic> map) {
    final rawItems = (map['items'] as List<dynamic>? ?? []);
    return SalesTransaction(
      salesTransId: id,
      salesTransAmount: (map['salesTransAmount'] as num?)?.toDouble() ?? 0.0,
      salesTransQty: (map['salesTransQty'] as num?)?.toInt() ?? 0,
      salesTransDate:
          (map['salesTransDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      items: rawItems
          .map((e) => SoldItem.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'salesTransAmount': salesTransAmount,
      'salesTransQty': salesTransQty,
      'salesTransDate': Timestamp.fromDate(salesTransDate),
      'items': items.map((i) => i.toMap()).toList(),
    };
  }
}