import 'dart:math';
import 'package:flutter/material.dart';
import 'data.dart';
import 'theme.dart';

Future<void> showAlert(BuildContext context, String msg) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Text(msg, style: cairo(14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('حسناً',
                style: cairo(14, weight: FontWeight.w700, color: AppColors.brand500)),
          ),
        ],
      ),
    ),
  );
}

InputDecoration fieldDeco(String hint, {double radius = 12}) {
  return InputDecoration(
    isDense: true,
    filled: true,
    fillColor: AppColors.slate50,
    hintText: hint,
    hintStyle: cairo(14, color: AppColors.slate400),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: const BorderSide(color: AppColors.slate200),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: const BorderSide(color: AppColors.brand500, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: const BorderSide(color: AppColors.red500),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: const BorderSide(color: AppColors.red500, width: 2),
    ),
  );
}

// ───────────── عنوان الصفحة ─────────────
class PageHeading extends StatelessWidget {
  final String title, subtitle;
  final Widget? trailing;
  const PageHeading(this.title, this.subtitle, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.slate200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: cairo(30, weight: FontWeight.w800, color: AppColors.slate900)),
                const SizedBox(height: 4),
                Text(subtitle, style: cairo(14, color: AppColors.slate500)),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 12), trailing!],
        ],
      ),
    );
  }
}

// ───────────── الشريط العلوي ─────────────
class AppHeader extends StatelessWidget {
  AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final px = pagePadding(w);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        border: const Border(bottom: BorderSide(color: AppColors.slate200)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 2,
              offset: const Offset(0, 1)),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: px),
            child: Row(
              children: [
                InkWell(
                  onTap: () => app.go('home'),
                  child: const _Logo(),
                ),
                if (w >= 1100) ...[
                  const SizedBox(width: 24),
                  _nav(),
                ],
                const SizedBox(width: 16),
                if (w >= 640)
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 448),
                        child: TextField(
                          onChanged: app.setSearch,
                          style: cairo(14),
                          decoration: fieldDeco('ابحث عن قصة، كاتب، أو تصنيف...', radius: 999)
                              .copyWith(
                            fillColor: AppColors.slate100,
                            prefixIcon: const Icon(Icons.search,
                                size: 18, color: AppColors.slate400),
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  const Spacer(),
                const SizedBox(width: 16),
                _writeButton(context, w >= 640),
                const SizedBox(width: 12),
                _auth(w >= 640),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(String label, String page, {bool dot = false}) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => app.go(page),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: cairo(14, weight: FontWeight.w700, color: AppColors.slate700)),
            if (dot) ...[
              const SizedBox(width: 6),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                    color: AppColors.brand500, shape: BoxShape.circle),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _nav() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _navItem('الرئيسية', 'home'),
        const SizedBox(width: 4),
        _navItem('استكشف التصنيفات', 'explore'),
        const SizedBox(width: 4),
        _navItem('مكتبتي', 'library'),
        const SizedBox(width: 4),
        _navItem('المحادثات', 'chats', dot: true),
      ],
    );
  }

  Widget _writeButton(BuildContext context, bool showText) {
    return Material(
      color: AppColors.brand500,
      shape: const StadiumBorder(),
      elevation: 3,
      shadowColor: AppColors.brand500.withOpacity(0.4),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: () => showWriteDialog(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.edit, size: 14, color: Colors.white),
              if (showText) ...[
                const SizedBox(width: 8),
                Text('اكتب قصة',
                    style: cairo(14, weight: FontWeight.w700, color: Colors.white)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _auth(bool showName) {
    return InkWell(
      onTap: () => app.go('profile'),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.brand500, width: 2),
            ),
            child: ClipOval(child: netImage(app.userAvatar)),
          ),
          if (showName) ...[
            const SizedBox(width: 8),
            Text(app.userName, style: cairo(12, weight: FontWeight.w700)),
          ],
        ],
      ),
    );
  }
}

Widget netImage(String url, {BoxFit fit = BoxFit.cover}) {
  return Image.network(
    url,
    fit: fit,
    width: double.infinity,
    height: double.infinity,
    errorBuilder: (_, __, ___) => Container(color: AppColors.slate100),
  );
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: [AppColors.brand600, AppColors.amber500],
            ),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 6,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: Text('ح',
              style: cairo(20, weight: FontWeight.w800, color: Colors.white)),
        ),
        const SizedBox(width: 8),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('haipad',
                style: cairo(24,
                    weight: FontWeight.w800, color: AppColors.slate900, height: 1.1)),
            Text('منصة القصص العربية',
                style: cairo(10,
                    weight: FontWeight.w600, color: AppColors.slate400, height: 1.2)),
          ],
        ),
      ],
    );
  }
}

// ───────────── شريط الجوال السفلي ─────────────
class MobileBar extends StatelessWidget {
  MobileBar({super.key});

  Widget _item(IconData icon, String label, String page) {
    return InkWell(
      onTap: () => app.go(page),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.slate600),
          const SizedBox(height: 4),
          Text(label,
              style: cairo(12, weight: FontWeight.w700, color: AppColors.slate600)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: AppColors.slate200)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _item(Icons.home, 'الرئيسية', 'home'),
            _item(Icons.explore, 'استكشف', 'explore'),
            _item(Icons.bookmarks, 'مكتبتي', 'library'),
            _item(Icons.forum, 'المحادثات', 'chats'),
            _item(Icons.person, 'حسابي', 'profile'),
          ],
        ),
      ),
    );
  }
}

// ───────────── بطاقة القصة وشبكة القصص ─────────────
class StoryCard extends StatelessWidget {
  final Story story;
  const StoryCard({super.key, required this.story});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 0.5,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => app.openStory(story.id),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.slate200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 3 / 4,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(color: AppColors.slate100),
                    netImage(story.cover),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.slate900.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(story.genre,
                            style: cairo(10, weight: FontWeight.w700, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(story.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: cairo(14,
                                  weight: FontWeight.w700, color: AppColors.slate900)),
                          const SizedBox(height: 2),
                          Text('بقلم: ${story.author}',
                              style: cairo(12,
                                  weight: FontWeight.w600, color: AppColors.slate500)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 8),
                        decoration: const BoxDecoration(
                          border: Border(top: BorderSide(color: AppColors.slate100)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(children: [
                              const Icon(Icons.visibility,
                                  size: 12, color: AppColors.slate400),
                              const SizedBox(width: 4),
                              Text(fmt(story.reads),
                                  style: cairo(11,
                                      weight: FontWeight.w700, color: AppColors.slate400)),
                            ]),
                            Row(children: [
                              const Icon(Icons.favorite, size: 12, color: AppColors.red500),
                              const SizedBox(width: 4),
                              Text('${story.votes}',
                                  style: cairo(11,
                                      weight: FontWeight.w700, color: AppColors.slate400)),
                            ]),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StoriesGrid extends StatelessWidget {
  final List<Story> stories;
  final int maxCols;
  final String emptyText;
  const StoriesGrid(
      {super.key, required this.stories, this.maxCols = 5, this.emptyText = ''});

  @override
  Widget build(BuildContext context) {
    if (stories.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(emptyText, style: cairo(14, color: AppColors.slate400)),
      );
    }
    return LayoutBuilder(builder: (context, c) {
      final w = MediaQuery.of(context).size.width;
      final cols = min(maxCols, w >= 1024 ? 5 : (w >= 768 ? 4 : (w >= 640 ? 3 : 2)));
      const gap = 16.0;
      final cardW = (c.maxWidth - gap * (cols - 1)) / cols;
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: stories.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          crossAxisSpacing: gap,
          mainAxisSpacing: gap,
          mainAxisExtent: cardW * 4 / 3 + 100,
        ),
        itemBuilder: (_, i) => StoryCard(story: stories[i]),
      );
    });
  }
}

// ───────────── نافذة كتابة قصة ─────────────
Future<void> showWriteDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (_) => WriteStoryDialog(parentContext: context),
  );
}

class WriteStoryDialog extends StatefulWidget {
  final BuildContext parentContext;
  const WriteStoryDialog({super.key, required this.parentContext});

  @override
  State<WriteStoryDialog> createState() => _WriteStoryDialogState();
}

class _WriteStoryDialogState extends State<WriteStoryDialog> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _cover = TextEditingController();
  final _desc = TextEditingController();
  final _chapter = TextEditingController();
  String _genre = allGenres.first;

  static const _covers = [
    'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?auto=format&fit=crop&q=80&w=400',
    'https://images.unsplash.com/photo-1543002588-bfa74002ed7e?auto=format&fit=crop&q=80&w=400',
    'https://images.unsplash.com/photo-1512820790803-83ca734da794?auto=format&fit=crop&q=80&w=400',
  ];

  @override
  void dispose() {
    _title.dispose();
    _cover.dispose();
    _desc.dispose();
    _chapter.dispose();
    super.dispose();
  }

  String? _req(String? v) => (v == null || v.trim().isEmpty) ? 'هذا الحقل مطلوب' : null;

  void _save() {
    if (!_form.currentState!.validate()) return;
    app.createStory(_title.text.trim(), _genre, _cover.text.trim(), _desc.text.trim(),
        _chapter.text.trim());
    final ctx = widget.parentContext;
    Navigator.pop(context);
    if (ctx.mounted) showAlert(ctx, 'تم نشر قصتك الجديدة بنجاح على المنصة!');
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(t, style: cairo(12, weight: FontWeight.w700, color: AppColors.slate700)),
      );

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 672),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(w >= 640 ? 32 : 24),
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.only(bottom: 12),
                    decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: AppColors.slate100))),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('إنشاء قصة جديدة',
                                  style: cairo(24,
                                      weight: FontWeight.w800, color: AppColors.slate900)),
                              const SizedBox(height: 4),
                              Text('أدخل معلومات القصة ثم أضف فصلك الأول.',
                                  style: cairo(12, color: AppColors.slate500)),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.close, size: 22, color: AppColors.slate400),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _label('عنوان القصة *'),
                  TextFormField(
                    controller: _title,
                    validator: _req,
                    style: cairo(14),
                    decoration: fieldDeco('مثال: سر القلعة المفقودة'),
                  ),
                  const SizedBox(height: 16),
                  _label('تصنيف القصة (من بين 23 قسم) *'),
                  DropdownButtonFormField<String>(
                    value: _genre,
                    isExpanded: true,
                    style: cairo(14),
                    decoration: fieldDeco(''),
                    items: allGenres
                        .map((g) => DropdownMenuItem(value: g, child: Text(g, style: cairo(14))))
                        .toList(),
                    onChanged: (v) => setState(() => _genre = v ?? _genre),
                  ),
                  const SizedBox(height: 16),
                  _label('صورة الغلاف (رابط الصورة أو اختر جهازك)'),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _cover,
                          keyboardType: TextInputType.url,
                          style: cairo(14),
                          decoration: fieldDeco('https://images.unsplash.com/...'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Material(
                        color: AppColors.slate100,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => setState(
                              () => _cover.text = _covers[Random().nextInt(_covers.length)]),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            child: Text('غلاف عشوائي',
                                style: cairo(12,
                                    weight: FontWeight.w700, color: AppColors.slate700)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _label('الملخص / وصف القصة *'),
                  TextFormField(
                    controller: _desc,
                    validator: _req,
                    maxLines: 3,
                    style: cairo(14),
                    decoration: fieldDeco('نبذة مختصرة مشوقة تجذب القراء...'),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.only(top: 16),
                    decoration: const BoxDecoration(
                        border: Border(top: BorderSide(color: AppColors.slate100))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _label('محتوى الفصل الأول *'),
                        TextFormField(
                          controller: _chapter,
                          validator: _req,
                          maxLines: 6,
                          style: tajawal(14, height: 1.625),
                          decoration: fieldDeco('اكتب أحداث الفصل الأول هنا...'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('إلغاء',
                            style: cairo(14, weight: FontWeight.w700, color: AppColors.slate600)),
                      ),
                      const SizedBox(width: 12),
                      Material(
                        color: AppColors.brand500,
                        borderRadius: BorderRadius.circular(12),
                        elevation: 2,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: _save,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            child: Text('نشر القصة فوراً',
                                style: cairo(14, weight: FontWeight.w700, color: Colors.white)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
