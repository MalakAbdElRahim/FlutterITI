import 'package:flutter/material.dart';
import '../Service/FirebaseAuthService.dart';
import 'LoginScreen.dart';

class Watched extends StatefulWidget {
  final VoidCallback toggleTheme;
  final String title;

  Watched({
    super.key,
    required this.title,
    required this.toggleTheme,
  });

  @override
  State<Watched> createState() => _WatchedState();
}

class _WatchedState extends State<Watched> {
  final FirebaseAuthService _authService = FirebaseAuthService();

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'Toggle Theme',
            onPressed: widget.toggleTheme,
          ),
          IconButton(
            icon: Icon(Icons.logout_outlined),
            tooltip: 'Logout',
            onPressed: () async {
              await _authService.logOut();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(toggleTheme: widget.toggleTheme),
                  ),
                );
              }
            },
          ),
        ],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text(
              "Watched Movies",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "No completed movies yet",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
