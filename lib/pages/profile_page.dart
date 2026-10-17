import 'package:flutter/material.dart';
import '../data.dart';
import '../theme.dart';
import '../widgets.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 896),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _card(context, w),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: cardBox(),
              child: const _ProfileTabs(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatar(BuildContext context, double size) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 6)),
              ],
            ),
            child: ClipOval(child: netImage(app.userAvatar)),
          ),
          Positioned(
            bottom: 4,
            right: 4,
            child: Material(
              color: AppColors.brand500,
              shape: const CircleBorder(),
              elevation: 2,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => _askAvatar(context),
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.edit, size: 12, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _askAvatar(BuildContext context) {
    final c = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('أدخل رابط صورة البروفايل الجديدة:', style: cairo(14, weight: FontWeight.w700)),
          content: TextField(controller: c, style: cairo(14), decoration: fieldDeco('https://')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('إلغاء', style: cairo(14, color: AppColors.slate600)),
            ),
            TextButton(
              onPressed: () {
                final url = c.text.trim();
                if (url.isNotEmpty) app.setAvatar(url);
                Navigator.pop(ctx);
              },
              child: Text('حفظ',
                  style: cairo(14, weight: FontWeight.w700, color: AppColors.brand500)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _followButtons(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Material(
        color: app.isFollowing ? AppColors.slate200 : AppColors.brand500,
        shape: const StadiumBorder(),
        elevation: 2,
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: app.toggleFollow,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Text(app.isFollowing ? 'تتابعه حالياً' : 'متابعة',
                style: cairo(14,
                    weight: FontWeight.w700,
                    color: app.isFollowing ? AppColors.slate800 : Colors.white)),
          ),
        ),
      ),
      const SizedBox(width: 8),
      Material(
        color: AppColors.slate100,
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: () {
            app.chatTab = 'private';
            app.go('chats');
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Icon(Icons.send, size: 16, color: AppColors.slate700),
          ),
        ),
      ),
    ]);
  }

  Widget _stat(String n, String label) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Text(n, style: cairo(14, weight: FontWeight.w700, color: AppColors.slate900)),
      const SizedBox(width: 4),
      Text(label, style: cairo(14, color: AppColors.slate500)),
    ]);
  }

  Widget _card(BuildContext context, double w) {
    final wide = w >= 640;
    final size = wide ? 128.0 : 112.0;
    final overlap = wide ? 80.0 : 64.0;

    final names = Column(
      crossAxisAlignment: wide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(app.userName,
            style: cairo(24, weight: FontWeight.w800, color: AppColors.slate900)),
        Text(app.userHandle,
            style: cairo(14, weight: FontWeight.w600, color: AppColors.slate500)),
      ],
    );

    return Container(
      clipBehavior: Clip.none,
      decoration: cardBox(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // الغلاف
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Container(
              height: 176,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [AppColors.brand600, AppColors.amber500, AppColors.brand600],
                ),
              ),
              child: Stack(children: [
                Positioned(
                  top: 16,
                  left: 16,
                  child: Material(
                    color: Colors.black.withOpacity(0.4),
                    shape: const StadiumBorder(),
                    child: InkWell(
                      customBorder: const StadiumBorder(),
                      onTap: () => showAlert(context, 'تم تغيير غلاف البروفايل بنجاح!'),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.camera_alt, size: 13, color: Colors.white),
                          const SizedBox(width: 4),
                          Text('تغيير الغلاف',
                              style: cairo(12, weight: FontWeight.w700, color: Colors.white)),
                        ]),
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (wide)
                  SizedBox(
                    height: size - overlap + 16,
                    child: OverflowBox(
                      alignment: Alignment.bottomCenter,
                      minHeight: 0,
                      maxHeight: size,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _avatar(context, size),
                          const SizedBox(width: 16),
                          names,
                          const Spacer(),
                          _followButtons(context),
                        ],
                      ),
                    ),
                  )
                else ...[
                  SizedBox(
                    height: size - overlap,
                    child: OverflowBox(
                      alignment: Alignment.bottomCenter,
                      minHeight: 0,
                      maxHeight: size,
                      child: _avatar(context, size),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(child: names),
                  const SizedBox(height: 16),
                  Center(child: _followButtons(context)),
                ],
                const SizedBox(height: 16),
                Text(app.userBio,
                    textAlign: wide ? TextAlign.start : TextAlign.center,
                    style: cairo(14, color: AppColors.slate700, height: 1.625)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: const BoxDecoration(
                    border: Border.symmetric(
                        horizontal: BorderSide(color: AppColors.slate100)),
                  ),
                  child: Row(
                    mainAxisAlignment:
                        wide ? MainAxisAlignment.start : MainAxisAlignment.center,
                    children: [
                      _stat('${app.myStories.length}', 'قصة'),
                      const SizedBox(width: 24),
                      _stat(fmt(app.followers), 'متابع'),
                      const SizedBox(width: 24),
                      _stat('310', ' يتابعهم'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────── تبويبات الحساب ─────────────
class _ProfileTabs extends StatefulWidget {
  const _ProfileTabs();

  @override
  State<_ProfileTabs> createState() => _ProfileTabsState();
}

class _ProfileTabsState extends State<_ProfileTabs> {
  final _c = TextEditingController();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Widget _tab(String label, String key) {
    final active = app.profileTab == key;
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 24),
      child: InkWell(
        onTap: () => app.setProfileTab(key),
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

  Widget _content() {
    if (app.profileTab == 'lists') {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.brand50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.orange200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📚 قائمة: المفضلة المطلقة 2026',
                style: cairo(14, weight: FontWeight.w700, color: AppColors.slate900)),
            const SizedBox(height: 4),
            Text('تضم أفضل الروايات العاطفية والخيال العلمي لهذا العام.',
                style: cairo(12, color: AppColors.slate600)),
          ],
        ),
      );
    }
    if (app.profileTab == 'wall') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(
              child: TextField(
                controller: _c,
                maxLines: 2,
                style: cairo(14),
                decoration: fieldDeco('اترك رسالة على حائط الكاتب...'),
              ),
            ),
            const SizedBox(width: 12),
            Material(
              color: AppColors.brand500,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  final t = _c.text.trim();
                  if (t.isEmpty) return;
                  app.postWall(t);
                  _c.clear();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Center(
                    child: Text('نشر',
                        style: cairo(12, weight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
              ),
            ),
          ])),
          const SizedBox(height: 16),
          for (final m in app.wall) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.slate50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.slate200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(m.user,
                          style: cairo(12, weight: FontWeight.w700, color: AppColors.slate900)),
                      Text(m.time, style: cairo(10, color: AppColors.slate400)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(m.text, style: cairo(12, color: AppColors.slate700)),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      );
    }
    return StoriesGrid(stories: app.myStories, maxCols: 4);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.slate200))),
            child: Row(children: [
              _tab('القصص المنشورة', 'stories'),
              _tab('قوائم القراءة', 'lists'),
              _tab('حائط المحادثات', 'wall'),
            ]),
          ),
          const SizedBox(height: 24),
          _content(),
        ],
      ),
    );
  }
}
