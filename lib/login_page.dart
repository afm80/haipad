import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'theme.dart';
import 'widgets.dart';

/// فعّل هذا الخيار فقط بعد إعداد تسجيل الدخول بـ Facebook في Firebase.
const bool kEnableFacebook = false;

const _ink = Color(0xFF222222);

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _signUp = false;
  bool _showEmail = false;
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
        _showEmail = true;
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

  void _toggleMode() {
    setState(() {
      _signUp = !_signUp;
      _error = null;
      _info = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final wide = w >= 1240;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _BlobPainter())),
            SafeArea(
              child: Column(
                children: [
                  _topBar(),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: wide
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const _Showcase(),
                                  const SizedBox(width: 60),
                                  _card(),
                                ],
                              )
                            : _card(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: [
          const _Logo(),
          const Spacer(),
          TextButton(
            onPressed: _toggleMode,
            child: Text(_signUp ? 'تسجيل الدخول' : 'التسجيل',
                style: cairo(14, weight: FontWeight.w700, color: _ink)),
          ),
        ],
      ),
    );
  }

  Widget _card() {
    return Container(
      width: 500,
      constraints: const BoxConstraints(maxWidth: 500),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(48, 56, 48, 40),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 24,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(_signUp ? 'إنشاء حساب في Haipad' : 'تسجيل الدخول إلى Haipad',
              textAlign: TextAlign.center,
              style: cairo(26, weight: FontWeight.w800, color: _ink)),
          const SizedBox(height: 36),
          _outlined(
            label: _signUp ? 'التسجيل بواسطة Google' : 'تسجيل الدخول بواسطة Google',
            icon: const _GoogleG(),
            onTap: () => _run(AuthService.signInWithGoogle),
          ),
          if (kEnableFacebook) ...[
            const SizedBox(height: 16),
            _outlined(
              label: _signUp
                  ? 'التسجيل بواسطة Facebook'
                  : 'تسجيل الدخول بواسطة Facebook',
              icon: Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: const Color(0xFF1877F2),
                    borderRadius: BorderRadius.circular(4)),
                child: Text('f',
                    style: cairo(16, weight: FontWeight.w900, color: Colors.white, height: 1)),
              ),
              onTap: () => _run(AuthService.signInWithFacebook),
            ),
          ],
          const SizedBox(height: 22),
          Row(children: [
            const Expanded(child: Divider(color: AppColors.slate200)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text('أو', style: cairo(13, color: AppColors.slate500)),
            ),
            const Expanded(child: Divider(color: AppColors.slate200)),
          ]),
          const SizedBox(height: 22),
          if (!_showEmail)
            _darkButton(
              _signUp ? 'التسجيل بالبريد الإلكتروني' : 'تسجيل الدخول بالبريد الإلكتروني',
              () => setState(() => _showEmail = true),
            )
          else
            _emailForm(),
          if (_error != null) ...[
            const SizedBox(height: 14),
            _notice(_error!, AppColors.red50, AppColors.red200, AppColors.red600),
          ],
          if (_info != null) ...[
            const SizedBox(height: 14),
            _notice(_info!, AppColors.brand50, AppColors.orange200, AppColors.brand600),
          ],
          if (!_signUp) ...[
            const SizedBox(height: 22),
            Center(
              child: TextButton(
                onPressed: _busy ? null : _forgot,
                child: Text('نسيت كلمة المرور؟',
                    style: cairo(14, weight: FontWeight.w700, color: _ink)),
              ),
            ),
          ],
          const SizedBox(height: 28),
          Center(
            child: InkWell(
              onTap: _busy ? null : _toggleMode,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Text(
                    _signUp ? 'لديك حساب؟ قم بتسجيل الدخول' : 'ليس لديك حساب؟ قم بالتسجيل',
                    style: cairo(14, weight: FontWeight.w700, color: _ink)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emailForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_signUp) ...[
          TextField(
            controller: _name,
            enabled: !_busy,
            style: cairo(14),
            decoration: fieldDeco('الاسم', radius: 999),
          ),
          const SizedBox(height: 12),
        ],
        TextField(
          controller: _email,
          enabled: !_busy,
          keyboardType: TextInputType.emailAddress,
          textDirection: TextDirection.ltr,
          style: cairo(14),
          decoration: fieldDeco('البريد الإلكتروني', radius: 999),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _pass,
          enabled: !_busy,
          obscureText: _hidePass,
          textDirection: TextDirection.ltr,
          style: cairo(14),
          onSubmitted: (_) => _submitEmail(),
          decoration: fieldDeco('كلمة المرور', radius: 999).copyWith(
            suffixIcon: IconButton(
              onPressed: () => setState(() => _hidePass = !_hidePass),
              icon: Icon(_hidePass ? Icons.visibility_off : Icons.visibility,
                  size: 18, color: AppColors.slate400),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _darkButton(_signUp ? 'إنشاء الحساب' : 'تسجيل الدخول', _submitEmail),
      ],
    );
  }

  Widget _darkButton(String label, VoidCallback onTap) {
    return SizedBox(
      height: 60,
      child: ElevatedButton(
        onPressed: _busy ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: _ink,
          disabledBackgroundColor: _ink.withOpacity(0.6),
          foregroundColor: Colors.white,
          shape: const StadiumBorder(),
          elevation: 0,
        ),
        child: _busy && _showEmail
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(label, style: cairo(15, weight: FontWeight.w700, color: Colors.white)),
      ),
    );
  }

  Widget _outlined(
      {required String label, required Widget icon, required VoidCallback onTap}) {
    return SizedBox(
      height: 60,
      child: OutlinedButton(
        onPressed: _busy ? null : onTap,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: _ink, width: 2),
          shape: const StadiumBorder(),
          foregroundColor: _ink,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: cairo(15, weight: FontWeight.w700, color: _ink)),
            const SizedBox(width: 10),
            icon,
          ],
        ),
      ),
    );
  }

  Widget _notice(String text, Color bg, Color border, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Text(text, style: cairo(12, weight: FontWeight.w600, color: fg, height: 1.5)),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        brandName(30, height: 1),
        const SizedBox(width: 8),
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
              color: AppColors.brand500, borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.auto_stories, color: Colors.white, size: 20),
        ),
      ],
    );
  }
}

class _GoogleG extends StatelessWidget {
  const _GoogleG();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (r) => const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4285F4), Color(0xFFEA4335), Color(0xFFFBBC05), Color(0xFF34A853)],
          stops: [0.0, 0.35, 0.65, 1.0],
        ).createShader(r),
        child: Center(
          child: Text('G',
              style: cairo(20, weight: FontWeight.w900, color: Colors.white, height: 1)),
        ),
      ),
    );
  }
}

/// الأشكال البرتقالية على جانبي الصفحة.
class _BlobPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = AppColors.brand500;
    final w = size.width, h = size.height;
    final narrow = w < 700;
    final k = narrow ? 0.45 : 1.0;

    // الجانب الأيسر: أوراق في الأعلى
    for (final c in [
      [10.0, 60.0, 150.0],
      [-10.0, 210.0, 150.0],
      [40.0, 330.0, 95.0],
      [70.0, 120.0, 110.0],
    ]) {
      canvas.drawCircle(Offset(c[0] * k, c[1] * k), c[2] * k, p);
    }

    // الجانب الأيمن: شريط بأوراق على كامل الارتفاع
    final step = 200.0 * k;
    var y = 0.0;
    var i = 0;
    while (y < h + step) {
      final r = (i.isEven ? 140.0 : 115.0) * k;
      canvas.drawCircle(Offset(w + 10 * k, y), r, p);
      y += step * 0.78;
      i++;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// رسم الكمبيوتر والهاتف (محتوى Haipad الخاص).
class _Showcase extends StatelessWidget {
  const _Showcase();

  static const _covers = [
    [Color(0xFF7C3AED), Color(0xFFEC4899)],
    [Color(0xFFF59E0B), Color(0xFFEF4444)],
    [Color(0xFF0EA5E9), Color(0xFF1E3A8A)],
    [Color(0xFF10B981), Color(0xFF065F46)],
    [Color(0xFF111827), Color(0xFF6B7280)],
  ];

  Widget _cover(List<Color> c, double w, double h) => Container(
        width: w,
        height: h,
        margin: const EdgeInsets.only(left: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: c),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 600,
      height: 460,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // الكمبيوتر
          Positioned(
            right: 0,
            top: 20,
            child: Column(
              children: [
                Container(
                  width: 520,
                  height: 330,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F1F1F),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 26,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(color: AppColors.slate200))),
                          child: Row(children: [
                            brandName(11),
                            const SizedBox(width: 12),
                            Text('تصفّح', style: cairo(8, color: AppColors.slate500)),
                            const SizedBox(width: 8),
                            Text('المجتمع', style: cairo(8, color: AppColors.slate500)),
                          ]),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                          child: Container(
                            height: 96,
                            alignment: AlignmentDirectional.centerStart,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              gradient: const LinearGradient(
                                  colors: [AppColors.brand500, AppColors.amber500]),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('قصص جديدة',
                                    style: cairo(18, weight: FontWeight.w800, color: Colors.white)),
                                Text('اكتشف حكايات لم يقرأها أحد بعد',
                                    style: cairo(9, color: Colors.white)),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
                          child: Text('أهلاً بك في Haipad!',
                              style: cairo(11, weight: FontWeight.w800, color: _ink)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Row(
                            children: [for (final c in _covers) _cover(c, 70, 100)],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 600,
                  height: 14,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D5DB),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 4)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // الهاتف
          Positioned(
            left: 10,
            top: 150,
            child: Container(
              width: 170,
              height: 300,
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: const Color(0xFF1F1F1F),
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 8)),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 86,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: const LinearGradient(colors: [
                            Color(0xFF7C3AED),
                            Color(0xFFEC4899),
                          ]),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text('الفصل الأول',
                          style: cairo(11, weight: FontWeight.w800, color: _ink)),
                      const SizedBox(height: 6),
                      for (var i = 0; i < 6; i++)
                        Container(
                          height: 5,
                          margin: const EdgeInsets.only(bottom: 6),
                          width: i == 5 ? 60 : double.infinity,
                          decoration: BoxDecoration(
                              color: AppColors.slate200,
                              borderRadius: BorderRadius.circular(3)),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
