import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StoryDetailsScreen extends StatelessWidget {
  final String storyId;
  final String title;

  const StoryDetailsScreen({super.key, required this.storyId, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('stories')
            .doc(storyId)
            .collection('chapters')
            .orderBy('order')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('لا توجد فصول في هذه القصة بعد.'));
          }

          final chapters = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: chapters.length,
            itemBuilder: (context, index) {
              final chapter = chapters[index].data() as Map<String, dynamic>;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chapter['title'] ?? 'فصل بدون عنوان',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    chapter['content'] ?? '',
                    style: const TextStyle(fontSize: 18, height: 1.8),
                  ),
                  const SizedBox(height: 30),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
