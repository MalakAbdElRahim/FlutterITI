import 'package:flutter/material.dart';

import 'Service/FirebaseAuthService.dart';
import 'Views/LoginScreen.dart';


class Watched extends StatefulWidget {
  const Watched({super.key, required this.title, required this.toggleTheme});
  final VoidCallback toggleTheme;
  final String title;

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
        title: Text("watched"),
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
                  builder: (context) =>
                      LoginScreen(toggleTheme: widget.toggleTheme),
                ),
              );
            }
          },
        ),
        ],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          tooltip: 'back',
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Row(),
    );
  }
}
