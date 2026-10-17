import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';
import 'login_page.dart';
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

  Widget _loader() => const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: AppColors.brand500)),
      );

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.changes,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) return _loader();
        if (snap.data == null) return const LoginPage();
        return ListenableBuilder(
          listenable: app,
          builder: (context, _) {
            if (app.fatal != null) return _errorScreen();
            if (app.me == null) return _loader();
            return _shell(context);
          },
        );
      },
    );
  }

  Widget _errorScreen() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off, size: 48, color: AppColors.slate400),
                  const SizedBox(height: 16),
                  Text(app.fatal ?? '',
                      textAlign: TextAlign.center,
                      style: cairo(14, color: AppColors.slate700, height: 1.6)),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: AuthService.signOut,
                    child: Text('تسجيل الخروج',
                        style: cairo(14, weight: FontWeight.w700, color: AppColors.brand500)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _shell(BuildContext context) {
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
          key: ValueKey('${app.page}/${app.viewUid}/${app.readingId}'),
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
  }
}
