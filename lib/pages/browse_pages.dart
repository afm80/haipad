import 'package:flutter/material.dart';
import '../data.dart';
import '../dialogs.dart';
import '../theme.dart';
import '../widgets.dart';

Widget _chip(String label, bool active, VoidCallback onTap) {
  return Material(
    color: active ? AppColors.brand500 : Colors.white,
    shape: StadiumBorder(
        side: BorderSide(color: active ? AppColors.brand500 : AppColors.slate200)),
    child: InkWell(
      customBorder: const StadiumBorder(),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(label,
            style: cairo(12,
                weight: FontWeight.w700,
                color: active ? Colors.white : AppColors.slate700)),
      ),
    ),
  );
}

// ───────────── استكشف ─────────────
class ExplorePage extends StatelessWidget {
  ExplorePage({super.key});

  List<Story> _filtered() {
    var l = app.published;
    if (app.genreFilter != 'الجميع') {
      l = l.where((s) => s.genre == app.genreFilter).toList();
    }
    if (app.statusFilter == 'مكتملة') l = l.where((s) => s.completed).toList();
    if (app.statusFilter == 'مستمرة') l = l.where((s) => !s.completed).toList();
    final q = app.searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      l = l
          .where((s) =>
              s.title.toLowerCase().contains(q) ||
              s.author.toLowerCase().contains(q) ||
              s.genre.toLowerCase().contains(q) ||
              s.tags.any((t) => t.toLowerCase().contains(q)))
          .toList();
    }
    return sortStories(l, app.sort);
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final cols = w >= 1024 ? 6 : (w >= 768 ? 4 : (w >= 640 ? 3 : 2));
    final all = app.genreFilter == 'الجميع';
    final q = app.searchQuery.trim();
    final list = _filtered();
    final filtered = !all || q.isNotEmpty || app.statusFilter != 'الكل';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PageHeading(
          'استكشف القصص',
          'تصفّح حسب التصنيف أو ابحث بالعنوان أو الكاتب أو الوسوم.',
        ),
        const SizedBox(height: 24),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: allGenres.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 66,
          ),
          itemBuilder: (_, i) {
            final g = allGenres[i];
            final active = app.genreFilter == g;
            return Material(
              color: active ? AppColors.brand50 : Colors.white,
              elevation: 0.5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: active ? AppColors.brand500 : AppColors.slate200),
              ),
              child: InkWell(
                customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                onTap: () => app.filterByGenre(g),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.bookmark, size: 15, color: AppColors.brand500),
                    const SizedBox(height: 4),
                    Text(g,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: cairo(12, weight: FontWeight.w700, color: AppColors.slate800)),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('الحالة:', style: cairo(12, weight: FontWeight.w700, color: AppColors.slate500)),
            for (final st in const ['الكل', 'مستمرة', 'مكتملة'])
              _chip(st, app.statusFilter == st, () => app.setStatus(st)),
            const SizedBox(width: 12),
            Text('الترتيب:', style: cairo(12, weight: FontWeight.w700, color: AppColors.slate500)),
            _chip('الأكثر قراءة', app.sort == 'reads', () => app.setSort('reads')),
            _chip('الأحدث', app.sort == 'new', () => app.setSort('new')),
            _chip('الأكثر إعجاباً', app.sort == 'votes', () => app.setSort('votes')),
            if (filtered)
              InkWell(
                onTap: app.clearFilters,
                child: Text('مسح التصفية',
                    style: cairo(12, weight: FontWeight.w700, color: AppColors.brand500)),
              ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
            q.isNotEmpty
                ? 'نتائج البحث عن "$q"'
                : (all ? 'كل القصص' : 'تصنيف: ${app.genreFilter}'),
            style: cairo(24, weight: FontWeight.w700, color: AppColors.slate900)),
        const SizedBox(height: 16),
        if (!app.storiesLoaded)
          loadingBox()
        else
          StoriesGrid(
            stories: list,
            emptyText: filtered
                ? 'لا توجد قصص مطابقة.'
                : 'لا توجد قصص منشورة بعد. كن أول من ينشر!',
          ),
      ],
    );
  }
}

// ───────────── مكتبتي ─────────────
class LibraryPage extends StatelessWidget {
  LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final list = app.stories.where((s) => app.library.contains(s.id)).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeading(
          'مكتبتي الشخصية',
          'القصص التي حفظتها للقراءة لاحقاً.',
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.brand100,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text('${list.length} قصة',
                style: cairo(12, weight: FontWeight.w700, color: AppColors.brand600)),
          ),
        ),
        const SizedBox(height: 24),
        if (!app.storiesLoaded)
          loadingBox()
        else
          StoriesGrid(
            stories: list,
            emptyText: 'مكتبتك فارغة حالياً. تصفح القصص وأضف ما يعجبك هنا!',
          ),
      ],
    );
  }
}

// ───────────── لوحة قصصي ─────────────
class MyStoriesPage extends StatelessWidget {
  MyStoriesPage({super.key});

  Widget _tab(String label, String key) {
    final active = app.myTab == key;
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 16),
      child: InkWell(
        onTap: () => app.setMyTab(key),
        child: Container(
          padding: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                  color: active ? AppColors.brand500 : Colors.transparent, width: 2),
            ),
          ),
          child: Text(label,
              style: cairo(14,
                  weight: FontWeight.w700,
                  color: active ? AppColors.brand500 : AppColors.slate500)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final drafts = app.myTab == 'drafts';
    final mine = app.myStories
        .where((s) => drafts ? s.publishedChapters == 0 : s.publishedChapters > 0)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeading(
          'لوحة التحكم بالقصص (قصصي)',
          'إدارة رواياتك، نشر فصول جديدة، وتتبع الإحصائيات.',
          trailing: Material(
            color: AppColors.brand500,
            borderRadius: BorderRadius.circular(12),
            elevation: 2,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => showWriteDialog(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add, size: 16, color: Colors.white),
                    const SizedBox(width: 8),
                    Text('إنشاء قصة جديدة',
                        style: cairo(14, weight: FontWeight.w700, color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.slate200))),
          child: Row(
            children: [
              _tab('القصص المنشورة', 'published'),
              _tab('المسودات', 'drafts'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (!app.storiesLoaded)
          loadingBox()
        else if (mine.isEmpty)
          emptyLine(drafts ? 'لا توجد مسودات.' : 'لم تنشر أي قصة بعد.'),
        for (final s in mine) ...[
          _item(context, s, w),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _item(BuildContext context, Story s, double w) {
    final info = Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(width: 64, height: 96, child: netImage(s.cover)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.genre,
                  style: cairo(12, weight: FontWeight.w700, color: AppColors.brand500)),
              Text(s.title,
                  style: cairo(16, weight: FontWeight.w700, color: AppColors.slate900)),
              const SizedBox(height: 4),
              Text(
                  '${s.publishedChapters} فصول منشورة · ${fmt(s.reads)} قراءة · ${s.votes} إعجاب'
                  '${s.completed ? ' · مكتملة' : ''}',
                  style: cairo(12, color: AppColors.slate500)),
            ],
          ),
        ),
      ],
    );
    Widget small(String t, VoidCallback onTap, {bool primary = false}) => Material(
          color: primary ? AppColors.brand500 : AppColors.slate100,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(t,
                  style: cairo(12,
                      weight: FontWeight.w700,
                      color: primary ? Colors.white : AppColors.slate800)),
            ),
          ),
        );
    final buttons = Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (s.publishedChapters > 0) small('قراءة', () => app.openStory(s.id)),
        small('إدارة الفصول', () => showManageDialog(context, s)),
        small('+ فصل جديد', () => showChapterDialog(context, s), primary: true),
      ],
    );
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: cardBox(radius: 16),
      child: w >= 640
          ? Row(children: [Expanded(child: info), const SizedBox(width: 16), buttons])
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [info, const SizedBox(height: 16), buttons]),
    );
  }
}
