import 'package:flutter/material.dart';
import '../data.dart';
import '../repo.dart';
import '../theme.dart';
import '../widgets.dart';

class ChatsPage extends StatelessWidget {
  ChatsPage({super.key});

  Widget _tab(String label, IconData icon, String key) {
    final active = app.chatTab == key;
    return InkWell(
      onTap: () => app.setChatTab(key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
                color: active ? AppColors.brand500 : Colors.transparent, width: 2),
          ),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16, color: active ? AppColors.brand500 : AppColors.slate500),
          const SizedBox(width: 8),
          Text(label,
              style: cairo(14,
                  weight: FontWeight.w700,
                  color: active ? AppColors.brand500 : AppColors.slate500)),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1024),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const PageHeading(
              'مركز المحادثات والتواصل الاجتماعي',
              'تواصل مع الكُتّاب والقراء في الغرف العامة أو في الرسائل الخاصة المباشرة.',
            ),
            const SizedBox(height: 24),
            Container(
              decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.slate200))),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: [
                  _tab('غرف المحادثة العامة', Icons.groups, 'public'),
                  _tab('الرسائل الخاصة (DM)', Icons.mail, 'private'),
                ]),
              ),
            ),
            const SizedBox(height: 24),
            if (app.chatTab == 'public') PublicChat() else PrivateChat(),
          ],
        ),
      ),
    );
  }
}

// ───────────── مساعدات مشتركة ─────────────
Widget _panelBox(Widget child) => Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
      ),
      child: child,
    );

Widget _inputBar(TextEditingController c, String hint, VoidCallback onSend) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: const BoxDecoration(
      color: AppColors.slate50,
      border: Border(top: BorderSide(color: AppColors.slate200)),
    ),
    child: Row(children: [
      Expanded(
        child: TextField(
          controller: c,
          style: cairo(14),
          onSubmitted: (_) => onSend(),
          decoration: fieldDeco(hint).copyWith(
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.slate300),
            ),
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
          onTap: onSend,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Text('إرسال',
                style: cairo(14, weight: FontWeight.w700, color: Colors.white)),
          ),
        ),
      ),
    ]),
  );
}

Widget _split(BuildContext context, Widget side, Widget main) {
  final w = MediaQuery.of(context).size.width;
  if (w >= 768) {
    return SizedBox(
      height: 550,
      child: LayoutBuilder(builder: (context, c) {
        final col = (c.maxWidth - 48) / 3;
        return Row(children: [
          SizedBox(width: col, child: side),
          const SizedBox(width: 24),
          SizedBox(width: col * 2 + 24, child: main),
        ]);
      }),
    );
  }
  return SizedBox(
    height: 550,
    child: Column(children: [
      SizedBox(height: 263, child: side),
      const SizedBox(height: 24),
      SizedBox(height: 263, child: main),
    ]),
  );
}

// ───────────── الغرف العامة ─────────────
class PublicChat extends StatefulWidget {
  const PublicChat({super.key});

  @override
  State<PublicChat> createState() => _PublicChatState();
}

class _PublicChatState extends State<PublicChat> {
  final _c = TextEditingController();

  Color _roomColor(String id) {
    if (id == 'writers') return AppColors.brand500;
    if (id == 'horror') return AppColors.slate800;
    return AppColors.rose500;
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final t = _c.text.trim();
    final me = app.me;
    if (t.isEmpty || me == null) return;
    _c.clear();
    await guard(context, () => Repo.sendRoom(app.room, me, t));
  }

  @override
  Widget build(BuildContext context) {
    final room = chatRooms.firstWhere((r) => r[0] == app.room, orElse: () => chatRooms.first);

    final side = _panelBox(
      ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: Text('غرف النقاش',
                style: cairo(12, weight: FontWeight.w700, color: AppColors.slate400)),
          ),
          for (final r in chatRooms)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: app.room == r[0] ? AppColors.brand50 : Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                      color: app.room == r[0] ? AppColors.brand100 : Colors.transparent),
                ),
                child: InkWell(
                  customBorder:
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onTap: () => app.selectRoom(r[0]),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(children: [
                      Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration:
                            BoxDecoration(color: _roomColor(r[0]), shape: BoxShape.circle),
                        child: Text(r[1], style: const TextStyle(fontSize: 16)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r[2],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: cairo(14,
                                    weight: FontWeight.w700, color: AppColors.slate900)),
                            Text(r[3],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: cairo(12, color: AppColors.slate500)),
                          ],
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    final main = _panelBox(
      Column(children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppColors.slate50,
            border: Border(bottom: BorderSide(color: AppColors.slate200)),
          ),
          child: Text(room[2],
              style: cairo(14, weight: FontWeight.w700, color: AppColors.slate800)),
        ),
        Expanded(
          child: Live<List<ChatMsg>>(
            streamKey: app.room,
            create: () => Repo.roomStream(app.room),
            builder: (context, snap) {
              if (snap.hasError) return Center(child: errorLine('تعذّر تحميل الرسائل.'));
              final msgs = snap.data;
              if (msgs == null) return loadingBox();
              if (msgs.isEmpty) {
                return Center(child: emptyLine('لا توجد رسائل بعد. ابدأ النقاش!'));
              }
              return ListView.separated(
                reverse: true,
                padding: const EdgeInsets.all(16),
                itemCount: msgs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (_, i) {
                  final m = msgs[i];
                  return Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: LayoutBuilder(
                      builder: (context, c) => ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: c.maxWidth * 0.85),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.slate50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.slate200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    onTap: () => app.openProfile(m.uid),
                                    child: Text(m.user,
                                        style: cairo(12,
                                            weight: FontWeight.w700,
                                            color: AppColors.brand600)),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(timeAgo(m.createdAt),
                                      style: cairo(10, color: AppColors.slate400)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(m.text,
                                  style: cairo(12, color: AppColors.slate800, height: 1.625)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        _inputBar(_c, 'اكتب رسالتك للغرفة العامة...', _send),
      ]),
    );

    return _split(context, side, main);
  }
}

// ───────────── الرسائل الخاصة ─────────────
class PrivateChat extends StatefulWidget {
  const PrivateChat({super.key});

  @override
  State<PrivateChat> createState() => _PrivateChatState();
}

class _PrivateChatState extends State<PrivateChat> {
  final _c = TextEditingController();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final t = _c.text.trim();
    final me = app.me;
    final peer = app.dmPeerUid;
    if (t.isEmpty || me == null || peer == null) return;
    _c.clear();
    await guard(
        context,
        () => Repo.sendDm(
              me: me,
              peerUid: peer,
              peerName: app.dmPeerName ?? 'مستخدم',
              peerAvatar: app.dmPeerAvatar ?? '',
              text: t,
            ));
  }

  @override
  Widget build(BuildContext context) {
    final uid = app.uid ?? '';
    final sel = app.selectedDm;

    final side = _panelBox(
      Live<List<Conversation>>(
        streamKey: uid,
        create: () => Repo.conversationsStream(uid),
        builder: (context, snap) {
          if (snap.hasError) return Center(child: errorLine('تعذّر تحميل المحادثات.'));
          final convs = snap.data;
          if (convs == null) return loadingBox();
          if (convs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('لا توجد محادثات بعد.\nافتح ملف أي كاتب واضغط زر الرسالة لبدء محادثة.',
                    textAlign: TextAlign.center,
                    style: cairo(12, color: AppColors.slate400, height: 1.6)),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final d in convs)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: d.id == sel ? AppColors.brand50 : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                          color: d.id == sel ? AppColors.brand100 : AppColors.slate200),
                    ),
                    child: InkWell(
                      customBorder:
                          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      onTap: () => app.selectDm(d.id, d.peerUid(uid), d.peerName(uid),
                          d.peerAvatar(uid)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(children: [
                          avatarCircle(d.peerAvatar(uid), d.peerName(uid), 40),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(d.peerName(uid),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: cairo(14,
                                        weight: FontWeight.w700, color: AppColors.slate900)),
                                Text(d.lastMsg,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: cairo(12, color: AppColors.slate500)),
                              ],
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );

    final main = _panelBox(
      Column(children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppColors.slate50,
            border: Border(bottom: BorderSide(color: AppColors.slate200)),
          ),
          child: Text(
            sel == null
                ? 'اختر محادثة لبدء التواصل الخاص'
                : 'المحادثة الخاصة مع: ${app.dmPeerName ?? ''}',
            style: cairo(14, weight: FontWeight.w700, color: AppColors.slate800),
          ),
        ),
        Expanded(
          child: sel == null
              ? Center(
                  child: Text('لا توجد محادثة محددة حالياً.',
                      style: cairo(14, color: AppColors.slate400)))
              : Live<List<ChatMsg>>(
                  streamKey: sel,
                  create: () => Repo.dmStream(sel),
                  builder: (context, snap) {
                    // محادثة جديدة لم تُرسل فيها رسالة بعد قد تعيد خطأ صلاحيات؛ نعاملها كفارغة.
                    final msgs = snap.data ?? const <ChatMsg>[];
                    if (snap.data == null && snap.connectionState == ConnectionState.waiting) {
                      return loadingBox();
                    }
                    if (msgs.isEmpty) {
                      return Center(
                          child: emptyLine('لا توجد رسائل بعد. اكتب أول رسالة.'));
                    }
                    return ListView.separated(
                      reverse: true,
                      padding: const EdgeInsets.all(16),
                      itemCount: msgs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (_, i) {
                        final m = msgs[i];
                        final me = m.uid == app.uid;
                        return Align(
                          alignment: me ? Alignment.centerLeft : Alignment.centerRight,
                          child: LayoutBuilder(
                            builder: (context, c) => ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: c.maxWidth * 0.75),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: me ? AppColors.brand500 : AppColors.slate100,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(m.text,
                                    style: cairo(12,
                                        weight: FontWeight.w600,
                                        color: me ? Colors.white : AppColors.slate800)),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
        if (sel != null) _inputBar(_c, 'اكتب رسالة خاصة...', _send),
      ]),
    );

    return _split(context, side, main);
  }
}
