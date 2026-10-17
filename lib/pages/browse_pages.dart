import 'package:flutter/material.dart';
import '../data.dart';
import '../theme.dart';
import '../widgets.dart';

// ───────────── استكشف ─────────────
class ExplorePage extends StatelessWidget {
  ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final cols = w >= 1024 ? 6 : (w >= 768 ? 4 : (w >= 640 ? 3 : 2));
    final all = app.genreFilter == 'الجميع';
    final list = all ? app.stories : app.stories.where((s) => s.genre == app.genreFilter).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PageHeading(
          'استكشف جميع التصنيفات (23 تصنيفاً)',
          'اختر التصنيف المفضل لديك للوصول إلى آلاف الروايات والقصص المكتوبة بأقلام عربية مبدعة.',
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
            return Material(
              color: Colors.white,
              elevation: 0.5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.slate200),
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
        Text(all ? 'الجميع (كل القصص)' : 'تصنيف: ${app.genreFilter}',
            style: cairo(24, weight: FontWeight.w700, color: AppColors.slate900)),
        const SizedBox(height: 16),
        StoriesGrid(stories: list, emptyText: 'لا توجد قصص حتى الآن في هذا التصنيف.'),
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
          'القصص التي حفظتها للقراءة لاحقاً ومتابعة تحديثاتها.',
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
    return InkWell(
      onTap: () {
        app.myTab = key;
        app.refresh();
      },
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final mine = app.myStories;
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
              const SizedBox(width: 16),
              _tab('المسودات', 'drafts'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (mine.isEmpty)
          Text('لم تقم بكتابة أي قصة بعد.', style: cairo(14, color: AppColors.slate400)),
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
          child: SizedBox(width: 64, height: 80, child: netImage(s.cover)),
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
              Text('${s.chapters.length} فصول منشورة',
                  style: cairo(12, color: AppColors.slate500)),
            ],
          ),
        ),
      ],
    );
    final buttons = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: AppColors.slate100,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => app.openStory(s.id),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('قراءة',
                  style: cairo(12, weight: FontWeight.w700, color: AppColors.slate800)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Material(
          color: AppColors.brand500,
          borderRadius: BorderRadius.circular(12),
          elevation: 2,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => showAlert(context, 'خاصية إضافة فصل جديد مسودة جاهزة'),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('+ فصل جديد',
                  style: cairo(12, weight: FontWeight.w700, color: Colors.white)),
            ),
          ),
        ),
      ],
    );
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: cardBox(radius: 16),
      child: w >= 640
          ? Row(children: [Expanded(child: info), const SizedBox(width: 16), buttons])
          : Column(children: [info, const SizedBox(height: 16), buttons]),
    );
  }
}
