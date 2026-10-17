import 'package:flutter/material.dart';

const allGenres = [
  "الإثارة", "غموض", "العاطفية", "الحركة والأكشن", "قصص عامة", "عشوائي",
  "قصص المراهقين", "القصة القصيرة", "قصص الهواة", "أدب نسائي", "الخيال(فانتازيا)",
  "المغامرة", "الفكاهة", "التاريخية", "الخيال العلمي", "الرعب", "المستذئب",
  "الشعر", "الخوارق", "مصاصو الدماء", "الروحانية", "غير روائي", "الكلاسيكية التقليدية"
];

class Chapter {
  final String title, content;
  const Chapter(this.title, this.content);
}

class Comment {
  final String user, avatar, text;
  const Comment(this.user, this.avatar, this.text);
}

class Story {
  final int id;
  final String title, author, authorHandle, genre, cover, desc;
  int reads, votes;
  final List<Chapter> chapters;
  final List<Comment> comments;
  Story({
    required this.id,
    required this.title,
    required this.author,
    required this.authorHandle,
    required this.genre,
    required this.cover,
    required this.desc,
    required this.reads,
    required this.votes,
    required this.chapters,
    required this.comments,
  });
}

class PublicMsg {
  final String user, text, time;
  const PublicMsg(this.user, this.text, this.time);
}

class DmMsg {
  final String sender, text;
  const DmMsg(this.sender, this.text);
}

class Dm {
  final int id;
  final String user, avatar;
  String lastMsg;
  final List<DmMsg> messages;
  Dm(this.id, this.user, this.avatar, this.lastMsg, this.messages);
}

class WallMsg {
  final String user, text, time;
  const WallMsg(this.user, this.text, this.time);
}

class AppState extends ChangeNotifier {
  String page = 'home';
  String genreFilter = 'الجميع';
  String searchQuery = '';
  int readingId = 1;
  int chapterIndex = 0;
  double fontSize = 18;
  String readerTheme = 'light';

  String userName = 'نور الطيب';
  String userHandle = '@nooraltaib';
  String userAvatar =
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=300';
  String userBio =
      'كاتبة وشغوفة بروايات أدب الخيال والرعب والغموض 📚 | صدر لي روايات عديدة على المنصة | أرحب بكل آرائكم واستفساراتكم.';
  int followers = 1240;
  bool isFollowing = false;

  List<int> library = [1, 3];

  final List<Story> stories = [
    Story(
      id: 1,
      title: 'ظل القلعة القديمة',
      author: 'نور الطيب',
      authorHandle: '@nooraltaib',
      genre: 'غموض',
      cover: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?auto=format&fit=crop&q=80&w=400',
      desc: 'في قرية جبلية معزولة، تظهر أسرار اختفاء عائلة كاملة منذ أربعين عاماً، حين يقرر كاتب شاب دخول القلعة المهجورة بنفسه...',
      reads: 14500,
      votes: 1230,
      chapters: [
        const Chapter('الفصل الأول: النداء الغامض',
            "كانت الرياح تعصف بقمم الأشجار المتراصة حول القلعة المظلمة. سار يوسف بخطوات حذرة، حاملاً مصباحه النفطي القديم. أوراق الشجر اليابسة تتكسر تحت قدميه لتكسر صمت الليل الثقيل.\n\nوصل إلى البوابة الحديدية الضخمة المتآكلة بفعل الصدأ. فتحها بصوت صرير حاد تردد صداه في الوادي كله. بداخل القلعة، كانت هناك لوحة زيتية معلقة على الحائط لامرأة تبتسم بريبة، وعيناها تبدوان وكأنهما تلاحقان كل من يمر أمامها..."),
        const Chapter('الفصل الثاني: المخطوطة الذهبية',
            "في الطابق الثاني، وجد مكتبة غطى الغبار أرففها الخشبية. بين الكتب القديمة، لفتت انتباهه مخطوطة ملطخة بالبرونز القديم. عندما فتحها، قرأ السطر الأول: 'من يقرأ هذه الكلمات لم يعد بوسعه العودة...'."),
      ],
      comments: [
        const Comment('سارة أحمد', 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=100', 'بداية مشوقة جداً! طريقة الوصف تصنع أجواء رعب ممتازة.'),
        const Comment('عمر خالد', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=100', 'متى ينزل الفصل القادم؟ لا أستطيع الانتظار!'),
      ],
    ),
    Story(
      id: 2,
      title: 'عرش المستذئب الأخير',
      author: 'أحمد محمود',
      authorHandle: '@ahmed_m',
      genre: 'المستذئب',
      cover: 'https://images.unsplash.com/photo-1560942485-b2a11cc13456?auto=format&fit=crop&q=80&w=400',
      desc: 'صراع قديم بين العشائر السبع في الغابات الشمالية عندما يكتشف البطل أنه آخر سليل لسلالة الذئاب الفضية.',
      reads: 28900,
      votes: 3410,
      chapters: [
        const Chapter('الفصل الأول: ليلة اكتمال القمر',
            'سطع القمر بضوئه الفضي الكامل فوق غابات الصنوبر. شعر أصلان بحرارة تسري في عروقه وتتحول عينيه إلى اللون الذهبي المشع...'),
      ],
      comments: [],
    ),
    Story(
      id: 3,
      title: 'نبضات في زحام القاهرة',
      author: 'مريم العلي',
      authorHandle: '@maryam_ali',
      genre: 'العاطفية',
      cover: 'https://images.unsplash.com/photo-1516589178581-6cd7833ae3b2?auto=format&fit=crop&q=80&w=400',
      desc: 'رواية رومانسية اجتماعية تدور أحداثها بين أروقة المعارض الفنية والمقاهي الشعبية في القاهرة.',
      reads: 9200,
      votes: 890,
      chapters: [
        const Chapter('الفصل الأول: اللقاء الأول',
            'كانت المطر تهطل بغزارة حين التقت أعينهما في معرض اللوحات الزيتية...'),
      ],
      comments: [],
    ),
    Story(
      id: 4,
      title: 'حارس النجوم: الأفق البعيد',
      author: 'نور الطيب',
      authorHandle: '@nooraltaib',
      genre: 'الخيال العلمي',
      cover: 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?auto=format&fit=crop&q=80&w=400',
      desc: 'في عام 2150، تنطلق سفينة فضاء عربية لاستكشاف كوكب جديد يوفر الطاقة للبشرية.',
      reads: 5400,
      votes: 620,
      chapters: [
        const Chapter('الفصل الأول: الإقلاع',
            'بدأ العد التنازلي من محطة مدارية في صحراء الخليج العربي...'),
      ],
      comments: [],
    ),
  ];

  String chatTab = 'public';
  String room = 'writers';
  final Map<String, List<PublicMsg>> publicMessages = {
    'writers': [
      const PublicMsg('أحمد محمود', 'أهلاً بالجميع! ما هو رأيكم في تطوير الشخصية الرئيسية بالقصص القصيرة؟', '10:15 ص'),
      const PublicMsg('نور الطيب', 'أفضل دائماً التركيز على دوافع الشخصية وعيوبها قبل مميزاتها.', '10:18 ص'),
    ],
    'horror': [
      const PublicMsg('كريم أدب', 'من يحب قصص مصاصي الدماء والخوارق الكلاسيكية؟', '09:30 ص'),
    ],
    'romance': [
      const PublicMsg('هدى العلي', "رواية 'نبضات' رائعة جداً أتمنى لها النجاح!", '11:00 ص'),
    ],
  };

  final List<Dm> dms = [
    Dm(1, 'أحمد محمود',
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=150',
        'أتمنى لك التوفيق في روايتك الجديدة!', [
      const DmMsg('them', 'مرحباً نور، قرأت قصتك الشائقة!'),
      const DmMsg('me', 'شكراً جزيلاً لك يا أحمد! يسعدني رأيك.'),
    ]),
  ];
  int? selectedDm;

  final List<WallMsg> wall = [
    const WallMsg('فاطمة الزهراء', 'أبدعتِ في الفصل الأخير من رواية ظل القلعة! بانتظار جديدك.', 'منذ ساعتين'),
  ];
  String profileTab = 'stories';
  String myTab = 'published';

  // ───── أفعال ─────
  void refresh() => notifyListeners();

  void setUser({required String name, String? avatar}) {
    userName = name;
    if (avatar != null && avatar.isNotEmpty) userAvatar = avatar;
    notifyListeners();
  }

  void go(String p) {
    page = p;
    notifyListeners();
  }

  void filterByGenre(String g) {
    genreFilter = g;
    page = 'explore';
    notifyListeners();
  }

  void setSearch(String q) {
    searchQuery = q;
    notifyListeners();
  }

  void openStory(int id) {
    readingId = id;
    chapterIndex = 0;
    page = 'story-reader';
    notifyListeners();
  }

  Story get current => stories.firstWhere((s) => s.id == readingId);
  List<Story> get myStories => stories.where((s) => s.author == userName).toList();

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

  void vote() {
    current.votes++;
    notifyListeners();
  }

  bool toggleLibrary() {
    final added = !library.contains(readingId);
    if (added) {
      library.add(readingId);
    } else {
      library.remove(readingId);
    }
    notifyListeners();
    return added;
  }

  void addComment(String text) {
    current.comments.add(Comment(userName, userAvatar, text));
    notifyListeners();
  }

  void createStory(String title, String genre, String cover, String desc, String chapter) {
    stories.insert(
      0,
      Story(
        id: DateTime.now().millisecondsSinceEpoch,
        title: title,
        author: userName,
        authorHandle: userHandle,
        genre: genre,
        cover: cover.isEmpty
            ? 'https://images.unsplash.com/photo-1543002588-bfa74002ed7e?auto=format&fit=crop&q=80&w=400'
            : cover,
        desc: desc,
        reads: 1,
        votes: 0,
        chapters: [Chapter('الفصل الأول', chapter)],
        comments: [],
      ),
    );
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

  void sendPublic(String text) {
    publicMessages[room]!.add(PublicMsg(userName, text, 'الآن'));
    notifyListeners();
  }

  void selectDm(int id) {
    selectedDm = id;
    notifyListeners();
  }

  void sendDm(String text) {
    final dm = dms.firstWhere((d) => d.id == (selectedDm ?? 1));
    dm.messages.add(DmMsg('me', text));
    dm.lastMsg = text;
    selectedDm = dm.id;
    notifyListeners();
  }

  void setProfileTab(String t) {
    profileTab = t;
    notifyListeners();
  }

  void toggleFollow() {
    isFollowing = !isFollowing;
    followers += isFollowing ? 1 : -1;
    notifyListeners();
  }

  void postWall(String text) {
    wall.insert(0, WallMsg(userName, text, 'الآن'));
    notifyListeners();
  }

  void setAvatar(String url) {
    userAvatar = url;
    notifyListeners();
  }
}

final app = AppState();
