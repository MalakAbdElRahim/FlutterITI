import 'package:flutter/material.dart';

import '../Service/FirebaseAuthService.dart';
import 'LoginScreen.dart';
import '../Favorites.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title, required this.toggleTheme});
  final VoidCallback toggleTheme;
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuthService _authService = FirebaseAuthService();

  @override
  Widget build(BuildContext context) {

    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        
        title: Text("Main Page"),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'Toggle Theme',
            onPressed: widget.toggleTheme,
          ),
        ],
        leading: IconButton(
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
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        
        children: [
          Padding(
            padding: EdgeInsetsGeometry.all(16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
          ElevatedButton(
            onPressed: () {
              if (mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        Favorites(title: "Favorites", toggleTheme: widget.toggleTheme),
                  ),
                );
              }
              
            },
            child: Container(
              padding: EdgeInsets.all(8),
              
              decoration: BoxDecoration(
                
                borderRadius: BorderRadius.circular(4),
                
              ),
              child: Row(children: [Icon(Icons.favorite),
              SizedBox(width: 4,),
              Text("Favorites",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                
                ),
          
              )]),
            ),
          ),
          SizedBox(width: 8,),
          ElevatedButton(
            onPressed: () {
              if (mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        Favorites(title: "Favorites", toggleTheme: widget.toggleTheme),
                  ),
                );
              }
            },
            
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(children: [
                Icon(Icons.bookmark),
                SizedBox(width: 4,),
                Text("To Watch"
                ,style: TextStyle(
                fontWeight: FontWeight.bold,
                
                ),)]),

            ),
          ),

          SizedBox(width: 8,),
          ElevatedButton(
            onPressed: () {
              if (mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        Favorites(title: "Favorites", toggleTheme: widget.toggleTheme),
                  ),
                );
              }
            },
            
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(children: [
                Icon(Icons.check_circle),
                SizedBox(width: 4,),
                Text("Watched",
                style: TextStyle(
                fontWeight: FontWeight.bold,
                
                ),)]),
            ),
          ),
        ],
      ),
        
          ),
        ],
    ),

    );
  }
}
