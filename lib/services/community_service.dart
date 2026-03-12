import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommunityService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ─── Collection Reference ───────────────────────────────────────────────────
  CollectionReference get _communities => _db.collection('communities');

  // ─── Create a new community ─────────────────────────────────────────────────
  Future<bool> createCommunity({
    required String name,
    required String type,
    required String description,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await _communities.add({
        'name': name,
        'type': type,
        'description': description,
        'createdBy': user.uid,
        'memberCount': 1,
        'members': [user.uid],
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // ─── Join/Leave community ───────────────────────────────────────────────────
  Future<bool> toggleJoin(String communityId, bool join) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      if (join) {
        await _communities.doc(communityId).update({
          'members': FieldValue.arrayUnion([user.uid]),
          'memberCount': FieldValue.increment(1),
        });
      } else {
        await _communities.doc(communityId).update({
          'members': FieldValue.arrayRemove([user.uid]),
          'memberCount': FieldValue.increment(-1),
        });
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  // ─── Stream all communities ────────────────────────────────────────────────
  Stream<List<Map<String, dynamic>>> getCommunities() {
    return _communities.orderBy('createdAt', descending: true).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
              .toList(),
        );
  }
}
