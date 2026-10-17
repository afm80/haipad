import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'data.dart';
import 'repo.dart';

/// طبقة بسيطة فوق Firebase Auth: Google + البريد وكلمة المرور.
class AuthService {
  static FirebaseAuth get _auth => FirebaseAuth.instance;
  static StreamSubscription<User?>? _sub;

  static User? get user => _auth.currentUser;

  static Stream<User?> get changes => _auth.authStateChanges();

  /// يربط حالة الدخول ببيانات التطبيق: ينشئ ملف المستخدم عند أول دخول ثم يبدأ القراءة الحيّة.
  static void init() {
    _sub?.cancel();
    _sub = _auth.authStateChanges().listen((u) async {
      if (u == null) {
        app.stop();
        return;
      }
      try {
        await Repo.ensureUser(u);
        app.start(u.uid);
      } catch (e) {
        app.fail(e);
      }
    });
  }

  static Future<void> signInWithGoogle() async {
    final provider = GoogleAuthProvider()..setCustomParameters({'prompt': 'select_account'});
    await _auth.signInWithPopup(provider);
  }

  static Future<void> signInWithFacebook() async {
    await _auth.signInWithPopup(FacebookAuthProvider());
  }

  static Future<void> signInWithEmail(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
  }

  static Future<void> signUpWithEmail(
      String name, String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(), password: password);
    final u = cred.user;
    if (u == null) return;
    await u.updateDisplayName(name.trim());
    try {
      await Repo.ensureUser(u);
      await Repo.setName(u.uid, name.trim());
    } catch (_) {
      // يُعاد إنشاء الملف تلقائياً عند الدخول التالي.
    }
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
