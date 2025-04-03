import 'package:mongo_dart/mongo_dart.dart';

class MongoService {
  // Primary connection string with all shards explicitly listed
  static const _baseConnectionString = 
    'mongodb://vetinternational1968:mahmoud123456@'
    'ivc-cluster-shard-00-00.2nmzm9h.mongodb.net:27017,'
    'ivc-cluster-shard-00-01.2nmzm9h.mongodb.net:27017,'
    'ivc-cluster-shard-00-02.2nmzm9h.mongodb.net:27017/'
    '?ssl=true&replicaSet=atlas-b5q7qk-shard-0'
    '&authSource=admin&retryWrites=true&w=majority';

  late Db _db;
  bool _isConnected = false;

  Future<void> connect(String dbName) async {
    try {
      final connectionUri = '$_baseConnectionString$dbName';
      
      _db = Db(connectionUri);
      
      // Configure connection settings
      _db.connectionTimeout = 30; // 30 seconds timeout
      _db.queryTimeout = 15; // 15 seconds for queries
      
      await _db.open().then((_) {
        _isConnected = true;
        print('Successfully connected to MongoDB');
      });

    } on SocketException catch (e) {
      throw Exception('Network error: Failed to connect to MongoDB. Please check your internet connection.\n$e');
    } on MongoDartError catch (e) {
      throw Exception('MongoDB error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to connect: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getInventoryData() async {
    _checkConnection();
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
    _checkConnection();
    try {
      final collection = _db.collection('Sale');
      return await collection.find({
        'createdAt': {
          '\$gte': startDate,
          '\$lte': endDate
        }
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch sales data: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getServicesData(DateTime startDate, DateTime endDate) async {
    _checkConnection();
    try {
      final collection = _db.collection('Service'); // Changed from 'Sale' to 'Service'
      return await collection.find({
        'createdAt': {
          '\$gte': startDate,
          '\$lte': endDate
        }
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch services data: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getPaymentData(DateTime startDate, DateTime endDate) async {
    _checkConnection();
    try {
      final collection = _db.collection('Payment');
      return await collection.find({
        'paidAt': {
          '\$gte': startDate,
          '\$lte': endDate
        }
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch payment data: $e');
    }
  }

  Future<void> close() async {
    if (_isConnected) {
      await _db.close();
      _isConnected = false;
    }
  }

  void _checkConnection() {
    if (!_isConnected) {
      throw Exception('Not connected to MongoDB. Call connect() first.');
    }
  }
}