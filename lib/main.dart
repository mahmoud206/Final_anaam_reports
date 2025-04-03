import 'package:flutter/material.dart';
import 'package:vetra_anaam_report/screens/database_selection_screen.dart';

void main() {
  runApp(const InventoryApp());
}

class InventoryApp extends StatelessWidget {
  const InventoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VetraTech Inventory',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const DatabaseSelectionScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}