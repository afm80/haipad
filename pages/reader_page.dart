import 'package:flutter/material.dart';
import '../data.dart';
import '../theme.dart';
import '../widgets.dart';

class ReaderPage extends StatelessWidget {
  ReaderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = app.current;
    final w = MediaQuery.of(context).size.width;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 896),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _header(s, w),
            const SizedBox(height: 24),
            _box(context, s, w),
          ],
        ),
      ),
    );
  }

  Widget _stat(IconData icon, Color c, String text) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 14, color: c),
      const SizedBox(width: 4),
      Text(text, style: cairo(12, weight: FontWeight.w700, color: AppColors.slate600)),
    ]);
  }

  Widget _header(Story s, double w) {
    final wide = w >= 640;
    final align = wide ? CrossAxisAlignment.start : CrossAxisAlignment.center;
    final ta = wide ? TextAlign.start : TextAlign.center;
    final cover = ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(width: 128, height: 176, child: netImage(s.cover)),
    );
    final details = Column(
      crossAxisAlignment: align,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
              color: AppColors.brand100, borderRadius: BorderRadius.circular(999)),
          child: Text(s.genre,
              style: cairo(12, weight: FontWeight.w700, color: AppColors.brand600)),
        ),
        const SizedBox(height: 12),
        Text(s.title,
            textAlign: ta,
            style: cairo(30, weight: FontWeight.w800, color: AppColors.slate900)),
        const SizedBox(height: 12),
        Text.rich(
          TextSpan(children: [
            const TextSpan(text: 'الكاتب: '),
            TextSpan(text: s.author, style: const TextStyle(color: AppColors.brand500)),
            TextSpan(text: ' (${s.authorHandle})'),
          ]),
          textAlign: ta,
          style: cairo(14, weight: FontWeight.w700, color: AppColors.slate600),
        ),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 672),
          child: Text(s.desc,
              textAlign: ta,
              style: cairo(12, color: AppColors.slate500, height: 1.625)),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 24,
          runSpacing: 8,
          alignment: wide ? WrapAlignment.start : WrapAlignment.center,
          children: [
            _stat(Icons.visibility, AppColors.brand500, '${fmt(s.reads)} قراءة'),
            _stat(Icons.favorite, AppColors.red500, '${s.votes} إعجاب'),
            _stat(Icons.format_list_numbered, AppColors.blue500, '${s.chapters.length} فصول'),
          ],
        ),
      ],
    );
    return Container(
      padding: EdgeInsets.all(wide ? 32 : 24),
      decoration: cardBox(),
      child: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [cover, const SizedBox(width: 24), Expanded(child: details)],
            )
          : Column(children: [cover, const SizedBox(height: 24), details]),
    );
  }

  Widget _themeDot(String t, Color fill, Color border) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 8),
      child: InkWell(
        onTap: () => app.setReaderTheme(t),
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: fill,
            shape: BoxShape.circle,
            border: Border.all(color: border),
          ),
        ),
      ),
    );
  }

  Widget _fontBtn(String t, double d) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 12),
      child: Material(
        color: AppColors.slate100,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => app.adjustFont(d),
          child: SizedBox(
            width: 28,
            height: 28,
            child: Center(
              child: Text(t,
                  style: cairo(12, weight: FontWeight.w700, color: AppColors.slate600)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _box(BuildContext context, Story s, double w) {
    final wide = w >= 640;
    final dark = app.readerTheme == 'dark';
    final sepia = app.readerTheme == 'sepia';
    final bg = dark ? const Color(0xFF121212) : (sepia ? const Color(0xFFFBF0D9) : Colors.white);
    final fg = dark
        ? const Color(0xFFE2E8F0)
        : (sepia ? const Color(0xFF433422) : AppColors.slate800);
    final idx = app.chapterIndex.clamp(0, s.chapters.length - 1).toInt();
    final ch = s.chapters[idx];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.all(wide ? 40 : 24),
      decoration: cardBox().copyWith(color: bg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // شريط الأدوات
          Container(
            padding: const EdgeInsets.only(bottom: 16),
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.slate100))),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: 16,
              spacing: 16,
              children: [
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('مظهر القراءة:',
                      style: cairo(12, weight: FontWeight.w700, color: fg)),
                  _themeDot('light', Colors.white, AppColors.slate300),
                  _themeDot('sepia', const Color(0xFFFBF0D9), AppColors.amber300),
                  _themeDot('dark', AppColors.slate900, AppColors.slate700),
                ]),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('حجم الخط:',
                      style: cairo(12, weight: FontWeight.w700, color: AppColors.slate400)),
                  _fontBtn('A-', -2),
                  _fontBtn('A+', 2),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // عنوان الفصل
          Container(
            padding: const EdgeInsets.only(bottom: 12),
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.slate100))),
            child: Row(
              children: [
                Expanded(
                  child: Text(ch.title,
                      style: cairo(20,
                          weight: FontWeight.w700,
                          color: (dark || sepia) ? fg : AppColors.slate900)),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.slate100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.slate200),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: idx,
                      isDense: true,
                      style: cairo(12, weight: FontWeight.w700, color: AppColors.slate800),
                      dropdownColor: Colors.white,
                      items: [
                        for (var i = 0; i < s.chapters.length; i++)
                          DropdownMenuItem(
                              value: i,
                              child: Text(s.chapters[i].title,
                                  style: cairo(12,
                                      weight: FontWeight.w700, color: AppColors.slate800))),
                      ],
                      onChanged: (v) => app.setChapter(v ?? 0),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(ch.content, style: tajawal(app.fontSize, color: fg, height: 1.625)),
          const SizedBox(height: 24),
          // التصويت والمكتبة
          Container(
            padding: const EdgeInsets.only(top: 24),
            decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.slate100))),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              runSpacing: 16,
              spacing: 16,
              children: [
                Material(
                  color: AppColors.red50,
                  shape: const StadiumBorder(side: BorderSide(color: AppColors.red200)),
                  child: InkWell(
                    customBorder: const StadiumBorder(),
                    onTap: app.vote,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.favorite, size: 16, color: AppColors.red600),
                        const SizedBox(width: 8),
                        Text('تصويت وإعجاب (${s.votes})',
                            style: cairo(14, weight: FontWeight.w700, color: AppColors.red600)),
                      ]),
                    ),
                  ),
                ),
                Material(
                  color: AppColors.slate100,
                  shape: const StadiumBorder(),
                  child: InkWell(
                    customBorder: const StadiumBorder(),
                    onTap: () {
                      final added = app.toggleLibrary();
                      showAlert(
                          context,
                          added
                              ? 'تمت إضافة القصة إلى مكتبتك الشخصية بنجاح!'
                              : 'تمت إزالة القصة من مكتبتك.');
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.bookmark, size: 16, color: AppColors.slate700),
                        const SizedBox(width: 8),
                        Text('حفظ بالمكتبة',
                            style: cairo(14, weight: FontWeight.w700, color: AppColors.slate700)),
                      ]),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // التعليقات
          Container(
            padding: const EdgeInsets.only(top: 32),
            decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.slate100))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(children: [
                  const Icon(Icons.forum, size: 20, color: AppColors.brand500),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text('التعليقات والمناقشات حول هذا الفصل',
                        style: cairo(20,
                            weight: FontWeight.w700,
                            color: (dark || sepia) ? fg : AppColors.slate900)),
                  ),
                ]),
                const SizedBox(height: 16),
                const CommentInput(),
                const SizedBox(height: 16),
                if (s.comments.isEmpty)
                  Text('لا توجد تعليقات بعد. كن أول المعلقين!',
                      style: cairo(12, color: AppColors.slate400)),
                for (final c in s.comments) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.slate50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.slate200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipOval(
                            child: SizedBox(width: 32, height: 32, child: netImage(c.avatar))),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.user,
                                  style: cairo(12,
                                      weight: FontWeight.w700, color: AppColors.slate900)),
                              const SizedBox(height: 4),
                              Text(c.text, style: cairo(12, color: AppColors.slate700)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CommentInput extends StatefulWidget {
  const CommentInput({super.key});

  @override
  State<CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<CommentInput> {
  final _c = TextEditingController();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _post() {
    final t = _c.text.trim();
    if (t.isEmpty) return;
    app.addComment(t);
    _c.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipOval(child: SizedBox(width: 40, height: 40, child: netImage(app.userAvatar))),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _c,
                maxLines: 2,
                style: cairo(14),
                decoration:
                    fieldDeco('اكتب تعليقك أو رأيك بالفقرة الأخيرة...', radius: 16),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Material(
                  color: AppColors.brand500,
                  borderRadius: BorderRadius.circular(12),
                  elevation: 2,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _post,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Text('نشر التعليق',
                          style: cairo(12, weight: FontWeight.w700, color: Colors.white)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
