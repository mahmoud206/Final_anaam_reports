import 'package:flutter/material.dart';
import 'package:vetra_anaam_report/models/database.dart';
import 'package:vetra_anaam_report/screens/inventory_screen.dart';

class DatabaseSelectionScreen extends StatefulWidget {
  const DatabaseSelectionScreen({super.key});

  @override
  _DatabaseSelectionScreenState createState() => _DatabaseSelectionScreenState();
}

class _DatabaseSelectionScreenState extends State<DatabaseSelectionScreen> {
  final List<Database> databases = [
    Database(id: 1, name: "Elanam-KhamisMushit", symbol: "🏥"),
    Database(id: 2, name: "Elanam-Zapia", symbol: "🏢"),
    Database(id: 3, name: "Elanam-Baish", symbol: "🏭"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Database'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '🔍 Select Database',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: ListView.builder(
                itemCount: databases.length,
                itemBuilder: (context, index) {
                  final db = databases[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 40),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InventoryScreen(database: db),
                          ),
                        );
                      },
                      child: Text(
                        '${db.symbol} ${db.name}',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}