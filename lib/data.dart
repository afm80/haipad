import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  // الصفحة الرئيسية
  List<Story> homeTop = const [];
  List<Story> homeFresh = const [];
  bool homeLoaded = false;
  DateTime? _homeStamp;

  // صفحة الاستكشاف (تحميل تدريجي)
  static const pageSize = 20;
  List<Story> _feedAll = const [];
  bool feedLoaded = false;
  bool feedLoading = false;
  bool _feedPaged = true; // true: ترقيم من الخادم، false: تصفية/بحث ويُعرض تدريجياً
  bool _hasMoreServer = false;
  int _shown = pageSize;
  int _feedToken = 0;
  DateTime? _feedStamp;
  DocumentSnapshot<Map<String, dynamic>>? _feedLast;
  Timer? _searchTimer;

  // قصصي
  List<Story> _mine = const [];
  bool mineLoaded = false;

  // المكتبة
  List<Story> libraryStories = const [];
  bool libraryLoaded = false;
  String _libKey = '';

  Set<String> library = {};
  Set<String> following = {};
  List<ReadingList> lists = const [];

  final Set<String> _readCounted = {};
  final List<StreamSubscription<dynamic>> _subs = [];

  String get userName => me?.name ?? 'مستخدم';
  String get userAvatar => me?.avatar ?? '';

  List<Story> get myStories => _mine;

  List<Story> get feed => _feedPaged ? _feedAll : _feedAll.take(_shown).toList();
  bool get feedHasMore => _feedPaged ? _hasMoreServer : _feedAll.length > _shown;

  static bool _isPublished(Story s) => s.publishedChapters > 0;

  bool get _hasFilter => genreFilter != 'الجميع' || statusFilter != 'الكل';

  // ───── تحميل الصفحة الرئيسية ─────
  Future<void> loadHome() async {
    try {
      final r = await Future.wait<List<Story>>([
        Repo.topStories('reads', 16),
        Repo.topStories('createdAt', 16),
      ]);
      if (uid == null) return;
      homeTop = r[0].where(_isPublished).take(10).toList();
      homeFresh = r[1].where(_isPublished).take(10).toList();
      homeLoaded = true;
      _homeStamp = DateTime.now();
    } catch (e) {
      fail(e);
      return;
    }
    notifyListeners();
  }

  bool _stale(DateTime? t) =>
      t == null || DateTime.now().difference(t).inSeconds > 90;

  // ───── تحميل صفحة الاستكشاف ─────
  List<Story> _applyFilters(List<Story> l) {
    var r = l;
    if (genreFilter != 'الجميع') r = r.where((s) => s.genre == genreFilter).toList();
    if (statusFilter == 'مكتملة') r = r.where((s) => s.completed).toList();
    if (statusFilter == 'مستمرة') r = r.where((s) => !s.completed).toList();
    return r;
  }

  Future<void> reloadFeed() async {
    final token = ++_feedToken;
    feedLoading = true;
    feedLoaded = false;
    _shown = pageSize;
    _feedLast = null;
    _hasMoreServer = false;
    notifyListeners();
    try {
      final q = searchQuery.trim();
      List<Story> list;
      if (q.isNotEmpty) {
        _feedPaged = false;
        list = _applyFilters(await Repo.searchStories(q));
      } else if (_hasFilter) {
        _feedPaged = false;
        list = await Repo.filteredStories(
          genre: genreFilter == 'الجميع' ? null : genreFilter,
          completed: statusFilter == 'الكل' ? null : statusFilter == 'مكتملة',
        );
      } else {
        _feedPaged = true;
        final page = await Repo.feedPage(sort: sort, limit: pageSize);
        _feedLast = page.last;
        _hasMoreServer = page.rawCount >= pageSize;
        list = page.stories;
      }
      if (token != _feedToken) return;
      list = list.where(_isPublished).toList();
      _feedAll = _feedPaged ? list : sortStories(list, sort);
      _feedStamp = DateTime.now();
    } catch (e) {
      if (token != _feedToken) return;
      fail(e);
      return;
    }
    feedLoaded = true;
    feedLoading = false;
    notifyListeners();
  }

  /// يُستدعى عند الاقتراب من نهاية الصفحة (أو بزر «عرض المزيد»).
  Future<void> loadMore() async {
    if (feedLoading || !feedLoaded || !feedHasMore) return;
    if (!_feedPaged) {
      _shown += pageSize;
      notifyListeners();
      return;
    }
    final token = _feedToken;
    feedLoading = true;
    notifyListeners();
    try {
      final page = await Repo.feedPage(sort: sort, limit: pageSize, after: _feedLast);
      if (token != _feedToken) return;
      _feedLast = page.last ?? _feedLast;
      _hasMoreServer = page.rawCount >= pageSize;
      final have = _feedAll.map((s) => s.id).toSet();
      _feedAll = [
        ..._feedAll,
        ...page.stories.where((s) => _isPublished(s) && !have.contains(s.id)),
      ];
    } catch (_) {
      if (token == _feedToken) _hasMoreServer = false;
    }
    if (token != _feedToken) return;
    feedLoading = false;
    notifyListeners();
  }

  // ───── تحميل المكتبة ─────
  Future<void> loadLibrary() async {
    final ids = library.toList()..sort();
    final key = ids.join(',');
    if (libraryLoaded && key == _libKey) return;
    _libKey = key;
    libraryLoaded = false;
    notifyListeners();
    try {
      final l = ids.isEmpty ? <Story>[] : await Repo.storiesByIds(ids);
      if (key != _libKey) return;
      libraryStories = l;
      libraryLoaded = true;
    } catch (e) {
      fail(e);
      return;
    }
    notifyListeners();
  }

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
      Repo.authorStoriesStream(u).listen((l) {
        _mine = l;
        mineLoaded = true;
        notifyListeners();
      }, onError: fail),
      Repo.libraryStream(u).listen((s) {
        library = s;
        if (page == 'library') loadLibrary();
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
    loadHome();
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
    _searchTimer?.cancel();
    _feedToken++;
    homeTop = const [];
    homeFresh = const [];
    homeLoaded = false;
    _homeStamp = null;
    _feedAll = const [];
    feedLoaded = false;
    feedLoading = false;
    _hasMoreServer = false;
    _feedStamp = null;
    _feedLast = null;
    _mine = const [];
    mineLoaded = false;
    libraryStories = const [];
    libraryLoaded = false;
    _libKey = '';
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
    if (p == 'home' && (!homeLoaded || _stale(_homeStamp))) loadHome();
    if (p == 'explore' && (!feedLoaded || _stale(_feedStamp)) && !feedLoading) {
      reloadFeed();
    }
    if (p == 'library') loadLibrary();
    notifyListeners();
  }

  void filterByGenre(String g) {
    genreFilter = g;
    page = 'explore';
    reloadFeed();
  }

  void setSearch(String q) {
    searchQuery = q;
    if (q.trim().isNotEmpty) page = 'explore';
    notifyListeners();
    // ننتظر توقف الكتابة قليلاً قبل الاستعلام
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 450), reloadFeed);
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
    reloadFeed();
  }

  void setSort(String s) {
    sort = s;
    if (_feedPaged) {
      reloadFeed();
    } else {
      _feedAll = sortStories(_feedAll, s);
      notifyListeners();
    }
  }

  void clearFilters() {
    genreFilter = 'الجميع';
    statusFilter = 'الكل';
    searchQuery = '';
    reloadFeed();
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
