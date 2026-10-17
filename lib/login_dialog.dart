import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'theme.dart';
import 'widgets.dart';

/// نافذة تسجيل الدخول / إنشاء الحساب (بتصميم مشابه لنوافذ المنصات الشهيرة).
Future<void> showLoginDialog(BuildContext context, {bool signUp = false}) {
  return showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.55),
    builder: (_) => Directionality(
      textDirection: TextDirection.rtl,
      child: LoginDialog(startAsSignUp: signUp),
    ),
  );
}

class LoginDialog extends StatefulWidget {
  final bool startAsSignUp;
  const LoginDialog({super.key, this.startAsSignUp = false});

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  late bool _signUp = widget.startAsSignUp;
  bool _useEmail = false;
  bool _busy = false;
  bool _hidePass = true;
  String? _error;
  String? _info;

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
      _info = null;
    });
    try {
      await action();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      final msg = AuthService.errorText(e);
      if (mounted) setState(() => _error = msg.isEmpty ? null : msg);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _submitEmail() {
    if (_email.text.trim().isEmpty || _pass.text.isEmpty) {
      setState(() => _error = 'اكتب البريد وكلمة المرور.');
      return;
    }
    if (_signUp && _name.text.trim().isEmpty) {
      setState(() => _error = 'اكتب اسمك.');
      return;
    }
    _run(() => _signUp
        ? AuthService.signUpWithEmail(_name.text, _email.text, _pass.text)
        : AuthService.signInWithEmail(_email.text, _pass.text));
  }

  Future<void> _forgot() async {
    if (_email.text.trim().isEmpty) {
      setState(() {
        _error = 'اكتب بريدك أولاً ثم اضغط "نسيت كلمة المرور".';
        _info = null;
      });
      return;
    }
    try {
      await AuthService.resetPassword(_email.text);
      if (mounted) {
        setState(() {
          _error = null;
          _info = 'أرسلنا رابط إعادة تعيين كلمة المرور إلى بريدك.';
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = AuthService.errorText(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final wide = w >= 760;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: wide ? 860 : 440),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Container(
            color: Colors.white,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _formSide()),
                  if (wide) SizedBox(width: 340, child: _brandSide()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // الجانب البرتقالي (الشعار والعبارة)
  Widget _brandSide() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppColors.brand500, AppColors.brand600],
        ),
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_stories, color: Colors.white, size: 44),
          const SizedBox(height: 16),
          Text('haipad',
              style: cairo(34, weight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 12),
          Text('اكتب قصتك، واقرأ قصص الآلاف.\nمجتمعك من القرّاء والكتّاب بانتظارك.',
              style: cairo(15,
                  weight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.95),
                  height: 1.7)),
        ],
      ),
    );
  }

  Widget _formSide() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: AppColors.slate400),
                tooltip: 'إغلاق',
              ),
            ),
            Text(_signUp ? 'أنشئ حسابك' : 'تسجيل الدخول',
                textAlign: TextAlign.center,
                style: cairo(26, weight: FontWeight.w800, color: AppColors.slate900)),
            const SizedBox(height: 6),
            Text(
                _signUp
                    ? 'انضم إلى haipad وابدأ الكتابة والقراءة'
                    : 'مرحباً بعودتك إلى haipad',
                textAlign: TextAlign.center,
                style: cairo(13, color: AppColors.slate500)),
            const SizedBox(height: 22),
            if (!_useEmail) ...[
              _socialButton(
                label: 'المتابعة باستخدام Google',
                leading: Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.slate200),
                  ),
                  child: Text('G',
                      style: cairo(13, weight: FontWeight.w800, color: AppColors.blue500)),
                ),
                onTap: () => _run(AuthService.signInWithGoogle),
              ),
              const SizedBox(height: 12),
              _socialButton(
                label: 'المتابعة باستخدام البريد الإلكتروني',
                leading: const Icon(Icons.mail_outline,
                    size: 20, color: AppColors.slate600),
                onTap: () => setState(() {
                  _useEmail = true;
                  _error = null;
                }),
              ),
            ] else ...[
              if (_signUp) ...[
                TextField(
                  controller: _name,
                  enabled: !_busy,
                  style: cairo(14),
                  decoration: fieldDeco('الاسم'),
                ),
                const SizedBox(height: 12),
              ],
              TextField(
                controller: _email,
                enabled: !_busy,
                keyboardType: TextInputType.emailAddress,
                textDirection: TextDirection.ltr,
                style: cairo(14),
                decoration: fieldDeco('البريد الإلكتروني'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _pass,
                enabled: !_busy,
                obscureText: _hidePass,
                textDirection: TextDirection.ltr,
                style: cairo(14),
                onSubmitted: (_) => _submitEmail(),
                decoration: fieldDeco('كلمة المرور').copyWith(
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _hidePass = !_hidePass),
                    icon: Icon(
                        _hidePass ? Icons.visibility_off : Icons.visibility,
                        size: 18,
                        color: AppColors.slate400),
                  ),
                ),
              ),
              if (!_signUp)
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton(
                    onPressed: _busy ? null : _forgot,
                    child: Text('نسيت كلمة المرور؟',
                        style: cairo(12,
                            weight: FontWeight.w700, color: AppColors.brand600)),
                  ),
                )
              else
                const SizedBox(height: 8),
              const SizedBox(height: 4),
              SizedBox(
                height: 46,
                child: ElevatedButton(
                  onPressed: _busy ? null : _submitEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brand500,
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                    elevation: 0,
                  ),
                  child: _busy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text(_signUp ? 'إنشاء الحساب' : 'تسجيل الدخول',
                          style: cairo(15,
                              weight: FontWeight.w800, color: Colors.white)),
                ),
              ),
              TextButton(
                onPressed: () => setState(() {
                  _useEmail = false;
                  _error = null;
                }),
                child: Text('خيارات تسجيل أخرى',
                    style: cairo(12, color: AppColors.slate500)),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 10),
              _notice(_error!, AppColors.red50, AppColors.red200, AppColors.red600),
            ],
            if (_info != null) ...[
              const SizedBox(height: 10),
              _notice(_info!, AppColors.brand50, AppColors.orange200,
                  AppColors.brand600),
            ],
            const SizedBox(height: 18),
            const Divider(color: AppColors.slate200, height: 1),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_signUp ? 'لديك حساب بالفعل؟' : 'ليس لديك حساب؟',
                    style: cairo(13, color: AppColors.slate600)),
                TextButton(
                  onPressed: _busy
                      ? null
                      : () => setState(() {
                            _signUp = !_signUp;
                            _error = null;
                            _info = null;
                          }),
                  child: Text(_signUp ? 'سجّل الدخول' : 'أنشئ حساباً',
                      style: cairo(13,
                          weight: FontWeight.w800, color: AppColors.brand600)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _notice(String text, Color bg, Color border, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Text(text,
          style: cairo(12, weight: FontWeight.w600, color: fg, height: 1.5)),
    );
  }

  Widget _socialButton(
      {required String label, required Widget leading, required VoidCallback onTap}) {
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: _busy ? null : onTap,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.slate300),
          shape: const StadiumBorder(),
          foregroundColor: AppColors.slate800,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(alignment: AlignmentDirectional.centerStart, child: leading),
            _busy && !_useEmail
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : Text(label,
                    style: cairo(14, weight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
