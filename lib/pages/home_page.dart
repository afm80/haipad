import 'package:flutter/material.dart';
import '../data.dart';
import '../theme.dart';
import '../widgets.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _genres(),
        const SizedBox(height: 32),
        _featured(context),
        const SizedBox(height: 32),
        _banner(w),
      ],
    );
  }

  Widget _genres() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(Icons.local_fire_department, size: 22, color: AppColors.brand500),
            const SizedBox(width: 8),
            Text('تصفّح حسب التصنيف',
                style: cairo(20, weight: FontWeight.w700, color: AppColors.slate900)),
            const Spacer(),
            InkWell(
              onTap: () => app.go('explore'),
              child: Text('عرض الكل (23)',
                  style: cairo(14, weight: FontWeight.w700, color: AppColors.brand500)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              for (final g in allGenres.take(10)) ...[
                Material(
                  color: Colors.white,
                  elevation: 0.5,
                  shape: const StadiumBorder(side: BorderSide(color: AppColors.slate200)),
                  child: InkWell(
                    customBorder: const StadiumBorder(),
                    onTap: () => app.filterByGenre(g),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(g,
                          style: cairo(12, weight: FontWeight.w700, color: AppColors.slate700)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _section(String title, List<Story> list) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: cairo(24, weight: FontWeight.w800, color: AppColors.slate900)),
        const SizedBox(height: 16),
        StoriesGrid(stories: list),
      ],
    );
  }

  Widget _featured(BuildContext context) {
    if (!app.homeLoaded) return loadingBox();
    if (app.homeTop.isEmpty && app.homeFresh.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: cardBox(),
        child: Column(
          children: [
            const Icon(Icons.auto_stories, size: 40, color: AppColors.slate300),
            const SizedBox(height: 12),
            Text('لا توجد قصص منشورة بعد',
                style: cairo(18, weight: FontWeight.w700, color: AppColors.slate900)),
            const SizedBox(height: 4),
            Text('كن أول من ينشر قصة على المنصة!',
                style: cairo(14, color: AppColors.slate500)),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _section('الأكثر قراءة', app.homeTop),
        const SizedBox(height: 32),
        _section('أحدث القصص', app.homeFresh),
      ],
    );
  }

  Widget _banner(double w) {
    final wide = w >= 640;
    final info = Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.brand500,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 6,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: const Icon(Icons.menu_book, size: 26, color: Colors.white),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('هل لديك قصة لم تُحكَ بعد؟',
                  style: cairo(18, weight: FontWeight.w700, color: AppColors.slate900)),
              const SizedBox(height: 4),
              Text('استفد من أدوات الكتابة المجانية وأنِشئ فصول قِصتك وشاركها مع المجتمع مباشرة.',
                  style: cairo(14, color: AppColors.slate600)),
            ],
          ),
        ),
      ],
    );
    final button = Material(
      color: AppColors.slate900,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => app.go('my-stories'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text('لوحة قصصي',
              style: cairo(14, weight: FontWeight.w700, color: Colors.white)),
        ),
      ),
    );
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.brand50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.orange200),
      ),
      child: wide
          ? Row(children: [Expanded(child: info), const SizedBox(width: 16), button])
          : Column(children: [info, const SizedBox(height: 16), button]),
    );
  }
}
