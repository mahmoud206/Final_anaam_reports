import 'package:vetra_anaam_report/services/mongo_service.dart';

class ReportService {
  final MongoService _mongoService = MongoService();

  Future<List<Map<String, dynamic>>> getSalesData(
    String dbName,
    DateTime startDate,
    DateTime endDate,
  ) async {
    await _mongoService.connect(dbName);
    return await _mongoService.getSalesData(startDate, endDate);
  }

  Future<List<Map<String, dynamic>>> getServicesData(
    String dbName,
    DateTime startDate,
    DateTime endDate,
  ) async {
    await _mongoService.connect(dbName);
    return await _mongoService.getServicesData(startDate, endDate);
  }

  Future<List<Map<String, dynamic>>> getPaymentData(
    String dbName,
    DateTime startDate,
    DateTime endDate,
  ) async {
    await _mongoService.connect(dbName);
    return await _mongoService.getPaymentData(startDate, endDate);
  }
}