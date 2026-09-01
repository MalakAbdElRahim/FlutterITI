import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Service/FirebaseAuthService.dart';
import '../Provider/WatchlistProvider.dart';
import 'LoginScreen.dart';
import 'FavoritesScreen.dart';
import 'WatchingScreen.dart';
import 'ToWatchScreen.dart';
import 'WatchedScreen.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback toggleTheme;

  ProfileScreen({
    super.key,
    required this.toggleTheme,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuthService _authService = FirebaseAuthService();

  Widget _buildInfoTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            if (onTap != null) ...[
              SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final watchlistProvider = context.watch<WatchlistProvider>();
    final user = _authService.currentUser;
    final email = user?.email ?? "guest@onetapcinema.com";
    final initial = email.isNotEmpty ? email[0].toUpperCase() : "U";

    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'Toggle Theme',
            onPressed: widget.toggleTheme,
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
            // User Avatar & Name Banner
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
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "One Tap Cinema Member",
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 28),

            // Account & List Stats Section
            _buildInfoTile(
              context: context,
              icon: Icons.email_outlined,
              iconColor: Colors.teal,
              title: "Email",
              value: email,
            ),
            _buildInfoTile(
              context: context,
              icon: Icons.favorite,
              iconColor: Colors.red,
              title: "Favorites",
              value: "${watchlistProvider.favorites.length}",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Favorites(
                      title: "Favorites",
                      toggleTheme: widget.toggleTheme,
                    ),
                  ),
                );
              },
            ),
            _buildInfoTile(
              context: context,
              icon: Icons.play_circle_fill,
              iconColor: Colors.blueAccent,
              title: "Currently Watching",
              value: "${watchlistProvider.watching.length}",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WatchingScreen(
                      title: "Currently Watching",
                      toggleTheme: widget.toggleTheme,
                    ),
                  ),
                );
              },
            ),
            _buildInfoTile(
              context: context,
              icon: Icons.bookmark,
              iconColor: Colors.orangeAccent,
              title: "Want to Watch",
              value: "${watchlistProvider.toWatch.length}",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ToWatch(
                      title: "Want to Watch",
                      toggleTheme: widget.toggleTheme,
                    ),
                  ),
                );
              },
            ),
            _buildInfoTile(
              context: context,
              icon: Icons.check_circle,
              iconColor: Colors.green,
              title: "Watched",
              value: "${watchlistProvider.watched.length}",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Watched(
                      title: "Watched",
                      toggleTheme: widget.toggleTheme,
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: 32),

            // Log Out Button with Red Font
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await _authService.logOut();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginScreen(toggleTheme: widget.toggleTheme),
                      ),
                      (route) => false,
                    );
                  }
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.red.withValues(alpha: 0.5), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: Icon(Icons.logout, color: Colors.red),
                label: Text(
                  "Log Out",
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
