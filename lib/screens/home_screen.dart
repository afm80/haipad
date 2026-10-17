import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/story_model.dart';
import 'create_story_screen.dart';
import 'story_details_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final DatabaseService _dbService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('حكاية - Hekaya', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          if (user == null)
            IconButton(
              icon: const Icon(Icons.login),
              onPressed: () async {
                await _authService.signInWithGoogle();
                setState(() {});
              },
            )
          else
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(user.photoURL ?? ''),
                ),
              ),
            ),
        ],
      ),
      body: StreamBuilder<List<StoryModel>>(
        stream: _dbService.getStories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('لا توجد قصص بعد، كن أول من ينشر قصة!'));
          }

          final stories = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: stories.length,
            itemBuilder: (context, index) {
              final story = stories[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: story.coverUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(story.coverUrl, width: 60, height: 90, fit: BoxFit.cover),
                        )
                      : Container(width: 60, height: 90, color: Colors.grey[300], child: const Icon(Icons.book)),
                  title: Text(story.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('الكاتب: ${story.authorName} • التصنيف: ${story.genre}'),
                      const SizedBox(height: 6),
                      Text(story.synopsis, maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StoryDetailsScreen(storyId: story.id, title: story.title),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_authService.currentUser == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('الرجاء تسجيل الدخول أولاً لنشر قصة')),
            );
            return;
          }
          Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateStoryScreen()));
        },
        icon: const Icon(Icons.edit),
        label: const Text('كتابة قصة'),
      ),
    );
  }
}
