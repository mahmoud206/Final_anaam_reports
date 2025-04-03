import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vetra_anaam_report/models/database.dart';
import 'package:vetra_anaam_report/models/inventory_item.dart';
import 'package:vetra_anaam_report/services/pdf_service.dart';
import 'package:vetra_anaam_report/services/report_service.dart';
import 'package:vetra_anaam_report/utils/date_utils.dart';
import 'package:vetra_anaam_report/widgets/custome_data_table.dart';

class InventoryScreen extends StatefulWidget {
  final Database database;

  const InventoryScreen({super.key, required this.database});

  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List<InventoryItem> inventoryItems = [];
  bool isLoading = false;
  final ReportService _reportService = ReportService();
  final PdfService _pdfService = PdfService();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Mock data
    setState(() {
      inventoryItems = [
        InventoryItem(
          productName: "Product A",
          remainingQuantity: 10,
          nearestExpiryDate: DateTime.now().add(const Duration(days: 30)),
          note: "",
        ),
        InventoryItem(
          productName: "Product B",
          remainingQuantity: 3,
          nearestExpiryDate: DateTime.now().add(const Duration(days: 60)),
          note: "Other expiry dates: 2 on 2023-12-01",
        ),
        InventoryItem(
          productName: "Product C",
          remainingQuantity: 15,
          nearestExpiryDate: DateTime.now().add(const Duration(days: 90)),
          note: "",
        ),
      ];
      isLoading = false;
    });
  }

  Future<void> generateSalesReport() async {
    final dateRange = await showDateRangePickerDialog(context);
    if (dateRange == null) return;

    setState(() => isLoading = true);

    try {
      // Get sales data (mock implementation)
      final salesData = await _reportService.getSalesData(
        widget.database.name,
        dateRange.start,
        dateRange.end,
      );

      // Generate PDF
      final pdfFile = await _pdfService.generateSalesReport(
        salesData,
        widget.database.name,
        dateRange,
      );

      // Open the PDF
      await _pdfService.openPdf(pdfFile);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sales report generated successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating report: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> generateServicesReport() async {
    final dateRange = await showDateRangePickerDialog(context);
    if (dateRange == null) return;

    setState(() => isLoading = true);

    try {
      // Get services data (mock implementation)
      final servicesData = await _reportService.getServicesData(
        widget.database.name,
        dateRange.start,
        dateRange.end,
      );

      // Generate PDF
      final pdfFile = await _pdfService.generateServicesReport(
        servicesData,
        widget.database.name,
        dateRange,
      );

      // Open the PDF
      await _pdfService.openPdf(pdfFile);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Services report generated successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating report: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> generatePaymentReport() async {
    final dateRange = await showDateRangePickerDialog(context);
    if (dateRange == null) return;

    setState(() => isLoading = true);

    try {
      // Get payment data (mock implementation)
      final paymentData = await _reportService.getPaymentData(
        widget.database.name,
        dateRange.start,
        dateRange.end,
      );

      // Generate PDF
      final pdfFile = await _pdfService.generatePaymentReport(
        paymentData,
        widget.database.name,
        dateRange,
      );

      // Open the PDF
      await _pdfService.openPdf(pdfFile);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment report generated successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating report: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.database.symbol} ${widget.database.name} Inventory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Switch Database',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: loadData,
                  child: const Text('Refresh Data'),
                ),
              ],
            ),
          ),
          Expanded(
            child: CustomDataTable(
              inventoryItems: inventoryItems,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.bar_chart),
                  label: const Text('Sales Report'),
                  onPressed: generateSalesReport,
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.show_chart),
                  label: const Text('Services Report'),
                  onPressed: generateServicesReport,
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.monetization_on),
                  label: const Text('Payment Report'),
                  onPressed: generatePaymentReport,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}