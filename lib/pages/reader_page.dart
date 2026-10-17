import 'package:flutter/material.dart';
import '../data.dart';
import '../dialogs.dart';
import '../repo.dart';
import '../theme.dart';
import '../widgets.dart';

class ReaderPage extends StatelessWidget {
  ReaderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final id = app.readingId;
    if (id == null) return emptyLine('لم يتم اختيار قصة.');
    final w = MediaQuery.of(context).size.width;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 896),
        child: Live<Story?>(
          streamKey: id,
          create: () => Repo.storyStream(id),
          builder: (context, snap) {
            if (snap.hasError) return errorLine('تعذّر تحميل القصة.');
            if (snap.connectionState == ConnectionState.waiting) return loadingBox();
            final s = snap.data;
            if (s == null) return emptyLine('هذه القصة غير موجودة أو تم حذفها.');
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _header(context, s, w),
                const SizedBox(height: 24),
                Live<List<Chapter>>(
                  streamKey: s.id,
                  create: () => Repo.chaptersStream(s.id),
                  builder: (context, cs) {
                    if (cs.hasError) return errorLine('تعذّر تحميل الفصول.');
                    final list = cs.data;
                    if (list == null) return loadingBox();
                    return _box(context, s, list, w);
                  },
                ),
              ],
            );
          },
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

  Widget _badge(String t, Color bg, Color fg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
        child: Text(t, style: cairo(12, weight: FontWeight.w700, color: fg)),
      );

  Widget _header(BuildContext context, Story s, double w) {
    final wide = w >= 640;
    final align = wide ? CrossAxisAlignment.start : CrossAxisAlignment.center;
    final ta = wide ? TextAlign.start : TextAlign.center;
    final wrapAlign = wide ? WrapAlignment.start : WrapAlignment.center;
    final cover = ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(width: 128, height: 176, child: netImage(s.cover)),
    );
    final mine = s.authorId == app.uid;
    final details = Column(
      crossAxisAlignment: align,
      children: [
        Wrap(spacing: 8, runSpacing: 8, alignment: wrapAlign, children: [
          _badge(s.genre, AppColors.brand100, AppColors.brand600),
          _badge(s.completed ? 'مكتملة' : 'مستمرة',
              s.completed ? AppColors.emerald500 : AppColors.slate100,
              s.completed ? Colors.white : AppColors.slate600),
        ]),
        const SizedBox(height: 12),
        Text(s.title,
            textAlign: ta,
            style: cairo(30, weight: FontWeight.w800, color: AppColors.slate900)),
        const SizedBox(height: 12),
        InkWell(
          onTap: () => app.openProfile(s.authorId),
          child: Text.rich(
            TextSpan(children: [
              const TextSpan(text: 'الكاتب: '),
              TextSpan(text: s.author, style: const TextStyle(color: AppColors.brand500)),
              if (s.authorHandle.isNotEmpty) TextSpan(text: ' (${s.authorHandle})'),
            ]),
            textAlign: ta,
            style: cairo(14, weight: FontWeight.w700, color: AppColors.slate600),
          ),
        ),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 672),
          child: Text(s.desc,
              textAlign: ta,
              style: cairo(12, color: AppColors.slate500, height: 1.625)),
        ),
        if (s.tags.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(spacing: 6, runSpacing: 6, alignment: wrapAlign, children: [
            for (final t in s.tags)
              InkWell(
                onTap: () => app.setSearch(t),
                child: _badge('#$t', AppColors.slate100, AppColors.slate600),
              ),
          ]),
        ],
        const SizedBox(height: 20),
        Wrap(
          spacing: 24,
          runSpacing: 8,
          alignment: wrapAlign,
          children: [
            _stat(Icons.visibility, AppColors.brand500, '${fmt(s.reads)} قراءة'),
            _stat(Icons.favorite, AppColors.red500, '${s.votes} إعجاب'),
            _stat(Icons.format_list_numbered, AppColors.blue500, '${s.publishedChapters} فصول'),
          ],
        ),
        if (mine) ...[
          const SizedBox(height: 16),
          Material(
            color: AppColors.slate900,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => showManageDialog(context, s),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text('إدارة القصة',
                    style: cairo(12, weight: FontWeight.w700, color: Colors.white)),
              ),
            ),
          ),
        ],
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

  Widget _pill(String text, IconData icon, Color bg, Color fg, Color border,
      VoidCallback onTap) {
    return Material(
      color: bg,
      shape: StadiumBorder(side: BorderSide(color: border)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 16, color: fg),
            const SizedBox(width: 8),
            Text(text, style: cairo(14, weight: FontWeight.w700, color: fg)),
          ]),
        ),
      ),
    );
  }

  Widget _navBtn(String text, bool enabled, VoidCallback onTap) {
    return Material(
      color: enabled ? AppColors.slate900 : AppColors.slate200,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(text,
              style: cairo(13,
                  weight: FontWeight.w700,
                  color: enabled ? Colors.white : AppColors.slate400)),
        ),
      ),
    );
  }

  Widget _box(BuildContext context, Story s, List<Chapter> chapters, double w) {
    final wide = w >= 640;
    final dark = app.readerTheme == 'dark';
    final sepia = app.readerTheme == 'sepia';
    final bg = dark ? const Color(0xFF121212) : (sepia ? const Color(0xFFFBF0D9) : Colors.white);
    final fg = dark
        ? const Color(0xFFE2E8F0)
        : (sepia ? const Color(0xFF433422) : AppColors.slate800);
    final head = (dark || sepia) ? fg : AppColors.slate900;

    if (chapters.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: cardBox(),
        child: Center(child: emptyLine('لا توجد فصول منشورة في هذه القصة بعد.')),
      );
    }

    final idx = app.chapterIndex.clamp(0, chapters.length - 1).toInt();
    final ch = chapters[idx];

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
                      style: cairo(20, weight: FontWeight.w700, color: head)),
                ),
                if (chapters.length > 1) ...[
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
                          for (var i = 0; i < chapters.length; i++)
                            DropdownMenuItem(
                                value: i,
                                child: Text(chapters[i].title,
                                    style: cairo(12,
                                        weight: FontWeight.w700, color: AppColors.slate800))),
                        ],
                        onChanged: (v) => app.setChapter(v ?? 0),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          SelectableText(ch.content, style: tajawal(app.fontSize, color: fg, height: 1.625)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _navBtn('→ الفصل السابق', idx > 0, () => app.setChapter(idx - 1)),
              Text('${idx + 1} / ${chapters.length}',
                  style: cairo(12, weight: FontWeight.w700, color: AppColors.slate400)),
              _navBtn('الفصل التالي ←', idx < chapters.length - 1, () => app.setChapter(idx + 1)),
            ],
          ),
          const SizedBox(height: 24),
          // التصويت والمكتبة
          Container(
            padding: const EdgeInsets.only(top: 24),
            decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.slate100))),
            child: Wrap(
              runSpacing: 12,
              spacing: 12,
              children: [
                Live<bool>(
                  streamKey: '${s.id}/${app.uid}',
                  create: () => Repo.votedStream(s.id, app.uid ?? ''),
                  builder: (context, v) {
                    final voted = v.data ?? false;
                    return _pill(
                      '${voted ? 'تم الإعجاب' : 'تصويت وإعجاب'} (${s.votes})',
                      voted ? Icons.favorite : Icons.favorite_border,
                      voted ? AppColors.red500 : AppColors.red50,
                      voted ? Colors.white : AppColors.red600,
                      AppColors.red200,
                      () => guard(context, () => Repo.toggleVote(s.id, app.uid ?? '')),
                    );
                  },
                ),
                _pill(
                  app.library.contains(s.id) ? 'في مكتبتي' : 'حفظ بالمكتبة',
                  app.library.contains(s.id) ? Icons.bookmark : Icons.bookmark_border,
                  AppColors.slate100,
                  AppColors.slate700,
                  AppColors.slate100,
                  () => guard(context, () => app.toggleLibrary(s.id)),
                ),
                _pill('إضافة إلى قائمة', Icons.playlist_add, AppColors.slate100,
                    AppColors.slate700, AppColors.slate100,
                    () => showAddToListDialog(context, s)),
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
                        style: cairo(20, weight: FontWeight.w700, color: head)),
                  ),
                ]),
                const SizedBox(height: 16),
                CommentInput(storyId: s.id, chapterId: ch.id),
                const SizedBox(height: 16),
                Live<List<Comment>>(
                  streamKey: '${s.id}/${ch.id}',
                  create: () => Repo.commentsStream(s.id, ch.id),
                  builder: (context, cm) {
                    if (cm.hasError) return errorLine('تعذّر تحميل التعليقات.');
                    final list = cm.data;
                    if (list == null) return loadingBox();
                    if (list.isEmpty) {
                      return Text('لا توجد تعليقات بعد. كن أول المعلقين!',
                          style: cairo(12, color: AppColors.slate400));
                    }
                    return Column(
                      children: [for (final c in list) _comment(context, s, c)],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _comment(BuildContext context, Story s, Comment c) {
    final canDelete = c.uid == app.uid || s.authorId == app.uid;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.slate50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => app.openProfile(c.uid),
            child: avatarCircle(c.avatar, c.user, 32),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(c.user,
                      style: cairo(12, weight: FontWeight.w700, color: AppColors.slate900)),
                  const SizedBox(width: 8),
                  Text(timeAgo(c.createdAt), style: cairo(10, color: AppColors.slate400)),
                ]),
                const SizedBox(height: 4),
                Text(c.text, style: cairo(12, color: AppColors.slate700, height: 1.5)),
              ],
            ),
          ),
          if (canDelete)
            InkWell(
              onTap: () => guard(context, () => Repo.deleteComment(s.id, c.id)),
              child: const Icon(Icons.close, size: 16, color: AppColors.slate400),
            ),
        ],
      ),
    );
  }
}

class CommentInput extends StatefulWidget {
  final String storyId, chapterId;
  const CommentInput({super.key, required this.storyId, required this.chapterId});

  @override
  State<CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<CommentInput> {
  final _c = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _post() async {
    final t = _c.text.trim();
    final me = app.me;
    if (t.isEmpty || me == null || _busy) return;
    setState(() => _busy = true);
    await guard(context,
        () => Repo.addComment(sid: widget.storyId, chapterId: widget.chapterId, me: me, text: t));
    _c.clear();
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        avatarCircle(app.userAvatar, app.userName, 40),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _c,
                maxLines: 2,
                maxLength: 1000,
                style: cairo(14),
                decoration: fieldDeco('اكتب تعليقك على هذا الفصل...', radius: 16),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Material(
                  color: _busy ? AppColors.slate300 : AppColors.brand500,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _busy ? null : _post,
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
