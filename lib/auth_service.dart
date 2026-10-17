import 'package:firebase_auth/firebase_auth.dart';
import 'data.dart';

/// طبقة بسيطة فوق Firebase Auth: Google + البريد وكلمة المرور.
class AuthService {
  static FirebaseAuth get _auth => FirebaseAuth.instance;

  static User? get user => _auth.currentUser;

  static Stream<User?> get changes => _auth.authStateChanges();

  /// ينسخ بيانات المستخدم الحقيقي إلى حالة التطبيق (الاسم والصورة).
  static void syncProfile(User? u) {
    if (u == null) return;
    final name = (u.displayName != null && u.displayName!.trim().isNotEmpty)
        ? u.displayName!.trim()
        : (u.email ?? 'مستخدم').split('@').first;
    app.setUser(name: name, avatar: u.photoURL);
  }

  static Future<void> signInWithGoogle() async {
    final provider = GoogleAuthProvider()..setCustomParameters({'prompt': 'select_account'});
    final cred = await _auth.signInWithPopup(provider);
    syncProfile(cred.user);
  }

  static Future<void> signInWithEmail(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(), password: password);
    syncProfile(cred.user);
  }

  static Future<void> signUpWithEmail(
      String name, String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(), password: password);
    await cred.user?.updateDisplayName(name.trim());
    await cred.user?.reload();
    syncProfile(_auth.currentUser);
  }

  static Future<void> resetPassword(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  static Future<void> signOut() => _auth.signOut();

  /// رسائل خطأ عربية مفهومة.
  static String errorText(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-email':
          return 'البريد الإلكتروني غير صحيح.';
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'البريد أو كلمة المرور غير صحيحة.';
        case 'email-already-in-use':
          return 'هذا البريد مسجّل مسبقاً، جرّب تسجيل الدخول.';
        case 'weak-password':
          return 'كلمة المرور ضعيفة، استخدم 6 أحرف على الأقل.';
        case 'too-many-requests':
          return 'محاولات كثيرة، حاول مرة أخرى بعد قليل.';
        case 'popup-closed-by-user':
        case 'cancelled-popup-request':
          return '';
        case 'popup-blocked':
          return 'المتصفح منع النافذة المنبثقة، اسمح بها وحاول مجدداً.';
        case 'unauthorized-domain':
          return 'هذا النطاق غير مصرّح به في إعدادات Firebase.';
        case 'operation-not-allowed':
          return 'هذه الطريقة غير مفعّلة في Firebase Authentication.';
        case 'network-request-failed':
          return 'تعذّر الاتصال بالإنترنت.';
      }
    }
    return 'حدث خطأ غير متوقع، حاول مرة أخرى.';
  }
}
