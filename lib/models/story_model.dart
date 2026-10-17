import 'package:cloud_firestore/cloud_firestore.dart';

class StoryModel {
  final String id;
  final String title;
  final String synopsis;
  final String genre;
  final String coverUrl;
  final String authorId;
  final String authorName;
  final DateTime? createdAt;

  StoryModel({
    required this.id,
    required this.title,
    required this.synopsis,
    required this.genre,
    required this.coverUrl,
    required this.authorId,
    required this.authorName,
    this.createdAt,
  });

  factory StoryModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return StoryModel(
      id: doc.id,
      title: data['title'] ?? '',
      synopsis: data['synopsis'] ?? '',
      genre: data['genre'] ?? 'عام',
      coverUrl: data['coverUrl'] ?? '',
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? 'كاتب حكاية',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'synopsis': synopsis,
      'genre': genre,
      'coverUrl': coverUrl,
      'authorId': authorId,
      'authorName': authorName,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
