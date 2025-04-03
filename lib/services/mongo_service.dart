import 'package:mongo_dart/mongo_dart.dart';

class MongoService {
  static const connectionString = 
      'mongodb+srv://vetinternational1968:mahmoud123456@ivc-cluster.2nmzm9h.mongodb.net/';
  
  late Db _db;
  
  Future<void> connect(String dbName) async {
    _db = await Db.create('$connectionString$dbName?retryWrites=true&w=majority');
    await _db.open();
  }

  Future<List<Map<String, dynamic>>> getInventoryData() async {
    final collection = _db.collection('Inventory');
    final pipeline = [
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
    ];
    return await collection.aggregateToStream(pipeline).toList();
  }

  Future<List<Map<String, dynamic>>> getSalesData(DateTime startDate, DateTime endDate) async {
    final collection = _db.collection('Sale');
    return await collection.find({
      'createdAt': {
        '\$gte': startDate,
        '\$lte': endDate
      }
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getServicesData(DateTime startDate, DateTime endDate) async {
    final collection = _db.collection('Sale');
    return await collection.find({
      'createdAt': {
        '\$gte': startDate,
        '\$lte': endDate
      }
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getPaymentData(DateTime startDate, DateTime endDate) async {
    final collection = _db.collection('Payment');
    return await collection.find({
      'paidAt': {
        '\$gte': startDate,
        '\$lte': endDate
      }
    }).toList();
  }

  Future<void> close() async {
    await _db.close();
  }
}