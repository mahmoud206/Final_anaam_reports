import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:inventory_app/models/database.dart';
import 'package:inventory_app/models/inventory_item.dart';
import 'package:inventory_app/models/report_data.dart';
import 'package:inventory_app/services/mongo_service.dart';
import 'package:inventory_app/services/pdf_service.dart';
import 'package:inventory_app/utils/date_utils.dart';
import 'package:inventory_app/widgets/custom_data_table.dart';

class InventoryScreen extends StatefulWidget {
  final Database database;

  const InventoryScreen({super.key, required this.database});

  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List<InventoryItem> inventoryItems = [];
  bool isLoading = false;
  final MongoService _mongoService = MongoService();
  final PdfService _pdfService = PdfService();

  @override
  void initState() {
    super.initState();
    _connectAndLoadData();
  }

  Future<void> _connectAndLoadData() async {
    setState(() => isLoading = true);
    try {
      await _mongoService.connect(widget.database.name);
      final data = await _mongoService.getInventoryData();
      
      setState(() {
        inventoryItems = data.map((item) {
          final expiryDates = (item['expiryDates'] as List).cast<DateTime>();
          final nearestDate = expiryDates.reduce((a, b) => a.isBefore(b) ? a : b);
          
          return InventoryItem(
            productName: item['productName'],
            remainingQuantity: item['remainingQuantity'],
            nearestExpiryDate: nearestDate,
            note: _generateNote(expiryDates, nearestDate),
          );
        }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  String _generateNote(List<DateTime> expiryDates, DateTime nearestDate) {
    final otherDates = expiryDates.where((date) => date != nearestDate).toList();
    if (otherDates.isEmpty) return '';
    
    final dateCounts = <DateTime, int>{};
    for (final date in otherDates) {
      dateCounts[date] = (dateCounts[date] ?? 0) + 1;
    }
    
    return 'Other expiry dates: ' + 
      dateCounts.entries.map((e) => '${e.value} on ${DateFormat('yyyy-MM-dd').format(e.key)}').join(', ');
  }

  Future<void> generateSalesReport() async {
    final dateRange = await showDateRangePickerDialog(context);
    if (dateRange == null) return;

    setState(() => isLoading = true);
    
    try {
      final salesData = await _mongoService.getSalesData(
        dateRange.start,
        dateRange.end,
      );

      // Process sales data
      final List<SalesData> processedSales = [];
      for (final sale in salesData) {
        final items = sale['items'] as List? ?? [];
        for (final item in items) {
          processedSales.add(SalesData(
            date: sale['createdAt'],
            productName: item['productName'],
            quantity: item['quantity'],
            price: item['pricePerUnit']?.toDouble() ?? 0.0,
            profit: item['profit']?.toDouble() ?? 0.0,
          ));
        }
      }

      final pdfFile = await _pdfService.generateSalesReport(
        processedSales,
        widget.database.name,
        dateRange,
      );

      await _pdfService.openPdf(pdfFile);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sales report generated successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating sales report: $e')),
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
      final servicesData = await _mongoService.getServicesData(
        dateRange.start,
        dateRange.end,
      );

      // Process services data
      final List<ServiceData> processedServices = [];
      for (final sale in servicesData) {
        final services = sale['services'] as List? ?? [];
        for (final service in services) {
          processedServices.add(ServiceData(
            date: sale['createdAt'],
            serviceName: service['serviceName'],
            quantity: service['quantity'],
            price: service['price']?.toDouble() ?? 0.0,
          ));
        }
      }

      final pdfFile = await _pdfService.generateServicesReport(
        processedServices,
        widget.database.name,
        dateRange,
      );

      await _pdfService.openPdf(pdfFile);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Services report generated successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating services report: $e')),
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
      final paymentData = await _mongoService.getPaymentData(
        dateRange.start,
        dateRange.end,
      );

      // Process payment data
      final List<PaymentData> processedPayments = paymentData.map((payment) {
        return PaymentData(
          date: payment['paidAt'],
          method: payment['method'],
          isOutgoing: payment['isOutgoing'],
          amount: payment['amount']?.toDouble() ?? 0.0,
          description: payment['description'],
        );
      }).toList();

      final pdfFile = await _pdfService.generatePaymentReport(
        processedPayments,
        widget.database.name,
        dateRange,
      );

      await _pdfService.openPdf(pdfFile);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment report generated successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating payment report: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _mongoService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.database.symbol} ${widget.database.name} Inventory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _connectAndLoadData,
            tooltip: 'Refresh Data',
          ),
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
                if (inventoryItems.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Text('No inventory data available'),
                    ),
                  )
                else
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