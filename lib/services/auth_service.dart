import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── Stream of auth state changes ───────────────────────────────────────────
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ─── Current user ────────────────────────────────────────────────────────────
  User? get currentUser => _auth.currentUser;

  // ─── Register with email & password ─────────────────────────────────────────
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    required String role, // 'buyer' or 'seller'
    String? phone,
    String? location,
  }) async {
    try {
      // 1. Create Firebase Auth account
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user!;

      // 2. Update display name
      await user.updateDisplayName(name.trim());

      // 3. Save user profile to Firestore
      await _db.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name.trim(),
        'email': email.trim(),
        'role': role, // 'buyer' or 'seller'
        'phone': phone?.trim() ?? '',
        'location': location?.trim() ?? '',
        'profileImage': '',
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
        'isActive': true,
      });

      // 4. Create role-specific sub-document
      if (role == 'seller') {
        await _db.collection('sellers').doc(user.uid).set({
          'uid': user.uid,
          'name': name.trim(),
          'email': email.trim(),
          'phone': phone?.trim() ?? '',
          'location': location?.trim() ?? '',
          'totalProducts': 0,
          'totalScans': 0,
          'rating': 0.0,
          'joinedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await _db.collection('buyers').doc(user.uid).set({
          'uid': user.uid,
          'name': name.trim(),
          'email': email.trim(),
          'phone': phone?.trim() ?? '',
          'location': location?.trim() ?? '',
          'totalScans': 0,
          'joinedAt': FieldValue.serverTimestamp(),
        });
      }

      return AuthResult(success: true, user: user);
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, error: _mapFirebaseError(e.code));
    } catch (e) {
      return AuthResult(success: false, error: 'Something went wrong. Please try again.');
    }
  }

  // ─── Login with email & password ─────────────────────────────────────────────
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user!;

      // Update lastLogin timestamp
      await _db.collection('users').doc(user.uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });

      // Fetch role from Firestore
      final doc = await _db.collection('users').doc(user.uid).get();
      final role = doc.data()?['role'] ?? 'buyer';

      return AuthResult(success: true, user: user, role: role);
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, error: _mapFirebaseError(e.code));
    } catch (e) {
      return AuthResult(success: false, error: 'Something went wrong. Please try again.');
    }
  }

  // ─── Forgot password ──────────────────────────────────────────────────────────
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return AuthResult(success: true);
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, error: _mapFirebaseError(e.code));
    }
  }

  // ─── Sign out ─────────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ─── Get user role from Firestore ─────────────────────────────────────────────
  Future<String> getUserRole(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      return doc.data()?['role'] ?? 'buyer';
    } catch (_) {
      return 'buyer';
    }
  }

  // ─── Get full user profile ───────────────────────────────────────────────────
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      return doc.data();
    } catch (_) {
      return null;
    }
  }

  // ─── Map Firebase error codes to readable messages ──────────────────────────
  String _mapFirebaseError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}

// ─── Result wrapper ───────────────────────────────────────────────────────────
class AuthResult {
  final bool success;
  final User? user;
  final String? error;
  final String? role;

  AuthResult({
    required this.success,
    this.user,
    this.error,
    this.role,
  });
}