import 'package:flutter/material.dart';
import '../services/database_service.dart';

class CreateStoryScreen extends StatefulWidget {
  const CreateStoryScreen({super.key});

  @override
  State<CreateStoryScreen> createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends State<CreateStoryScreen> {
  final _titleController = TextEditingController();
  final _synopsisController = TextEditingController();
  final _coverController = TextEditingController();
  final _firstChapterController = TextEditingController();
  
  String _selectedGenre = 'رومانسية';
  bool _isLoading = false;

  final List<String> _genres = ['رومانسية', 'خيال', 'غموض', 'رعب', 'دراما', 'مغامرة', 'فنتازيا'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('نشر حكاية جديدة')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'عنوان القصة', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedGenre,
              decoration: const InputDecoration(labelText: 'تصنيف القصة', border: OutlineInputBorder()),
              items: _genres.map((genre) => DropdownMenuItem(value: genre, child: Text(genre))).toList(),
              onChanged: (val) => setState(() => _selectedGenre = val!),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _coverController,
              decoration: const InputDecoration(labelText: 'رابط صورة الغلاف (URL)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _synopsisController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'نبذة عن القصة', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _firstChapterController,
              maxLines: 8,
              decoration: const InputDecoration(labelText: 'محتوى الفصل الأول', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                    onPressed: () async {
                      if (_titleController.text.isEmpty || _firstChapterController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('الرجاء كتابة العنوان والفصل الأول على الأقل')),
                        );
                        return;
                      }

                      setState(() => _isLoading = true);
                      await DatabaseService().createStory(
                        title: _titleController.text,
                        synopsis: _synopsisController.text,
                        genre: _selectedGenre,
                        coverUrl: _coverController.text,
                        firstChapter: _firstChapterController.text,
                      );
                      setState(() => _isLoading = false);

                      if (mounted) Navigator.pop(context);
                    },
                    child: const Text('نشر القصة الآن', style: TextStyle(fontSize: 18)),
                  ),
          ],
        ),
      ),
    );
  }
}
