import 'package:flutter/material.dart';
import 'data.dart';
import 'theme.dart';
import 'widgets.dart';
import 'pages/home_page.dart';
import 'pages/browse_pages.dart';
import 'pages/reader_page.dart';
import 'pages/chats_page.dart';
import 'pages/profile_page.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  Widget _page() {
    switch (app.page) {
      case 'explore':
        return ExplorePage();
      case 'library':
        return LibraryPage();
      case 'my-stories':
        return MyStoriesPage();
      case 'story-reader':
        return ReaderPage();
      case 'chats':
        return ChatsPage();
      case 'profile':
        return ProfilePage();
      default:
        return HomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final w = MediaQuery.of(context).size.width;
        final px = pagePadding(w);
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: AppColors.slate50,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(65),
              child: AppHeader(),
            ),
            bottomNavigationBar: w >= 1100 ? null : MobileBar(),
            body: SingleChildScrollView(
              key: ValueKey(app.page),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1280),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(px, 24, px, 24),
                    child: _page(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
