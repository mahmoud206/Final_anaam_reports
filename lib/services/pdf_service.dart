import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'package:intl/intl.dart';
import 'package:vetra_anaam_report/models/report_data.dart';
import 'package:vetra_anaam_report/utils/date_utils.dart';

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
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(databaseName, 'Sales Report', dateRange),
              pw.SizedBox(height: 20),
              _buildSalesTable(salesData),
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
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(databaseName, 'Services Report', dateRange),
              pw.SizedBox(height: 20),
              _buildServicesTable(servicesData),
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
    _addPaymentPage(pdf, databaseName, dateRange, shabkaOutgoing, 'Outgoing شبكة');
    _addPaymentPage(pdf, databaseName, dateRange, shabkaIncoming, 'Incoming شبكة');
    _addPaymentPage(pdf, databaseName, dateRange, naqdiOutgoing, 'Outgoing نقدي');
    _addPaymentPage(pdf, databaseName, dateRange, naqdiIncoming, 'Incoming نقدي');

    return _saveDocument(pdf, 'payment_report_${_formatDateRange(dateRange)}.pdf');
  }

  void _addPaymentPage(
    pw.Document pdf,
    String databaseName,
    DateTimeRange dateRange,
    List<PaymentData> payments,
    String title,
  ) {
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(databaseName, 'Payment Report - $title', dateRange),
              pw.SizedBox(height: 20),
              _buildPaymentTable(payments),
              pw.SizedBox(height: 20),
              _buildPaymentSummary(payments, 'Total $title'),
            ],
          );
        },
      ),
    );
  }

  pw.Widget _buildHeader(String databaseName, String title, DateTimeRange dateRange) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          databaseName,
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 22,
            fontWeight: pw.FontWeight.bold,
          ),
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

  pw.Widget _buildSalesTable(List<SalesData> salesData) {
    return pw.Table.fromTextArray(
      context: null,
      border: pw.TableBorder.all(),
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      ),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blue700),
      headers: ['Date', 'Product', 'Qty', 'Price', 'Profit', 'Total', 'Total Profit'],
      data: salesData.map((sale) => [
        DateFormat('yyyy-MM-dd').format(sale.date),
        sale.productName,
        sale.quantity.toString(),
        _formatCurrency(sale.price),
        _formatCurrency(sale.profit),
        _formatCurrency(sale.total),
        _formatCurrency(sale.totalProfit),
      ]).toList(),
      cellAlignment: pw.Alignment.centerLeft,
      cellStyle: const pw.TextStyle(fontSize: 10),
    );
  }

  pw.Widget _buildSalesSummary(List<SalesData> salesData) {
    final totalSales = salesData.fold(0.0, (sum, sale) => sum + sale.total);
    final totalProfit = salesData.fold(0.0, (sum, sale) => sum + sale.totalProfit);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Text(
          'Total Sales: ${_formatCurrency(totalSales)}',
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 12,
          ),
        ),
        pw.Text(
          'Total Profit: ${_formatCurrency(totalProfit)}',
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildServicesTable(List<ServiceData> servicesData) {
    return pw.Table.fromTextArray(
      context: null,
      border: pw.TableBorder.all(),
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      ),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.green700),
      headers: ['Date', 'Service', 'Qty', 'Price', 'Total'],
      data: servicesData.map((service) => [
        DateFormat('yyyy-MM-dd').format(service.date),
        service.serviceName,
        service.quantity.toString(),
        _formatCurrency(service.price),
        _formatCurrency(service.total),
      ]).toList(),
      cellAlignment: pw.Alignment.centerLeft,
      cellStyle: const pw.TextStyle(fontSize: 10),
    );
  }

  pw.Widget _buildServicesSummary(List<ServiceData> servicesData) {
    final totalRevenue = servicesData.fold(0.0, (sum, service) => sum + service.total);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Text(
          'Total Revenue: ${_formatCurrency(totalRevenue)}',
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildPaymentTable(List<PaymentData> paymentData) {
    return pw.Table.fromTextArray(
      context: null,
      border: pw.TableBorder.all(),
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      ),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.purple700),
      headers: ['Date', 'Amount', 'Description'],
      data: paymentData.map((payment) => [
        DateFormat('yyyy-MM-dd').format(payment.date),
        _formatCurrency(payment.amount),
        payment.description,
      ]).toList(),
      cellAlignment: pw.Alignment.centerLeft,
      cellStyle: const pw.TextStyle(fontSize: 10),
    );
  }

  pw.Widget _buildPaymentSummary(List<PaymentData> paymentData, String title) {
    final totalAmount = paymentData.fold(0.0, (sum, payment) => sum + payment.amount);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Text(
          '$title: ${_formatCurrency(totalAmount)}',
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
    ).format(amount);
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