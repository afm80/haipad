import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/story_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // إضافة قصة جديدة
  Future<void> createStory({
    required String title,
    required String synopsis,
    required String genre,
    required String coverUrl,
    required String firstChapter,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    DocumentReference storyDoc = await _db.collection('stories').add({
      'title': title,
      'synopsis': synopsis,
      'genre': genre,
      'coverUrl': coverUrl,
      'authorId': user.uid,
      'authorName': user.displayName ?? 'كاتب حكاية',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await storyDoc.collection('chapters').add({
      'title': 'الفصل الأول',
      'content': firstChapter,
      'order': 1,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // جلب قائمة القصص
  Stream<List<StoryModel>> getStories() {
    return _db.collection('stories').orderBy('createdAt', descending: true).snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => StoryModel.fromFirestore(doc)).toList(),
        );
  }
}
