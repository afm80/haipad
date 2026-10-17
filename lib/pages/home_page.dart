import 'package:flutter/material.dart';
import '../data.dart';
import '../dialogs.dart';
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
        _hero(context, w),
        const SizedBox(height: 32),
        _genres(),
        const SizedBox(height: 32),
        _featured(context),
        const SizedBox(height: 32),
        _banner(w),
      ],
    );
  }

  Widget _pillButton(String text, VoidCallback onTap, {bool primary = true}) {
    return Material(
      color: primary ? AppColors.brand500 : Colors.white.withOpacity(0.1),
      shape: StadiumBorder(
        side: primary ? BorderSide.none : BorderSide(color: Colors.white.withOpacity(0.2)),
      ),
      elevation: primary ? 6 : 0,
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Text(text, style: cairo(14, weight: FontWeight.w700, color: Colors.white)),
        ),
      ),
    );
  }

  Widget _hero(BuildContext context, double w) {
    final wide = w >= 640;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.slate900,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.slate800),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 25,
              spreadRadius: -5,
              offset: const Offset(0, 20)),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -40,
            bottom: -40,
            child: Container(
              width: 256,
              height: 256,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.brand500.withOpacity(0.2),
                  AppColors.brand500.withOpacity(0),
                ]),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(wide ? 40 : 24),
            child: Align(
              alignment: Alignment.centerRight,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 672),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.brand500.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.brand500.withOpacity(0.3)),
                      ),
                      child: Text('مجتمع الكتاب والقرّاء العرب',
                          style: cairo(12, weight: FontWeight.w700, color: Colors.white)),
                    ),
                    const SizedBox(height: 16),
                    Text('شارِك شغفك.. اكتب رِوايتك واكتشف عوالم جديدة',
                        style: cairo(wide ? 48 : 30,
                            weight: FontWeight.w800, color: Colors.white, height: 1.25)),
                    const SizedBox(height: 16),
                    Text(
                      'منصة haipad تفتح لك الأبواب لنشر قصصك بكل سلاسة، والتفاعل مع آلاف القراء والكتاب بأسلوب عصري مجاني بالكامل.',
                      style: cairo(wide ? 16 : 14, color: AppColors.slate300, height: 1.625),
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _pillButton('ابدأ الكتابة الآن', () => showWriteDialog(context)),
                        _pillButton('استكشف القصص', () => app.go('explore'), primary: false),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
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
    if (!app.storiesLoaded) return loadingBox();
    final all = app.published;
    if (all.isEmpty) {
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
    final top = sortStories(all, 'reads').take(10).toList();
    final fresh = sortStories(all, 'new').take(10).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _section('الأكثر قراءة', top),
        const SizedBox(height: 32),
        _section('أحدث القصص', fresh),
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
