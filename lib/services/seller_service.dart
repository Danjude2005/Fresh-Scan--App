import 'package:cloud_firestore/cloud_firestore.dart';

class SellerService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── Get all sellers ────────────────────────────────────────────────────────
  Stream<List<Map<String, dynamic>>> getSellers() {
    return _db.collection('sellers').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => doc.data()).toList());
  }

  // ─── Search sellers ─────────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> searchSellers(String query) async {
    final snapshot = await _db
        .collection('sellers')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: '$query\uf8ff')
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}
