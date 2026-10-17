import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models.dart';

/// كل القراءة والكتابة في Firestore تمر من هنا.
class Repo {
  static FirebaseFirestore get _db => FirebaseFirestore.instance;
  static CollectionReference<Map<String, dynamic>> get _users => _db.collection('users');
  static CollectionReference<Map<String, dynamic>> get _stories => _db.collection('stories');
  static FieldValue get _now => FieldValue.serverTimestamp();

  static DateTime _far(DateTime? t) => t ?? DateTime.now();

  // ───────────── المستخدمون ─────────────
  static Future<void> ensureUser(User u) async {
    final ref = _users.doc(u.uid);
    final snap = await ref.get();
    if (snap.exists) return;
    final email = u.email ?? '';
    final local = email.contains('@') ? email.split('@').first : '';
    final shown = (u.displayName ?? '').trim();
    final name = shown.isNotEmpty ? shown : (local.isNotEmpty ? local : 'مستخدم');
    final clean = local.replaceAll(RegExp(r'[^A-Za-z0-9_.]'), '');
    final handle = clean.isNotEmpty ? '@$clean' : '@user${u.uid.substring(0, 5)}';
    await ref.set({
      'name': name,
      'handle': handle,
      'avatar': u.photoURL ?? '',
      'bio': '',
      'followersCount': 0,
      'followingCount': 0,
      'createdAt': _now,
    });
  }

  static Stream<UserProfile?> userStream(String uid) => _users
      .doc(uid)
      .snapshots()
      .map((d) => d.exists ? UserProfile.fromDoc(d) : null);

  static Future<void> setName(String uid, String name) =>
      _users.doc(uid).update({'name': name});

  static Future<void> updateProfile(String uid,
      {required String name, required String bio, required String avatar}) async {
    await _users.doc(uid).update({'name': name, 'bio': bio, 'avatar': avatar});
    final mine = await _stories.where('authorId', isEqualTo: uid).get();
    if (mine.docs.isEmpty) return;
    final b = _db.batch();
    for (final d in mine.docs) {
      b.update(d.reference, {'author': name, 'authorAvatar': avatar});
    }
    await b.commit();
  }

  // ───────────── المتابعة ─────────────
  static Stream<Set<String>> followingStream(String uid) => _users
      .doc(uid)
      .collection('following')
      .snapshots()
      .map((q) => q.docs.map((d) => d.id).toSet());

  static Future<void> setFollow(
      {required String me, required String target, required bool follow}) {
    final mine = _users.doc(me);
    final theirs = _users.doc(target);
    final b = _db.batch();
    final fing = mine.collection('following').doc(target);
    final fers = theirs.collection('followers').doc(me);
    if (follow) {
      b.set(fing, {'at': _now});
      b.set(fers, {'at': _now});
    } else {
      b.delete(fing);
      b.delete(fers);
    }
    b.update(theirs, {'followersCount': FieldValue.increment(follow ? 1 : -1)});
    b.update(mine, {'followingCount': FieldValue.increment(follow ? 1 : -1)});
    return b.commit();
  }

  // ───────────── القصص ─────────────
  static Stream<List<Story>> storiesStream() => _stories
      .orderBy('createdAt', descending: true)
      .limit(300)
      .snapshots()
      .map((q) => q.docs.map(Story.fromDoc).toList());

  static Stream<Story?> storyStream(String id) => _stories
      .doc(id)
      .snapshots()
      .map((d) => d.exists ? Story.fromDoc(d) : null);

  static Future<String> createStory({
    required UserProfile me,
    required String title,
    required String genre,
    required String cover,
    required String desc,
    required List<String> tags,
    required bool completed,
    required String chapterTitle,
    required String chapterContent,
    required bool publish,
  }) async {
    final sref = _stories.doc();
    final cref = sref.collection('chapters').doc();
    final b = _db.batch();
    b.set(sref, {
      'authorId': me.uid,
      'author': me.name,
      'authorHandle': me.handle,
      'authorAvatar': me.avatar,
      'title': title,
      'desc': desc,
      'genre': genre,
      'cover': cover,
      'tags': tags,
      'completed': completed,
      'reads': 0,
      'votes': 0,
      'publishedChapters': publish ? 1 : 0,
      'createdAt': _now,
      'updatedAt': _now,
    });
    b.set(cref, {
      'title': chapterTitle,
      'content': chapterContent,
      'order': DateTime.now().millisecondsSinceEpoch,
      'published': publish,
      'createdAt': _now,
      'updatedAt': _now,
    });
    await b.commit();
    return sref.id;
  }

  static Future<void> updateStory(
    String id, {
    required String title,
    required String genre,
    required String cover,
    required String desc,
    required List<String> tags,
    required bool completed,
  }) =>
      _stories.doc(id).update({
        'title': title,
        'genre': genre,
        'cover': cover,
        'desc': desc,
        'tags': tags,
        'completed': completed,
        'updatedAt': _now,
      });

  static Future<void> setCompleted(String id, bool v) =>
      _stories.doc(id).update({'completed': v, 'updatedAt': _now});

  static Future<void> _deleteAll(Query<Map<String, dynamic>> q) async {
    final snap = await q.get();
    for (var i = 0; i < snap.docs.length; i += 400) {
      final b = _db.batch();
      for (final d in snap.docs.skip(i).take(400)) {
        b.delete(d.reference);
      }
      await b.commit();
    }
  }

  static Future<void> deleteStory(String id) async {
    final sref = _stories.doc(id);
    await _deleteAll(sref.collection('chapters'));
    await _deleteAll(sref.collection('comments'));
    await _deleteAll(sref.collection('votes'));
    await sref.delete();
  }

  /// يزيد عدّاد القراءات بمقدار واحد.
  static Future<void> countRead(String sid) =>
      _stories.doc(sid).update({'reads': FieldValue.increment(1)});

  // ───────────── الفصول ─────────────
  static Stream<List<Chapter>> chaptersStream(String sid, {bool all = false}) {
    Query<Map<String, dynamic>> q = _stories.doc(sid).collection('chapters');
    if (!all) q = q.where('published', isEqualTo: true);
    return q.snapshots().map((s) {
      final l = s.docs.map(Chapter.fromDoc).toList();
      l.sort((a, b) => a.order.compareTo(b.order));
      return l;
    });
  }

  static Future<void> saveChapter({
    required String storyId,
    Chapter? chapter,
    required String title,
    required String content,
    required bool publish,
  }) {
    final sref = _stories.doc(storyId);
    final cref = sref.collection('chapters').doc(chapter?.id);
    final b = _db.batch();
    if (chapter == null) {
      b.set(cref, {
        'title': title,
        'content': content,
        'published': publish,
        'order': DateTime.now().millisecondsSinceEpoch,
        'createdAt': _now,
        'updatedAt': _now,
      });
    } else {
      b.update(cref, {
        'title': title,
        'content': content,
        'published': publish,
        'updatedAt': _now,
      });
    }
    final delta = (publish ? 1 : 0) - ((chapter?.published ?? false) ? 1 : 0);
    final upd = <String, dynamic>{'updatedAt': _now};
    if (delta != 0) upd['publishedChapters'] = FieldValue.increment(delta);
    b.update(sref, upd);
    return b.commit();
  }

  static Future<void> deleteChapter(String storyId, Chapter c) async {
    final sref = _stories.doc(storyId);
    await _deleteAll(sref.collection('comments').where('chapterId', isEqualTo: c.id));
    final b = _db.batch();
    b.delete(sref.collection('chapters').doc(c.id));
    if (c.published) {
      b.update(sref, {'publishedChapters': FieldValue.increment(-1)});
    }
    await b.commit();
  }

  // ───────────── التعليقات ─────────────
  static Stream<List<Comment>> commentsStream(String sid, String chapterId) => _stories
          .doc(sid)
          .collection('comments')
          .where('chapterId', isEqualTo: chapterId)
          .snapshots()
          .map((q) {
        final l = q.docs.map(Comment.fromDoc).toList();
        l.sort((a, b) => _far(b.createdAt).compareTo(_far(a.createdAt)));
        return l;
      });

  static Future<void> addComment(
      {required String sid,
      required String chapterId,
      required UserProfile me,
      required String text}) {
    return _stories.doc(sid).collection('comments').add({
      'chapterId': chapterId,
      'uid': me.uid,
      'user': me.name,
      'avatar': me.avatar,
      'text': text,
      'createdAt': _now,
    });
  }

  static Future<void> deleteComment(String sid, String id) =>
      _stories.doc(sid).collection('comments').doc(id).delete();

  // ───────────── التصويت ─────────────
  static Stream<bool> votedStream(String sid, String uid) => _stories
      .doc(sid)
      .collection('votes')
      .doc(uid)
      .snapshots()
      .map((d) => d.exists);

  static Future<void> toggleVote(String sid, String uid) {
    final sref = _stories.doc(sid);
    final vref = sref.collection('votes').doc(uid);
    return _db.runTransaction((tx) async {
      final v = await tx.get(vref);
      if (v.exists) {
        tx.delete(vref);
        tx.update(sref, {'votes': FieldValue.increment(-1)});
      } else {
        tx.set(vref, {'at': _now});
        tx.update(sref, {'votes': FieldValue.increment(1)});
      }
    });
  }

  // ───────────── المكتبة وقوائم القراءة ─────────────
  static Stream<Set<String>> libraryStream(String uid) => _users
      .doc(uid)
      .collection('library')
      .snapshots()
      .map((q) => q.docs.map((d) => d.id).toSet());

  static Future<void> setLibrary(String uid, String sid, bool add) {
    final ref = _users.doc(uid).collection('library').doc(sid);
    return add ? ref.set({'addedAt': _now}) : ref.delete();
  }

  static Stream<List<ReadingList>> listsStream(String uid) => _users
      .doc(uid)
      .collection('lists')
      .snapshots()
      .map((q) => q.docs.map(ReadingList.fromDoc).toList());

  static Future<void> createList(String uid, String name, {String? storyId}) =>
      _users.doc(uid).collection('lists').add({
        'name': name,
        'storyIds': storyId == null ? <String>[] : <String>[storyId],
        'createdAt': _now,
      });

  static Future<void> toggleInList(String uid, String listId, String sid, bool add) =>
      _users.doc(uid).collection('lists').doc(listId).update({
        'storyIds': add ? FieldValue.arrayUnion([sid]) : FieldValue.arrayRemove([sid]),
      });

  static Future<void> deleteList(String uid, String listId) =>
      _users.doc(uid).collection('lists').doc(listId).delete();

  // ───────────── حائط الملف الشخصي ─────────────
  static Stream<List<WallPost>> wallStream(String uid) => _users
      .doc(uid)
      .collection('wall')
      .orderBy('createdAt', descending: true)
      .limit(50)
      .snapshots()
      .map((q) => q.docs.map(WallPost.fromDoc).toList());

  static Future<void> postWall(String uid, UserProfile me, String text) =>
      _users.doc(uid).collection('wall').add({
        'authorId': me.uid,
        'user': me.name,
        'avatar': me.avatar,
        'text': text,
        'createdAt': _now,
      });

  static Future<void> deleteWall(String uid, String id) =>
      _users.doc(uid).collection('wall').doc(id).delete();

  // ───────────── الغرف العامة ─────────────
  static Stream<List<ChatMsg>> roomStream(String room) => _db
      .collection('rooms')
      .doc(room)
      .collection('messages')
      .orderBy('createdAt', descending: true)
      .limit(100)
      .snapshots()
      .map((q) => q.docs.map(ChatMsg.fromDoc).toList());

  static Future<void> sendRoom(String room, UserProfile me, String text) => _db
          .collection('rooms')
          .doc(room)
          .collection('messages')
          .add({
        'uid': me.uid,
        'user': me.name,
        'text': text,
        'createdAt': _now,
      });

  // ───────────── الرسائل الخاصة ─────────────
  static String convId(String a, String b) {
    final l = [a, b]..sort();
    return '${l[0]}_${l[1]}';
  }

  static Stream<List<Conversation>> conversationsStream(String uid) => _db
          .collection('conversations')
          .where('participants', arrayContains: uid)
          .snapshots()
          .map((q) {
        final l = q.docs.map(Conversation.fromDoc).toList();
        l.sort((a, b) => _far(b.updatedAt).compareTo(_far(a.updatedAt)));
        return l;
      });

  static Stream<List<ChatMsg>> dmStream(String convId) => _db
      .collection('conversations')
      .doc(convId)
      .collection('messages')
      .orderBy('createdAt', descending: true)
      .limit(200)
      .snapshots()
      .map((q) => q.docs.map(ChatMsg.fromDoc).toList());

  static Future<void> sendDm({
    required UserProfile me,
    required String peerUid,
    required String peerName,
    required String peerAvatar,
    required String text,
  }) {
    final id = convId(me.uid, peerUid);
    final cref = _db.collection('conversations').doc(id);
    final parts = [me.uid, peerUid]..sort();
    final b = _db.batch();
    b.set(
        cref,
        {
          'participants': parts,
          'names': {me.uid: me.name, peerUid: peerName},
          'avatars': {me.uid: me.avatar, peerUid: peerAvatar},
          'lastMsg': text,
          'updatedAt': _now,
        },
        SetOptions(merge: true));
    b.set(cref.collection('messages').doc(), {
      'uid': me.uid,
      'user': me.name,
      'text': text,
      'createdAt': _now,
    });
    return b.commit();
  }
}
