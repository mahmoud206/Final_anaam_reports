import 'package:flutter/material.dart';
import 'package:vetra_anaam_report/models/inventory_item.dart';

class CustomDataTable extends StatelessWidget {
  final List<InventoryItem> inventoryItems;

  const CustomDataTable({super.key, required this.inventoryItems});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Product Name')),
          DataColumn(label: Text('Remaining Qty'), numeric: true),
          DataColumn(label: Text('Expiry Date')),
          DataColumn(label: Text('Note')),
        ],
        rows: inventoryItems.map((item) {
          return DataRow(
            cells: [
              DataCell(Text(item.productName)),
              DataCell(Text(item.remainingQuantity.toString())),
              DataCell(Text(item.formattedExpiryDate)),
              DataCell(Text(item.note)),
            ],
          );
        }).toList(),
      ),
    );
  }
}