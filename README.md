# haipad

منصة عربية لكتابة وقراءة القصص والروايات على غرار واتباد. مبنية بـ Flutter Web وتُنشر تلقائياً على Firebase Hosting، وكل البيانات تُقرأ وتُكتب من **Cloud Firestore** (لا توجد أي بيانات وهمية في الكود).

## الميزات
- حسابات (Google / بريد وكلمة مرور) وملف شخصي قابل للتعديل.
- كتابة القصص على شكل فصول: مسودات ونشر، وسوم، حالة (مستمرة/مكتملة)، تعديل وحذف.
- قراءة بفصول متعددة، أوضاع قراءة، تصويت، تعليقات على كل فصل، عدّاد قراءات.
- مكتبة شخصية وقوائم قراءة، متابعة الكتّاب، حائط الملف الشخصي.
- استكشاف وبحث (تصنيف، حالة، وسوم، ترتيب).
- غرف محادثة عامة ورسائل خاصة.

## الإعداد (مرة واحدة)
1. في Firebase Console للمشروع `haipad`: أنشئ قاعدة **Firestore** (Native mode).
2. فعّل في Authentication طريقتي **Google** و**Email/Password**، وأضف نطاق الموقع إلى النطاقات المصرّح بها.
3. انسخ محتوى `firestore.rules` إلى Firestore → Rules ثم **Publish**
   (أو: `firebase deploy --only firestore:rules`).
4. قيّد مفتاح الـ API في Google Cloud Console على نطاق موقعك.

## التشغيل محلياً
```
flutter pub get
flutter run -d chrome
```

## هيكل Firestore
| المسار | المحتوى |
|---|---|
| `users/{uid}` | الاسم، المعرّف، الصورة، النبذة، `followersCount`، `followingCount` |
| `users/{uid}/following`, `followers`, `library`, `lists`, `wall` | المتابعة، المكتبة، قوائم القراءة، الحائط |
| `stories/{id}` | بيانات القصة + `reads`, `votes`, `publishedChapters` |
| `stories/{id}/chapters/{cid}` | الفصول (`published` = false للمسودة) |
| `stories/{id}/comments`, `votes` | التعليقات (حقل `chapterId`) وتصويتات المستخدمين |
| `rooms/{room}/messages` | الغرف العامة: `writers`, `horror`, `romance` |
| `conversations/{uidA_uidB}` (+ `messages`) | الرسائل الخاصة |
