import 'package:intl/intl.dart';

class InventoryItem {
  final String productName;
  final int remainingQuantity;
  final DateTime nearestExpiryDate;
  final String note;

  InventoryItem({
    required this.productName,
    required this.remainingQuantity,
    required this.nearestExpiryDate,
    required this.note,
  });

  String get formattedExpiryDate => DateFormat('yyyy-MM-dd').format(nearestExpiryDate);
}