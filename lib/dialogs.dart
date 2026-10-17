import 'package:flutter/material.dart';
import 'cover_picker.dart';
import 'data.dart';
import 'repo.dart';
import 'theme.dart';
import 'widgets.dart';

// ───────────── مساعدات مشتركة للنوافذ ─────────────
Widget _shell(
    {required String title,
    String? subtitle,
    required Widget child,
    double maxWidth = 672}) {
  return Builder(builder: (context) {
    final w = MediaQuery.of(context).size.width;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(w >= 640 ? 32 : 24),
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
                            Text(title,
                                style: cairo(22,
                                    weight: FontWeight.w800, color: AppColors.slate900)),
                            if (subtitle != null) ...[
                              const SizedBox(height: 4),
                              Text(subtitle, style: cairo(12, color: AppColors.slate500)),
                            ],
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
                child,
              ],
            ),
          ),
        ),
      ),
    );
  });
}

Widget _label(String t) => Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(t, style: cairo(12, weight: FontWeight.w700, color: AppColors.slate700)),
    );

Widget _btn(String text, VoidCallback? onTap,
    {bool primary = true, Color? color}) {
  final bg = primary ? (color ?? AppColors.brand500) : AppColors.slate100;
  final fg = primary ? Colors.white : AppColors.slate700;
  return Material(
    color: onTap == null ? AppColors.slate300 : bg,
    borderRadius: BorderRadius.circular(12),
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Text(text, style: cairo(14, weight: FontWeight.w700, color: fg)),
      ),
    ),
  );
}

Future<bool> confirmDialog(BuildContext context, String msg) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (ctx) => Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Text(msg, style: cairo(14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('إلغاء', style: cairo(14, color: AppColors.slate600)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('تأكيد',
                style: cairo(14, weight: FontWeight.w700, color: AppColors.red600)),
          ),
        ],
      ),
    ),
  );
  return r ?? false;
}

String? _req(String? v) => (v == null || v.trim().isEmpty) ? 'هذا الحقل مطلوب' : null;

String? _url(String? v) {
  final t = (v ?? '').trim();
  if (t.isEmpty) return null;
  return (t.startsWith('http://') || t.startsWith('https://')) ? null : 'الرابط غير صحيح';
}

List<String> _parseTags(String s) => s
    .split(RegExp(r'[,،]'))
    .map((e) => e.trim())
    .where((e) => e.isNotEmpty)
    .take(10)
    .toList();

// ───────────── إنشاء قصة / تعديل معلوماتها ─────────────
Future<void> showWriteDialog(BuildContext context) => showDialog<void>(
      context: context,
      builder: (_) => StoryFormDialog(parentContext: context),
    );

Future<void> showEditStoryDialog(BuildContext context, Story s) => showDialog<void>(
      context: context,
      builder: (_) => StoryFormDialog(parentContext: context, story: s),
    );

class StoryFormDialog extends StatefulWidget {
  final BuildContext parentContext;
  final Story? story; // null = إنشاء جديد
  const StoryFormDialog({super.key, required this.parentContext, this.story});

  @override
  State<StoryFormDialog> createState() => _StoryFormDialogState();
}

class _StoryFormDialogState extends State<StoryFormDialog> {
  final _form = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.story?.title ?? '');
  late String _coverVal = widget.story?.cover ?? '';
  String? _coverError;
  late final _desc = TextEditingController(text: widget.story?.desc ?? '');
  late final _tags = TextEditingController(text: widget.story?.tags.join('، ') ?? '');
  final _chTitle = TextEditingController(text: 'الفصل الأول');
  final _chapter = TextEditingController();
  late String _genre = (widget.story != null && allGenres.contains(widget.story!.genre))
      ? widget.story!.genre
      : allGenres.first;
  late bool _completed = widget.story?.completed ?? false;
  bool _busy = false;
  String? _error;

  bool get _editing => widget.story != null;

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _tags.dispose();
    _chTitle.dispose();
    _chapter.dispose();
    super.dispose();
  }

  Future<void> _save(bool publish) async {
    if (!_form.currentState!.validate()) return;
    final me = app.me;
    if (me == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final ctx = widget.parentContext;
    try {
      if (_editing) {
        await Repo.updateStory(
          widget.story!.id,
          title: _title.text.trim(),
          genre: _genre,
          cover: _coverVal,
          desc: _desc.text.trim(),
          tags: _parseTags(_tags.text),
          completed: _completed,
        );
      } else {
        await Repo.createStory(
          me: me,
          title: _title.text.trim(),
          genre: _genre,
          cover: _coverVal,
          desc: _desc.text.trim(),
          tags: _parseTags(_tags.text),
          completed: _completed,
          chapterTitle: _chTitle.text.trim(),
          chapterContent: _chapter.text.trim(),
          publish: publish,
        );
      }
      if (!mounted) return;
      Navigator.pop(context);
      if (!_editing) {
        app.setMyTab(publish ? 'published' : 'drafts');
        app.go('my-stories');
      }
      if (ctx.mounted) {
        showAlert(
            ctx,
            _editing
                ? 'تم حفظ التعديلات.'
                : (publish ? 'تم نشر قصتك بنجاح!' : 'تم حفظ القصة كمسودة.'));
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = 'تعذّر الحفظ، حاول مرة أخرى.';
        });
      }
    }
  }

  Future<void> _pickCover() async {
    try {
      final data = await pickCoverImage();
      if (data == null || !mounted) return;
      setState(() {
        _coverVal = data;
        _coverError = null;
      });
    } catch (e) {
      if (mounted) setState(() => _coverError = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return _shell(
      title: _editing ? 'تعديل معلومات القصة' : 'إنشاء قصة جديدة',
      subtitle: _editing ? null : 'أدخل معلومات القصة ثم أضف فصلك الأول.',
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _label('عنوان القصة *'),
            TextFormField(
              controller: _title,
              validator: _req,
              maxLength: 150,
              style: cairo(14),
              decoration: fieldDeco('مثال: سر القلعة المفقودة'),
            ),
            const SizedBox(height: 8),
            _label('التصنيف *'),
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
            _label('صورة الغلاف (اختياري)'),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(width: 72, height: 96, child: netImage(_coverVal)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _btn(_coverVal.isEmpty ? 'اختيار صورة من الجهاز' : 'تغيير الصورة',
                              _busy ? null : _pickCover),
                          if (_coverVal.isNotEmpty)
                            TextButton(
                              onPressed: _busy ? null : () => setState(() => _coverVal = ''),
                              child: Text('إزالة',
                                  style: cairo(13,
                                      weight: FontWeight.w700, color: AppColors.red600)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('تُقصّ الصورة تلقائياً بنسبة 2:3 (مثل واتباد).',
                          style: cairo(11, color: AppColors.slate400)),
                      if (_coverError != null) errorLine(_coverError!),
                    ],
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
              maxLength: 1500,
              style: cairo(14),
              decoration: fieldDeco('نبذة مختصرة مشوقة تجذب القراء...'),
            ),
            const SizedBox(height: 8),
            _label('الوسوم (افصل بينها بفاصلة)'),
            TextFormField(
              controller: _tags,
              style: cairo(14),
              decoration: fieldDeco('رعب، قلعة، أسرار'),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _completed,
              activeColor: AppColors.brand500,
              onChanged: (v) => setState(() => _completed = v),
              title: Text('القصة مكتملة', style: cairo(14, weight: FontWeight.w700)),
            ),
            if (!_editing) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.only(top: 16),
                decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: AppColors.slate100))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _label('عنوان الفصل الأول *'),
                    TextFormField(
                      controller: _chTitle,
                      validator: _req,
                      style: cairo(14),
                      decoration: fieldDeco('الفصل الأول'),
                    ),
                    const SizedBox(height: 16),
                    _label('محتوى الفصل الأول *'),
                    TextFormField(
                      controller: _chapter,
                      validator: _req,
                      maxLines: 8,
                      style: tajawal(14, height: 1.625),
                      decoration: fieldDeco('اكتب أحداث الفصل الأول هنا...'),
                    ),
                  ],
                ),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: cairo(12, color: AppColors.red600)),
            ],
            const SizedBox(height: 24),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 12,
              runSpacing: 12,
              children: [
                _btn('إلغاء', _busy ? null : () => Navigator.pop(context), primary: false),
                if (_editing)
                  _btn('حفظ', _busy ? null : () => _save(true))
                else ...[
                  _btn('حفظ كمسودة', _busy ? null : () => _save(false), primary: false),
                  _btn('نشر القصة', _busy ? null : () => _save(true)),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────── كتابة / تعديل فصل ─────────────
Future<void> showChapterDialog(BuildContext context, Story s, {Chapter? chapter}) =>
    showDialog<void>(
      context: context,
      builder: (_) => ChapterDialog(parentContext: context, story: s, chapter: chapter),
    );

class ChapterDialog extends StatefulWidget {
  final BuildContext parentContext;
  final Story story;
  final Chapter? chapter;
  const ChapterDialog(
      {super.key, required this.parentContext, required this.story, this.chapter});

  @override
  State<ChapterDialog> createState() => _ChapterDialogState();
}

class _ChapterDialogState extends State<ChapterDialog> {
  final _form = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.chapter?.title ?? '');
  late final _content = TextEditingController(text: widget.chapter?.content ?? '');
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    super.dispose();
  }

  Future<void> _save(bool publish) async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await Repo.saveChapter(
        storyId: widget.story.id,
        chapter: widget.chapter,
        title: _title.text.trim(),
        content: _content.text.trim(),
        publish: publish,
      );
      if (!mounted) return;
      Navigator.pop(context);
      final ctx = widget.parentContext;
      if (ctx.mounted) {
        showAlert(ctx, publish ? 'تم نشر الفصل.' : 'تم حفظ الفصل كمسودة.');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = 'تعذّر الحفظ، حاول مرة أخرى.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _shell(
      title: widget.chapter == null ? 'فصل جديد' : 'تعديل الفصل',
      subtitle: widget.story.title,
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _label('عنوان الفصل *'),
            TextFormField(
              controller: _title,
              validator: _req,
              style: cairo(14),
              decoration: fieldDeco('مثال: الفصل الثاني: المخطوطة'),
            ),
            const SizedBox(height: 16),
            _label('محتوى الفصل *'),
            TextFormField(
              controller: _content,
              validator: _req,
              maxLines: 14,
              style: tajawal(14, height: 1.625),
              decoration: fieldDeco('اكتب فصلك هنا...'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: cairo(12, color: AppColors.red600)),
            ],
            const SizedBox(height: 24),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 12,
              runSpacing: 12,
              children: [
                _btn('إلغاء', _busy ? null : () => Navigator.pop(context), primary: false),
                _btn('حفظ كمسودة', _busy ? null : () => _save(false), primary: false),
                _btn('نشر الفصل', _busy ? null : () => _save(true)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────── إدارة القصة وفصولها ─────────────
Future<void> showManageDialog(BuildContext context, Story s) => showDialog<void>(
      context: context,
      builder: (_) => _ManageDialog(parentContext: context, storyId: s.id),
    );

class _ManageDialog extends StatelessWidget {
  final BuildContext parentContext;
  final String storyId;
  const _ManageDialog({required this.parentContext, required this.storyId});

  @override
  Widget build(BuildContext context) {
    return _shell(
      title: 'إدارة القصة',
      child: Live<Story?>(
        streamKey: storyId,
        create: () => Repo.storyStream(storyId),
        builder: (context, snap) {
          final s = snap.data;
          if (snap.connectionState == ConnectionState.waiting) return loadingBox();
          if (s == null) return emptyLine('هذه القصة غير موجودة.');
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(s.title,
                  style: cairo(18, weight: FontWeight.w800, color: AppColors.slate900)),
              const SizedBox(height: 12),
              Wrap(spacing: 12, runSpacing: 12, children: [
                _btn('تعديل المعلومات', () => showEditStoryDialog(parentContext, s),
                    primary: false),
                _btn('+ فصل جديد', () => showChapterDialog(parentContext, s)),
              ]),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: s.completed,
                activeColor: AppColors.brand500,
                onChanged: (v) => guard(context, () => Repo.setCompleted(s.id, v)),
                title: Text('القصة مكتملة', style: cairo(14, weight: FontWeight.w700)),
              ),
              const Divider(color: AppColors.slate100),
              Text('الفصول',
                  style: cairo(14, weight: FontWeight.w700, color: AppColors.slate700)),
              const SizedBox(height: 8),
              Live<List<Chapter>>(
                streamKey: s.id,
                create: () => Repo.chaptersStream(s.id, all: true),
                builder: (context, cs) {
                  if (cs.hasError) return errorLine('تعذّر تحميل الفصول.');
                  final list = cs.data;
                  if (list == null) return loadingBox();
                  if (list.isEmpty) return emptyLine('لا توجد فصول بعد.');
                  return Column(
                    children: [for (final c in list) _chapterRow(context, s, c)],
                  );
                },
              ),
              const Divider(color: AppColors.slate100),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  onPressed: () async {
                    final ok = await confirmDialog(
                        context, 'سيتم حذف القصة وكل فصولها وتعليقاتها نهائياً. هل أنت متأكد؟');
                    if (!ok || !context.mounted) return;
                    await guard(context, () => Repo.deleteStory(s.id));
                    if (context.mounted) Navigator.pop(context);
                    if (app.readingId == s.id && app.page == 'story-reader') app.go('my-stories');
                  },
                  icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.red600),
                  label: Text('حذف القصة',
                      style: cairo(13, weight: FontWeight.w700, color: AppColors.red600)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _chapterRow(BuildContext context, Story s, Chapter c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.slate50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Row(children: [
        Expanded(
          child: Text(c.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: cairo(13, weight: FontWeight.w700, color: AppColors.slate800)),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: c.published ? AppColors.emerald500 : AppColors.slate300,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(c.published ? 'منشور' : 'مسودة',
              style: cairo(10, weight: FontWeight.w700, color: Colors.white)),
        ),
        IconButton(
          tooltip: 'تعديل',
          icon: const Icon(Icons.edit, size: 18, color: AppColors.slate600),
          onPressed: () => showChapterDialog(parentContext, s, chapter: c),
        ),
        IconButton(
          tooltip: 'حذف',
          icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.red600),
          onPressed: () async {
            final ok = await confirmDialog(context, 'حذف هذا الفصل نهائياً؟');
            if (!ok || !context.mounted) return;
            await guard(context, () => Repo.deleteChapter(s.id, c));
          },
        ),
      ]),
    );
  }
}

// ───────────── إضافة قصة إلى قائمة قراءة ─────────────
Future<void> showAddToListDialog(BuildContext context, Story s) => showDialog<void>(
      context: context,
      builder: (_) => _AddToListDialog(story: s),
    );

class _AddToListDialog extends StatefulWidget {
  final Story story;
  const _AddToListDialog({required this.story});

  @override
  State<_AddToListDialog> createState() => _AddToListDialogState();
}

class _AddToListDialogState extends State<_AddToListDialog> {
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final n = _name.text.trim();
    final u = app.uid;
    if (n.isEmpty || u == null) return;
    _name.clear();
    await guard(context, () => Repo.createList(u, n, storyId: widget.story.id));
  }

  @override
  Widget build(BuildContext context) {
    return _shell(
      title: 'إضافة إلى قائمة قراءة',
      subtitle: widget.story.title,
      maxWidth: 480,
      child: ListenableBuilder(
        listenable: app,
        builder: (context, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (app.lists.isEmpty) emptyLine('لا توجد قوائم بعد. أنشئ قائمتك الأولى:'),
            for (final l in app.lists)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.brand500,
                value: l.storyIds.contains(widget.story.id),
                title: Text(l.name, style: cairo(14, weight: FontWeight.w700)),
                onChanged: (v) {
                  final u = app.uid;
                  if (u == null) return;
                  guard(context,
                      () => Repo.toggleInList(u, l.id, widget.story.id, v ?? false));
                },
              ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _name,
                  style: cairo(14),
                  maxLength: 60,
                  onSubmitted: (_) => _create(),
                  decoration: fieldDeco('اسم قائمة جديدة'),
                ),
              ),
              const SizedBox(width: 8),
              _btn('إنشاء', _create),
            ]),
          ],
        ),
      ),
    );
  }
}

// ───────────── تعديل الملف الشخصي ─────────────
Future<void> showProfileEditDialog(BuildContext context) => showDialog<void>(
      context: context,
      builder: (_) => _ProfileEditDialog(parentContext: context),
    );

class _ProfileEditDialog extends StatefulWidget {
  final BuildContext parentContext;
  const _ProfileEditDialog({required this.parentContext});

  @override
  State<_ProfileEditDialog> createState() => _ProfileEditDialogState();
}

class _ProfileEditDialogState extends State<_ProfileEditDialog> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: app.me?.name ?? '');
  late final _bio = TextEditingController(text: app.me?.bio ?? '');
  late final _avatar = TextEditingController(text: app.me?.avatar ?? '');
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _bio.dispose();
    _avatar.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final u = app.uid;
    if (u == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await Repo.updateProfile(u,
          name: _name.text.trim(), bio: _bio.text.trim(), avatar: _avatar.text.trim());
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = 'تعذّر الحفظ، حاول مرة أخرى.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _shell(
      title: 'تعديل الملف الشخصي',
      maxWidth: 520,
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _label('الاسم *'),
            TextFormField(
              controller: _name,
              validator: _req,
              maxLength: 40,
              style: cairo(14),
              decoration: fieldDeco('اسمك كما يظهر للآخرين'),
            ),
            const SizedBox(height: 8),
            _label('نبذة عنك'),
            TextFormField(
              controller: _bio,
              maxLines: 3,
              maxLength: 300,
              style: cairo(14),
              decoration: fieldDeco('اكتب نبذة قصيرة...'),
            ),
            const SizedBox(height: 8),
            _label('رابط صورة الملف الشخصي (اختياري)'),
            TextFormField(
              controller: _avatar,
              validator: _url,
              keyboardType: TextInputType.url,
              style: cairo(14),
              decoration: fieldDeco('https://...'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: cairo(12, color: AppColors.red600)),
            ],
            const SizedBox(height: 24),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 12,
              children: [
                _btn('إلغاء', _busy ? null : () => Navigator.pop(context), primary: false),
                _btn('حفظ', _busy ? null : _save),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
