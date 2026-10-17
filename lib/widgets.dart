import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'data.dart';
import 'theme.dart';
import 'auth_service.dart';
import 'dialogs.dart';

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
                _auth(context, w >= 640),
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

  Widget _auth(BuildContext context, bool showName) {
    return PopupMenuButton<String>(
      tooltip: '',
      onSelected: (v) {
        if (v == 'profile') app.go('profile');
        if (v == 'my-stories') app.go('my-stories');
        if (v == 'logout') AuthService.signOut();
      },
      itemBuilder: (_) => [
        PopupMenuItem(
            value: 'profile',
            child: Text('ملفي الشخصي', style: cairo(13, weight: FontWeight.w700))),
        PopupMenuItem(
            value: 'my-stories',
            child: Text('لوحة قصصي', style: cairo(13, weight: FontWeight.w700))),
        PopupMenuItem(
            value: 'logout',
            child: Text('تسجيل الخروج',
                style: cairo(13, weight: FontWeight.w700, color: AppColors.red600))),
      ],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.brand500, width: 2),
            ),
            child: avatarCircle(app.userAvatar, app.userName, 32),
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

/// يشترك في Stream مرة واحدة ولا يعيد الاشتراك عند إعادة بناء الصفحة؛
/// يعيد الاشتراك فقط عند تغيّر [streamKey].
class Live<T> extends StatefulWidget {
  final Object streamKey;
  final Stream<T> Function() create;
  final Widget Function(BuildContext, AsyncSnapshot<T>) builder;
  const Live({
    super.key,
    required this.streamKey,
    required this.create,
    required this.builder,
  });

  @override
  State<Live<T>> createState() => _LiveState<T>();
}

class _LiveState<T> extends State<Live<T>> {
  late Stream<T> _stream = widget.create();

  @override
  void didUpdateWidget(Live<T> old) {
    super.didUpdateWidget(old);
    if (old.streamKey != widget.streamKey) _stream = widget.create();
  }

  @override
  Widget build(BuildContext context) =>
      StreamBuilder<T>(stream: _stream, builder: widget.builder);
}

/// ينفّذ عملية على Firestore ويعرض رسالة مفهومة عند الفشل.
Future<void> guard(BuildContext context, Future<void> Function() action) async {
  try {
    await action();
  } catch (e) {
    final msg = e.toString().contains('permission-denied')
        ? 'ليست لديك صلاحية لتنفيذ هذه العملية.'
        : 'تعذّر تنفيذ العملية، حاول مرة أخرى.';
    if (context.mounted) showAlert(context, msg);
  }
}

Widget loadingBox() => const Padding(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Center(child: CircularProgressIndicator(color: AppColors.brand500)),
    );

Widget emptyLine(String t) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(t, style: cairo(14, color: AppColors.slate400)),
    );

Widget errorLine(String t) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(t, style: cairo(14, color: AppColors.red600)),
    );

/// صورة دائرية للمستخدم؛ تعرض الحرف الأول إذا لم تتوفر صورة.
Widget avatarCircle(String url, String name, double size) {
  final letter = name.trim().isEmpty ? '؟' : name.trim().substring(0, 1);
  return ClipOval(
    child: SizedBox(
      width: size,
      height: size,
      child: url.isEmpty
          ? Container(
              alignment: Alignment.center,
              color: AppColors.brand100,
              child: Text(letter,
                  style: cairo(size * 0.45, weight: FontWeight.w800, color: AppColors.brand600)),
            )
          : netImage(url),
    ),
  );
}

final Map<String, Uint8List> _imgCache = {};

Widget netImage(String url, {BoxFit fit = BoxFit.cover}) {
  if (url.isEmpty) {
    return Container(
      color: AppColors.slate100,
      alignment: Alignment.center,
      child: const Icon(Icons.menu_book, color: AppColors.slate300),
    );
  }
  // صور مرفوعة من الجهاز تُحفظ كنص base64
  if (url.startsWith('data:image')) {
    try {
      final bytes = _imgCache.putIfAbsent(
          url, () => base64Decode(url.substring(url.indexOf(',') + 1)));
      return Image.memory(
        bytes,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => Container(color: AppColors.slate100),
      );
    } catch (_) {
      return Container(color: AppColors.slate100);
    }
  }
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
            brandName(24),
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
                aspectRatio: 2 / 3,
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
                    if (story.completed)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.emerald600,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text('مكتملة',
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
          mainAxisExtent: cardW * 3 / 2 + 100,
        ),
        itemBuilder: (_, i) => StoryCard(story: stories[i]),
      );
    });
  }
}
