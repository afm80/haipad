import 'dart:async';
import 'package:flutter/material.dart';
import 'models.dart';
import 'repo.dart';

export 'models.dart';

const allGenres = [
  "الإثارة", "غموض", "العاطفية", "الحركة والأكشن", "قصص عامة", "عشوائي",
  "قصص المراهقين", "القصة القصيرة", "قصص الهواة", "أدب نسائي", "الخيال(فانتازيا)",
  "المغامرة", "الفكاهة", "التاريخية", "الخيال العلمي", "الرعب", "المستذئب",
  "الشعر", "الخوارق", "مصاصو الدماء", "الروحانية", "غير روائي", "الكلاسيكية التقليدية"
];

/// الغرف العامة (المعرّف، الرمز، الاسم، الوصف).
const chatRooms = [
  ['writers', '✍️', 'ملتقى الكتاب العرب', 'مناقشة الأفكار والتأليف'],
  ['horror', '👻', 'عشّاق أدب الرعب والغموض', 'قصص مصاصي الدماء والخوارق'],
  ['romance', '💖', 'نادي الروايات العاطفية', 'مناقشة أشهر القصص الرومانسية'],
];

List<Story> sortStories(List<Story> list, String sort) {
  final l = [...list];
  switch (sort) {
    case 'new':
      l.sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));
      break;
    case 'votes':
      l.sort((a, b) => b.votes.compareTo(a.votes));
      break;
    default:
      l.sort((a, b) => b.reads.compareTo(a.reads));
  }
  return l;
}

/// حالة التطبيق: التنقل وإعدادات الواجهة + بيانات مشتركة تُقرأ حيّة من Firestore.
class AppState extends ChangeNotifier {
  // ───── التنقل والواجهة ─────
  String page = 'home';
  String genreFilter = 'الجميع';
  String statusFilter = 'الكل'; // الكل | مكتملة | مستمرة
  String sort = 'reads'; // reads | new | votes
  String searchQuery = '';
  String? readingId;
  int chapterIndex = 0;
  double fontSize = 18;
  String readerTheme = 'light';
  String chatTab = 'public';
  String room = 'writers';
  String? selectedDm;
  String? dmPeerUid, dmPeerName, dmPeerAvatar;
  String profileTab = 'stories';
  String myTab = 'published';
  String? viewUid; // الملف المعروض؛ null = ملفي

  // ───── بيانات حيّة ─────
  String? uid;
  UserProfile? me;
  String? fatal;
  List<Story> stories = const [];
  bool storiesLoaded = false;
  Set<String> library = {};
  Set<String> following = {};
  List<ReadingList> lists = const [];

  final Set<String> _readCounted = {};
  final List<StreamSubscription<dynamic>> _subs = [];

  String get userName => me?.name ?? 'مستخدم';
  String get userAvatar => me?.avatar ?? '';

  List<Story> get published => stories.where((s) => s.publishedChapters > 0).toList();
  List<Story> get myStories => stories.where((s) => s.authorId == uid).toList();
  List<Story> publishedOf(String u) =>
      stories.where((s) => s.authorId == u && s.publishedChapters > 0).toList();

  // ───── دورة الحياة ─────
  void start(String u) {
    if (uid == u) return;
    stop(notify: false);
    uid = u;
    _subs.addAll([
      Repo.userStream(u).listen((p) {
        me = p;
        notifyListeners();
      }, onError: fail),
      Repo.storiesStream().listen((l) {
        stories = l;
        storiesLoaded = true;
        notifyListeners();
      }, onError: fail),
      Repo.libraryStream(u).listen((s) {
        library = s;
        notifyListeners();
      }, onError: fail),
      Repo.followingStream(u).listen((s) {
        following = s;
        notifyListeners();
      }, onError: fail),
      Repo.listsStream(u).listen((l) {
        lists = l;
        notifyListeners();
      }, onError: fail),
    ]);
    notifyListeners();
  }

  void fail(Object e) {
    fatal = 'تعذّر الاتصال بقاعدة البيانات. تأكد من تفعيل Firestore ونشر قواعد الأمان '
        '(ملف firestore.rules).\n$e';
    notifyListeners();
  }

  void stop({bool notify = true}) {
    for (final s in _subs) {
      s.cancel();
    }
    _subs.clear();
    uid = null;
    me = null;
    fatal = null;
    stories = const [];
    storiesLoaded = false;
    library = {};
    following = {};
    lists = const [];
    _readCounted.clear();
    page = 'home';
    genreFilter = 'الجميع';
    statusFilter = 'الكل';
    searchQuery = '';
    readingId = null;
    selectedDm = null;
    viewUid = null;
    profileTab = 'stories';
    if (notify) notifyListeners();
  }

  // ───── أفعال التنقل ─────
  void go(String p) {
    page = p;
    if (p == 'profile') viewUid = null;
    notifyListeners();
  }

  void filterByGenre(String g) {
    genreFilter = g;
    page = 'explore';
    notifyListeners();
  }

  void setSearch(String q) {
    searchQuery = q;
    if (q.trim().isNotEmpty) page = 'explore';
    notifyListeners();
  }

  void openStory(String id) {
    readingId = id;
    chapterIndex = 0;
    page = 'story-reader';
    if (uid != null && _readCounted.add(id)) {
      Repo.countRead(id).catchError((_) {});
    }
    notifyListeners();
  }

  void openProfile(String u) {
    viewUid = u == uid ? null : u;
    profileTab = 'stories';
    page = 'profile';
    notifyListeners();
  }

  void openDmWith(String peerUid, String name, String avatar) {
    final me = uid;
    if (me == null || peerUid == me) return;
    chatTab = 'private';
    selectedDm = Repo.convId(me, peerUid);
    dmPeerUid = peerUid;
    dmPeerName = name;
    dmPeerAvatar = avatar;
    page = 'chats';
    notifyListeners();
  }

  void selectDm(String id, String peerUid, String name, String avatar) {
    selectedDm = id;
    dmPeerUid = peerUid;
    dmPeerName = name;
    dmPeerAvatar = avatar;
    notifyListeners();
  }

  void setReaderTheme(String t) {
    readerTheme = t;
    notifyListeners();
  }

  void adjustFont(double d) {
    fontSize = (fontSize + d).clamp(14, 26).toDouble();
    notifyListeners();
  }

  void setChapter(int i) {
    chapterIndex = i;
    notifyListeners();
  }

  void setChatTab(String t) {
    chatTab = t;
    notifyListeners();
  }

  void selectRoom(String r) {
    room = r;
    notifyListeners();
  }

  void setProfileTab(String t) {
    profileTab = t;
    notifyListeners();
  }

  void setMyTab(String t) {
    myTab = t;
    notifyListeners();
  }

  void setStatus(String s) {
    statusFilter = s;
    notifyListeners();
  }

  void setSort(String s) {
    sort = s;
    notifyListeners();
  }

  void clearFilters() {
    genreFilter = 'الجميع';
    statusFilter = 'الكل';
    searchQuery = '';
    notifyListeners();
  }

  // ───── أفعال تكتب في Firestore ─────
  Future<void> toggleLibrary(String sid) {
    final u = uid;
    if (u == null) return Future.value();
    return Repo.setLibrary(u, sid, !library.contains(sid));
  }

  Future<void> toggleFollow(String target) {
    final u = uid;
    if (u == null || u == target) return Future.value();
    return Repo.setFollow(me: u, target: target, follow: !following.contains(target));
  }
}

final app = AppState();
