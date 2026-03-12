import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ─── Collection Reference ───────────────────────────────────────────────────
  CollectionReference get _products => _db.collection('products');

  // ─── Add a new product ──────────────────────────────────────────────────────
  Future<bool> addProduct({
    required String name,
    required String category,
    required int freshness,
    required int nutrition,
    required int pesticides,
    required double price,
    required String quantity,
    required int shelfLife,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await _products.add({
        'sellerId': user.uid,
        'sellerName': user.displayName ?? 'Unknown Seller',
        'name': name,
        'category': category,
        'freshness': freshness,
        'nutrition': nutrition,
        'pesticides': pesticides,
        'price': price,
        'quantity': quantity,
        'shelfLife': shelfLife,
        'status': _getStatusText(freshness),
        'lastScanned': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update seller's total products count
      await _db.collection('sellers').doc(user.uid).update({
        'totalProducts': FieldValue.increment(1),
      });

      return true;
    } catch (e) {
      print('Error adding product: $e');
      return false;
    }
  }

  // ─── Get products for a specific seller ─────────────────────────────────────
  Stream<List<Map<String, dynamic>>> getSellerProducts() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _products
        .where('sellerId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
            .toList());
  }

  // ─── Get all fresh products (for buyers) ───────────────────────────────────
  Stream<List<Map<String, dynamic>>> getAllProducts() {
    return _products
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
            .toList());
  }

  // ─── Update product ─────────────────────────────────────────────────────────
  Future<bool> updateProduct(String productId, Map<String, dynamic> data) async {
    try {
      await _products.doc(productId).update(data);
      return true;
    } catch (e) {
      return false;
    }
  }

  // ─── Delete product ─────────────────────────────────────────────────────────
  Future<bool> deleteProduct(String productId) async {
    try {
      final doc = await _products.doc(productId).get();
      final sellerId = (doc.data() as Map<String, dynamic>)['sellerId'];
      
      await _products.doc(productId).delete();

      // Update seller's total products count
      await _db.collection('sellers').doc(sellerId).update({
        'totalProducts': FieldValue.increment(-1),
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  // ─── Save Scan History ──────────────────────────────────────────────────────
  Future<void> saveScanResult({
    required String name,
    required int freshness,
    required int nutrition,
    required int pesticides,
    required int shelfLife,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _db.collection('scan_history').add({
      'userId': user.uid,
      'productName': name,
      'freshness': freshness,
      'nutrition': nutrition,
      'pesticides': pesticides,
      'shelfLife': shelfLife,
      'scannedAt': FieldValue.serverTimestamp(),
    });

    // Increment scan count in user profile
    await _db.collection('users').doc(user.uid).update({
      'totalScans': FieldValue.increment(1),
    });
  }

  String _getStatusText(int freshness) {
    if (freshness >= 75) return "Fresh";
    if (freshness >= 50) return "Moderate";
    return "Not Fresh";
  }
}
