import 'dart:io';
import 'package:mongo_dart/mongo_dart.dart';

class MongoService {
  // Database configurations
  static  Map<String, String> _databaseConfigs = {
    'Elanam-KhamisMushit': _buildConnectionString(),
    'Elanam-Zapia': _buildConnectionString(),
    'Elanam-Baish': _buildConnectionString(),
  };

  static String _buildConnectionString() {
    return 'mongodb://vetinternational1968:mahmoud123456@'
        'ivc-cluster-shard-00-00.2nmzm9h.mongodb.net:27017,'
        'ivc-cluster-shard-00-01.2nmzm9h.mongodb.net:27017,'
        'ivc-cluster-shard-00-02.2nmzm9h.mongodb.net:27017/'
        '?ssl=true&replicaSet=atlas-b5q7qk-shard-0'
        '&authSource=admin&retryWrites=true&w=majority';
  }

  late Db _db;
  String? _currentDbName;
  bool _isConnected = false;

  Future<void> connect(String dbName) async {
    if (_isConnected && _currentDbName == dbName) {
      return; // Already connected
    }

    await close(); // Close existing connection

    try {
      if (!_databaseConfigs.containsKey(dbName)) {
        throw Exception('Database "$dbName" not configured');
      }

      final connectionUri = '${_databaseConfigs[dbName]}$dbName';
      _db = await Db.create(connectionUri);

      // Set timeout using connection pool settings
      await _db.open().timeout(const Duration(seconds: 30));

      await _db.open().then((_) {
        _isConnected = true;
        _currentDbName = dbName;
        print('Connected to $dbName');
      });
    } on SocketException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Connection failed: $e');
    }
  }

  // All your data methods remain exactly the same
  Future<List<Map<String, dynamic>>> getInventoryData() async {
    _verifyConnection();
    try {
      final collection = _db.collection('Inventory');
      return await collection.aggregateToStream([
        {
          '\$group': {
            '_id': '\$productName',
            'totalQuantity': {'\$sum': '\$remainingQuantity'},
            'expiryDates': {'\$push': '\$expiryDate'}
          }
        },
        {
          '\$project': {
            'productName': '\$_id',
            'remainingQuantity': '\$totalQuantity',
            'expiryDates': 1,
            '_id': 0
          }
        }
      ]).toList();
    } catch (e) {
      throw Exception('Failed to fetch inventory: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getSalesData(DateTime startDate, DateTime endDate) async {
    _verifyConnection();
    try {
      final collection = _db.collection('Sale');
      return await collection.find({
        'createdAt': {
          '\$gte': startDate,
          '\$lte': endDate
        }
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch sales: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getServicesData(DateTime startDate, DateTime endDate) async {
    _verifyConnection();
    try {
      final collection = _db.collection('Service');
      return await collection.find({
        'createdAt': {
          '\$gte': startDate,
          '\$lte': endDate
        }
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch services: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getPaymentData(DateTime startDate, DateTime endDate) async {
    _verifyConnection();
    try {
      final collection = _db.collection('Payment');
      return await collection.find({
        'paidAt': {
          '\$gte': startDate,
          '\$lte': endDate
        }
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch payments: $e');
    }
  }

  Future<void> close() async {
    if (_isConnected) {
      await _db.close();
      _isConnected = false;
      _currentDbName = null;
    }
  }

  void _verifyConnection() {
    if (!_isConnected) {
      throw Exception('No active connection. Call connect() first.');
    }
  }

  static List<String> getAvailableDatabases() {
    return _databaseConfigs.keys.toList();
  }
}
