import 'package:cloud_firestore/cloud_firestore.dart';

String _s(Map<String, dynamic> m, String k) {
  final v = m[k];
  return v is String ? v : '';
}

int _i(Map<String, dynamic> m, String k) {
  final v = m[k];
  return v is num ? v.toInt() : 0;
}

DateTime? _t(Map<String, dynamic> m, String k) {
  final v = m[k];
  return v is Timestamp ? v.toDate() : null;
}

List<String> _list(Map<String, dynamic> m, String k) {
  final v = m[k];
  return v is List ? v.whereType<String>().toList() : <String>[];
}

Map<String, String> _map(Map<String, dynamic> m, String k) {
  final v = m[k];
  if (v is! Map) return <String, String>{};
  return v.map((key, value) => MapEntry(key.toString(), value.toString()));
}

class UserProfile {
  final String uid, name, handle, avatar, bio;
  final int followers, following;
  const UserProfile({
    required this.uid,
    required this.name,
    required this.handle,
    required this.avatar,
    required this.bio,
    required this.followers,
    required this.following,
  });

  factory UserProfile.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? <String, dynamic>{};
    final name = _s(m, 'name');
    return UserProfile(
      uid: d.id,
      name: name.isEmpty ? 'مستخدم' : name,
      handle: _s(m, 'handle'),
      avatar: _s(m, 'avatar'),
      bio: _s(m, 'bio'),
      followers: _i(m, 'followersCount'),
      following: _i(m, 'followingCount'),
    );
  }
}

class Story {
  final String id, authorId, author, authorHandle, authorAvatar;
  final String title, desc, genre, cover;
  final List<String> tags;
  final bool completed;
  final int reads, votes, publishedChapters;
  final DateTime? createdAt;
  const Story({
    required this.id,
    required this.authorId,
    required this.author,
    required this.authorHandle,
    required this.authorAvatar,
    required this.title,
    required this.desc,
    required this.genre,
    required this.cover,
    required this.tags,
    required this.completed,
    required this.reads,
    required this.votes,
    required this.publishedChapters,
    required this.createdAt,
  });

  factory Story.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? <String, dynamic>{};
    return Story(
      id: d.id,
      authorId: _s(m, 'authorId'),
      author: _s(m, 'author'),
      authorHandle: _s(m, 'authorHandle'),
      authorAvatar: _s(m, 'authorAvatar'),
      title: _s(m, 'title'),
      desc: _s(m, 'desc'),
      genre: _s(m, 'genre'),
      cover: _s(m, 'cover'),
      tags: _list(m, 'tags'),
      completed: m['completed'] == true,
      reads: _i(m, 'reads'),
      votes: _i(m, 'votes'),
      publishedChapters: _i(m, 'publishedChapters'),
      createdAt: _t(m, 'createdAt'),
    );
  }
}

class Chapter {
  final String id, title, content;
  final int order;
  final bool published;
  const Chapter({
    required this.id,
    required this.title,
    required this.content,
    required this.order,
    required this.published,
  });

  factory Chapter.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? <String, dynamic>{};
    return Chapter(
      id: d.id,
      title: _s(m, 'title'),
      content: _s(m, 'content'),
      order: _i(m, 'order'),
      published: m['published'] == true,
    );
  }
}

class Comment {
  final String id, uid, user, avatar, text, chapterId;
  final DateTime? createdAt;
  const Comment({
    required this.id,
    required this.uid,
    required this.user,
    required this.avatar,
    required this.text,
    required this.chapterId,
    required this.createdAt,
  });

  factory Comment.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? <String, dynamic>{};
    return Comment(
      id: d.id,
      uid: _s(m, 'uid'),
      user: _s(m, 'user'),
      avatar: _s(m, 'avatar'),
      text: _s(m, 'text'),
      chapterId: _s(m, 'chapterId'),
      createdAt: _t(m, 'createdAt'),
    );
  }
}

/// رسالة في غرفة عامة أو محادثة خاصة.
class ChatMsg {
  final String id, uid, user, text;
  final DateTime? createdAt;
  const ChatMsg({
    required this.id,
    required this.uid,
    required this.user,
    required this.text,
    required this.createdAt,
  });

  factory ChatMsg.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? <String, dynamic>{};
    return ChatMsg(
      id: d.id,
      uid: _s(m, 'uid'),
      user: _s(m, 'user'),
      text: _s(m, 'text'),
      createdAt: _t(m, 'createdAt'),
    );
  }
}

class Conversation {
  final String id, lastMsg;
  final List<String> participants;
  final Map<String, String> names, avatars;
  final DateTime? updatedAt;
  const Conversation({
    required this.id,
    required this.lastMsg,
    required this.participants,
    required this.names,
    required this.avatars,
    required this.updatedAt,
  });

  factory Conversation.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? <String, dynamic>{};
    return Conversation(
      id: d.id,
      lastMsg: _s(m, 'lastMsg'),
      participants: _list(m, 'participants'),
      names: _map(m, 'names'),
      avatars: _map(m, 'avatars'),
      updatedAt: _t(m, 'updatedAt'),
    );
  }

  String peerUid(String me) =>
      participants.firstWhere((p) => p != me, orElse: () => me);
  String peerName(String me) => names[peerUid(me)] ?? 'مستخدم';
  String peerAvatar(String me) => avatars[peerUid(me)] ?? '';
}

class WallPost {
  final String id, authorId, user, avatar, text;
  final DateTime? createdAt;
  const WallPost({
    required this.id,
    required this.authorId,
    required this.user,
    required this.avatar,
    required this.text,
    required this.createdAt,
  });

  factory WallPost.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? <String, dynamic>{};
    return WallPost(
      id: d.id,
      authorId: _s(m, 'authorId'),
      user: _s(m, 'user'),
      avatar: _s(m, 'avatar'),
      text: _s(m, 'text'),
      createdAt: _t(m, 'createdAt'),
    );
  }
}

class ReadingList {
  final String id, name;
  final List<String> storyIds;
  const ReadingList({required this.id, required this.name, required this.storyIds});

  factory ReadingList.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? <String, dynamic>{};
    return ReadingList(id: d.id, name: _s(m, 'name'), storyIds: _list(m, 'storyIds'));
  }
}
