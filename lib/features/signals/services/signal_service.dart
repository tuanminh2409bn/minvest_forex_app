import 'package:cloud_firestore/cloud_firestore.dart';

class SignalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lấy một Stream các tín hiệu đang chạy, sắp xếp mới nhất lên đầu
  Stream<QuerySnapshot> getRunningSignals({String? userTier}) {
    Query query = _firestore
        .collection('signals')
        .where('status', isEqualTo: 'running')
        .orderBy('createdAt', descending: true);

    // Nếu là demo, chỉ lấy 8 tín hiệu
    if (userTier == 'demo') {
      query = query.limit(8);
    }

    return query.snapshots();
  }

  Stream<QuerySnapshot> getClosedSignals() {
    return _firestore
        .collection('signals')
        .where('status', isEqualTo: 'closed')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}