import 'package:cloud_firestore/cloud_firestore.dart';

class SignalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lấy một Stream các tín hiệu đang chạy, sắp xếp mới nhất lên đầu
  Stream<QuerySnapshot> getRunningSignals() {
    return _firestore
        .collection('signals')
        .where('status', isEqualTo: 'running')
        .orderBy('createdAt', descending: true)
        .snapshots();

  }

  Stream<QuerySnapshot> getClosedSignals() {
    return _firestore
        .collection('signals')
        .where('status', isEqualTo: 'closed')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}