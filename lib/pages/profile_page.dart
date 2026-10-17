import 'package:flutter/material.dart';
import '../data.dart';
import '../dialogs.dart';
import '../repo.dart';
import '../theme.dart';
import '../widgets.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = app.viewUid ?? app.uid;
    if (uid == null) return emptyLine('لا يوجد مستخدم.');
    final w = MediaQuery.of(context).size.width;
    return Live<UserProfile?>(
      streamKey: uid,
      create: () => Repo.userStream(uid),
      builder: (context, snap) {
        if (snap.hasError) return errorLine('تعذّر تحميل الملف الشخصي.');
        if (snap.connectionState == ConnectionState.waiting) return loadingBox();
        final p = snap.data;
        if (p == null) return emptyLine('هذا المستخدم غير موجود.');
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 896),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _card(context, p, w),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: cardBox(),
                  child: _ProfileTabs(profile: p),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _avatar(UserProfile p, double size) {
    return Container(
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
      child: avatarCircle(p.avatar, p.name, size - 8),
    );
  }

  Widget _pillBtn(String text, bool filled, VoidCallback onTap) {
    return Material(
      color: filled ? AppColors.brand500 : AppColors.slate200,
      shape: const StadiumBorder(),
      elevation: filled ? 2 : 0,
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Text(text,
              style: cairo(14,
                  weight: FontWeight.w700,
                  color: filled ? Colors.white : AppColors.slate800)),
        ),
      ),
    );
  }

  Widget _actions(BuildContext context, UserProfile p) {
    if (p.uid == app.uid) {
      return _pillBtn('تعديل الملف', false, () => showProfileEditDialog(context));
    }
    final following = app.following.contains(p.uid);
    return Row(mainAxisSize: MainAxisSize.min, children: [
      _pillBtn(following ? 'تتابعه حالياً' : 'متابعة', !following,
          () => guard(context, () => app.toggleFollow(p.uid))),
      const SizedBox(width: 8),
      Material(
        color: AppColors.slate100,
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: () => app.openDmWith(p.uid, p.name, p.avatar),
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

  Widget _card(BuildContext context, UserProfile p, double w) {
    final wide = w >= 640;
    final size = wide ? 128.0 : 112.0;
    final overlap = wide ? 80.0 : 64.0;

    final names = Column(
      crossAxisAlignment: wide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(p.name, style: cairo(24, weight: FontWeight.w800, color: AppColors.slate900)),
        if (p.handle.isNotEmpty)
          Text(p.handle,
              style: cairo(14, weight: FontWeight.w600, color: AppColors.slate500)),
      ],
    );

    return Container(
      clipBehavior: Clip.none,
      decoration: cardBox(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
                          _avatar(p, size),
                          const SizedBox(width: 16),
                          names,
                          const Spacer(),
                          _actions(context, p),
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
                      child: _avatar(p, size),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(child: names),
                  const SizedBox(height: 16),
                  Center(child: _actions(context, p)),
                ],
                if (p.bio.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(p.bio,
                      textAlign: wide ? TextAlign.start : TextAlign.center,
                      style: cairo(14, color: AppColors.slate700, height: 1.625)),
                ],
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
                      _stat('${app.publishedOf(p.uid).length}', 'قصة'),
                      const SizedBox(width: 24),
                      _stat(fmt(p.followers), 'متابع'),
                      const SizedBox(width: 24),
                      _stat(fmt(p.following), 'يتابعهم'),
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
  final UserProfile profile;
  const _ProfileTabs({required this.profile});

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

  bool get _isMe => widget.profile.uid == app.uid;

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

  Widget _lists() {
    final p = widget.profile;
    return Live<List<ReadingList>>(
      streamKey: p.uid,
      create: () => Repo.listsStream(p.uid),
      builder: (context, snap) {
        if (snap.hasError) return errorLine('تعذّر تحميل القوائم.');
        final lists = snap.data;
        if (lists == null) return loadingBox();
        if (lists.isEmpty) {
          return emptyLine(_isMe
              ? 'لا توجد قوائم بعد. أضف قصصاً إلى قوائم من صفحة القراءة.'
              : 'لا توجد قوائم قراءة.');
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final l in lists) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.brand50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.orange200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(children: [
                      Expanded(
                        child: Text('📚 ${l.name} (${l.storyIds.length})',
                            style: cairo(14, weight: FontWeight.w700, color: AppColors.slate900)),
                      ),
                      if (_isMe)
                        InkWell(
                          onTap: () async {
                            final ok = await confirmDialog(context, 'حذف قائمة "${l.name}"؟');
                            if (!ok || !context.mounted) return;
                            await guard(context, () => Repo.deleteList(p.uid, l.id));
                          },
                          child: const Icon(Icons.delete_outline,
                              size: 18, color: AppColors.red600),
                        ),
                    ]),
                    const SizedBox(height: 12),
                    StoriesGrid(
                      stories: app.stories.where((s) => l.storyIds.contains(s.id)).toList(),
                      maxCols: 4,
                      emptyText: 'القائمة فارغة.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ],
        );
      },
    );
  }

  Widget _wall() {
    final p = widget.profile;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(
              child: TextField(
                controller: _c,
                maxLines: 2,
                maxLength: 500,
                style: cairo(14),
                decoration: fieldDeco(_isMe
                    ? 'اكتب شيئاً على حائطك...'
                    : 'اترك رسالة على حائط ${p.name}...'),
              ),
            ),
            const SizedBox(width: 12),
            Material(
              color: AppColors.brand500,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  final t = _c.text.trim();
                  final me = app.me;
                  if (t.isEmpty || me == null) return;
                  _c.clear();
                  await guard(context, () => Repo.postWall(p.uid, me, t));
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
          ]),
        ),
        const SizedBox(height: 16),
        Live<List<WallPost>>(
          streamKey: p.uid,
          create: () => Repo.wallStream(p.uid),
          builder: (context, snap) {
            if (snap.hasError) return errorLine('تعذّر تحميل الحائط.');
            final list = snap.data;
            if (list == null) return loadingBox();
            if (list.isEmpty) return emptyLine('لا توجد رسائل على الحائط بعد.');
            return Column(
              children: [
                for (final m in list)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
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
                          children: [
                            InkWell(
                              onTap: () => app.openProfile(m.authorId),
                              child: Text(m.user,
                                  style: cairo(12,
                                      weight: FontWeight.w700, color: AppColors.slate900)),
                            ),
                            const SizedBox(width: 8),
                            Text(timeAgo(m.createdAt),
                                style: cairo(10, color: AppColors.slate400)),
                            const Spacer(),
                            if (_isMe || m.authorId == app.uid)
                              InkWell(
                                onTap: () => guard(context, () => Repo.deleteWall(p.uid, m.id)),
                                child: const Icon(Icons.close, size: 16, color: AppColors.slate400),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(m.text, style: cairo(12, color: AppColors.slate700, height: 1.5)),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _content() {
    switch (app.profileTab) {
      case 'lists':
        return _lists();
      case 'wall':
        return _wall();
      default:
        return StoriesGrid(
          stories: app.publishedOf(widget.profile.uid),
          maxCols: 4,
          emptyText: _isMe ? 'لم تنشر أي قصة بعد.' : 'لم ينشر هذا الكاتب أي قصة بعد.',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.slate200))),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              _tab('القصص المنشورة', 'stories'),
              _tab('قوائم القراءة', 'lists'),
              _tab('حائط المحادثات', 'wall'),
            ]),
          ),
        ),
        const SizedBox(height: 24),
        _content(),
      ],
    );
  }
}
