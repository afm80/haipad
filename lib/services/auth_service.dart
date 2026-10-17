import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      if (googleAuth == null) return null;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        await _db.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'displayName': userCredential.user!.displayName ?? 'مستخدم حكاية',
          'email': userCredential.user!.email,
          'photoURL': userCredential.user!.photoURL ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      return userCredential;
    } catch (e) {
      print("خطأ في تسجيل الدخول: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
