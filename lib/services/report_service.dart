import 'package:intl/intl.dart';
import 'package:vetra_anaam_report/models/report_data.dart';

class ReportService {
  Future<List<SalesData>> getSalesData(
      String databaseName,
      DateTime startDate,
      DateTime endDate,
      ) async {
    // Mock data - replace with actual MongoDB query
    return [
      SalesData(
        date: startDate,
        productName: "Product A",
        quantity: 5,
        price: 10.0,
        profit: 2.0,
      ),
      SalesData(
        date: startDate.add(const Duration(days: 1)),
        productName: "Product B",
        quantity: 3,
        price: 15.0,
        profit: 3.0,
      ),
    ];
  }

  Future<List<ServiceData>> getServicesData(
      String databaseName,
      DateTime startDate,
      DateTime endDate,
      ) async {
    // Mock data - replace with actual MongoDB query
    return [
      ServiceData(
        date: startDate,
        serviceName: "Service A",
        quantity: 2,
        price: 50.0,
      ),
      ServiceData(
        date: startDate.add(const Duration(days: 1)),
        serviceName: "Service B",
        quantity: 1,
        price: 75.0,
      ),
    ];
  }

  Future<List<PaymentData>> getPaymentData(
      String databaseName,
      DateTime startDate,
      DateTime endDate,
      ) async {
    // Mock data - replace with actual MongoDB query
    return [
      PaymentData(
        date: startDate,
        method: "شبكة",
        isOutgoing: true,
        amount: 100.0,
        description: "Payment 1",
      ),
      PaymentData(
        date: startDate,
        method: "شبكة",
        isOutgoing: false,
        amount: 150.0,
        description: "Payment 2",
      ),
      PaymentData(
        date: startDate.add(const Duration(days: 1)),
        method: "نقدي",
        isOutgoing: true,
        amount: 200.0,
        description: "Payment 3",
      ),
      PaymentData(
        date: startDate.add(const Duration(days: 1)),
        method: "نقدي",
        isOutgoing: false,
        amount: 250.0,
        description: "Payment 4",
      ),
    ];
  }
}