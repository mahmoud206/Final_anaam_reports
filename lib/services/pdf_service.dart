import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'package:intl/intl.dart';
import 'package:vetra_anaam_report/models/report_data.dart';

class PdfService {
  Future<File> generateSalesReport(
      List<SalesData> salesData,
      String databaseName,
      DateTimeRange dateRange,
      ) async {
    final pdf = pw.Document();

    // Add a page with header and table
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              _buildHeader(databaseName, 'Sales Report', dateRange),
              pw.SizedBox(height: 20),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  // Header row
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Product', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Qty', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Price', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Profit', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Total Profit', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  // Data rows
                  for (var sale in salesData)
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(DateFormat('yyyy-MM-dd').format(sale.date)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(sale.productName),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(sale.quantity.toString()),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(sale.price.toStringAsFixed(2)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(sale.profit.toStringAsFixed(2)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(sale.total.toStringAsFixed(2)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(sale.totalProfit.toStringAsFixed(2)),
                        ),
                      ],
                    ),
                ],
              ),
              pw.SizedBox(height: 20),
              _buildSalesSummary(salesData),
            ],
          );
        },
      ),
    );

    return _saveDocument(pdf, 'sales_report_${_formatDateRange(dateRange)}.pdf');
  }

  Future<File> generateServicesReport(
      List<ServiceData> servicesData,
      String databaseName,
      DateTimeRange dateRange,
      ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              _buildHeader(databaseName, 'Services Report', dateRange),
              pw.SizedBox(height: 20),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  // Header row
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Service', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Qty', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Price', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  // Data rows
                  for (var service in servicesData)
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(DateFormat('yyyy-MM-dd').format(service.date)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(service.serviceName),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(service.quantity.toString()),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(service.price.toStringAsFixed(2)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(service.total.toStringAsFixed(2)),
                        ),
                      ],
                    ),
                ],
              ),
              pw.SizedBox(height: 20),
              _buildServicesSummary(servicesData),
            ],
          );
        },
      ),
    );

    return _saveDocument(pdf, 'services_report_${_formatDateRange(dateRange)}.pdf');
  }

  Future<File> generatePaymentReport(
      List<PaymentData> paymentData,
      String databaseName,
      DateTimeRange dateRange,
      ) async {
    final pdf = pw.Document();

    // Group payment data by method and direction
    final shabkaOutgoing = paymentData
        .where((p) => p.method == 'شبكة' && p.isOutgoing)
        .toList();
    final shabkaIncoming = paymentData
        .where((p) => p.method == 'شبكة' && !p.isOutgoing)
        .toList();
    final naqdiOutgoing = paymentData
        .where((p) => p.method == 'نقدي' && p.isOutgoing)
        .toList();
    final naqdiIncoming = paymentData
        .where((p) => p.method == 'نقدي' && !p.isOutgoing)
        .toList();

    // Add a page for each section
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              _buildHeader(databaseName, 'Payment Report - Outgoing شبكة', dateRange),
              pw.SizedBox(height: 20),
              _buildPaymentTable(shabkaOutgoing),
              pw.SizedBox(height: 20),
              _buildPaymentSummary(shabkaOutgoing, 'Total Outgoing شبكة'),
            ],
          );
        },
      ),
    );

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              _buildHeader(databaseName, 'Payment Report - Incoming شبكة', dateRange),
              pw.SizedBox(height: 20),
              _buildPaymentTable(shabkaIncoming),
              pw.SizedBox(height: 20),
              _buildPaymentSummary(shabkaIncoming, 'Total Incoming شبكة'),
            ],
          );
        },
      ),
    );

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              _buildHeader(databaseName, 'Payment Report - Outgoing نقدي', dateRange),
              pw.SizedBox(height: 20),
              _buildPaymentTable(naqdiOutgoing),
              pw.SizedBox(height: 20),
              _buildPaymentSummary(naqdiOutgoing, 'Total Outgoing نقدي'),
            ],
          );
        },
      ),
    );

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              _buildHeader(databaseName, 'Payment Report - Incoming نقدي', dateRange),
              pw.SizedBox(height: 20),
              _buildPaymentTable(naqdiIncoming),
              pw.SizedBox(height: 20),
              _buildPaymentSummary(naqdiIncoming, 'Total Incoming نقدي'),
            ],
          );
        },
      ),
    );

    return _saveDocument(pdf, 'payment_report_${_formatDateRange(dateRange)}.pdf');
  }

  pw.Widget _buildHeader(String databaseName, String title, DateTimeRange dateRange) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          databaseName,
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
        ),
        pw.Text(
          'Date Range: ${DateFormat('yyyy-MM-dd').format(dateRange.start)} to ${DateFormat('yyyy-MM-dd').format(dateRange.end)}',
          style: const pw.TextStyle(fontSize: 14),
        ),
        pw.Text(
          'Generated on: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
          style: const pw.TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  pw.Widget _buildPaymentTable(List<PaymentData> paymentData) {
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        // Header row
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('Date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('Amount', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('Description', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
          ],
        ),
        // Data rows
        for (var payment in paymentData)
          pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(DateFormat('yyyy-MM-dd').format(payment.date)),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(payment.amount.toStringAsFixed(2)),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(payment.description),
              ),
            ],
          ),
      ],
    );
  }

  pw.Widget _buildSalesSummary(List<SalesData> salesData) {
    final totalSales = salesData.fold(0.0, (sum, sale) => sum + sale.total);
    final totalProfit = salesData.fold(0.0, (sum, sale) => sum + sale.totalProfit);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Text(
          'Total Sales: ${totalSales.toStringAsFixed(2)}',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
        pw.Text(
          'Total Profit: ${totalProfit.toStringAsFixed(2)}',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }

  pw.Widget _buildServicesSummary(List<ServiceData> servicesData) {
    final totalRevenue = servicesData.fold(0.0, (sum, service) => sum + service.total);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Text(
          'Total Revenue: ${totalRevenue.toStringAsFixed(2)}',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }

  pw.Widget _buildPaymentSummary(List<PaymentData> paymentData, String title) {
    final totalAmount = paymentData.fold(0.0, (sum, payment) => sum + payment.amount);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Text(
          '$title: ${totalAmount.toStringAsFixed(2)}',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }

  Future<File> _saveDocument(pw.Document document, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(await document.save());
    return file;
  }

  Future<void> openPdf(File file) async {
    await OpenFile.open(file.path);
  }

  String _formatDateRange(DateTimeRange range) {
    return '${DateFormat('yyyyMMdd').format(range.start)}_${DateFormat('yyyyMMdd').format(range.end)}';
  }
}