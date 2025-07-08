import 'package:cloud_firestore/cloud_firestore.dart';

class Signal {
  final String id;
  final String symbol;
  final String type;
  final String status;
  final double entryPrice;
  final double stopLoss;
  final List<dynamic> takeProfits;
  final Timestamp createdAt;
  final String? result;
  final num? pips;

  Signal({
    required this.id,
    required this.symbol,
    required this.type,
    required this.status,
    required this.entryPrice,
    required this.stopLoss,
    required this.takeProfits,
    required this.createdAt,
    this.result,
    this.pips,
  });

  // Factory constructor để tạo Signal từ một DocumentSnapshot của Firestore
  factory Signal.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Signal(
      id: doc.id,
      symbol: data['symbol'] ?? '',
      type: data['type'] ?? 'buy',
      status: data['status'] ?? 'running',
      entryPrice: (data['entryPrice'] ?? 0.0).toDouble(),
      stopLoss: (data['stopLoss'] ?? 0.0).toDouble(),
      takeProfits: List.from(data['takeProfits'] ?? []),
      createdAt: data['createdAt'] ?? Timestamp.now(),
      result: data['result'],
      pips: data['pips'],
    );
  }
}