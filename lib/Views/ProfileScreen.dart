import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Provider/FirebaseAuthProvider.dart';
import '../Provider/WatchlistProvider.dart';
import '../Widgets/InfoTileWidget.dart';
import 'LoginScreen.dart';
import 'FavoritesScreen.dart';
import 'WatchingScreen.dart';
import 'ToWatchScreen.dart';
import 'WatchedScreen.dart';
import 'ChangePasswordScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback toggleTheme;

  const ProfileScreen({super.key, required this.toggleTheme});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final watchlistProvider = context.watch<WatchlistProvider>();
    final authProvider = context.watch<FirebaseAuthProvider>();

    final email = authProvider.user?.email ??
        FirebaseAuth.instance.currentUser?.email ??
        'guest';
    final initial = email.isNotEmpty ? email[0].toUpperCase() : 'U';

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'Toggle Theme',
            onPressed: toggleTheme,
          ),
        ],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      initial,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    email,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                ],
              ),
            ),

            SizedBox(height: 28),

            InfoTileWidget(
              icon: Icons.lock_outline,
              iconColor: Colors.blueAccent,
              title: 'Change Password',
              value: '',
              onTap: () {
                authProvider.clearWarning();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangePasswordScreen(
                      toggleTheme: toggleTheme,
                    ),
                  ),
                );
              },
            ),
            InfoTileWidget(
              icon: Icons.favorite,
              iconColor: Colors.red,
              title: 'Favorites',
              value: '${watchlistProvider.favorites.length}',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Favorites(
                    title: 'Favorites',
                    toggleTheme: toggleTheme,
                  ),
                ),
              ),
            ),
            InfoTileWidget(
              icon: Icons.play_circle_fill,
              iconColor: Colors.blueAccent,
              title: 'Currently Watching',
              value: '${watchlistProvider.watching.length}',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WatchingScreen(
                    title: 'Currently Watching',
                    toggleTheme: toggleTheme,
                  ),
                ),
              ),
            ),
            InfoTileWidget(
              icon: Icons.bookmark,
              iconColor: Colors.orangeAccent,
              title: 'Want to Watch',
              value: '${watchlistProvider.toWatch.length}',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ToWatch(
                    title: 'Want to Watch',
                    toggleTheme: toggleTheme,
                  ),
                ),
              ),
            ),
            InfoTileWidget(
              icon: Icons.check_circle,
              iconColor: Colors.green,
              title: 'Watched',
              value: '${watchlistProvider.watched.length}',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Watched(
                    title: 'Watched',
                    toggleTheme: toggleTheme,
                  ),
                ),
              ),
            ),

            SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await authProvider.signOut();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginScreen(toggleTheme: toggleTheme),
                      ),
                      (route) => false,
                    );
                  }
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.red.withValues(alpha: 0.5), width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: Icon(Icons.logout, color: Colors.red),
                label: Text(
                  'Log Out',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
