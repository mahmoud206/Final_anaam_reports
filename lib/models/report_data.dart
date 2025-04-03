class SalesData {
  final DateTime date;
  final String productName;
  final int quantity;
  final double price;
  final double profit;

  SalesData({
    required this.date,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.profit,
  });

  double get total => quantity * price;
  double get totalProfit => quantity * profit;
}

class ServiceData {
  final DateTime date;
  final String serviceName;
  final int quantity;
  final double price;

  ServiceData({
    required this.date,
    required this.serviceName,
    required this.quantity,
    required this.price,
  });

  double get total => quantity * price;
}

class PaymentData {
  final DateTime date;
  final String method;
  final bool isOutgoing;
  final double amount;
  final String description;

  PaymentData({
    required this.date,
    required this.method,
    required this.isOutgoing,
    required this.amount,
    required this.description,
  });
}