import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Provider/FirebaseAuthProvider.dart';
import '../Controller/AuthController.dart';
import 'Homepage.dart';
import 'LoginScreen.dart';

class SignupScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  const SignupScreen({super.key, required this.toggleTheme});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool obscureText = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp(AuthController controller) async {
    final success = await controller.signUp(
      _emailController.text,
      _passwordController.text,
    );

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(
            title: "Main Page",
            toggleTheme: widget.toggleTheme,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<FirebaseAuthProvider>();
    final authController = AuthController(authProvider: authProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Movie player",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'Toggle Theme',
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: 60, left: 24, right: 24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.movie_rounded,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(height: 20),
              Text(
                "Welcome to movie player",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      authProvider.clearWarning();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginScreen(toggleTheme: widget.toggleTheme),
                        ),
                      );
                    },
                    child: Text(
                      "Or Log in instead from here",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.secondary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.amber[800] ?? Colors.amber,
                        size: 22,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "This app isn't intended for anyone below 18 years old. this app contains a large database of movies that might contain R-rated themes, Violence or immoral ideas. Always make sure to search for Parents guides and Trigger Warnings for the movie you want to watch. Safe Browsing!",
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.45,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 25),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autofillHints: [AutofillHints.email],
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                  labelText: "Email",
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: obscureText,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.key),
                  labelText: "Password",
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => obscureText = !obscureText),
                    icon: Icon(
                      obscureText ? Icons.visibility : Icons.visibility_off,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: authProvider.isLoading
                      ? null
                      : () => _handleSignUp(authController),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: authProvider.isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Theme.of(context).colorScheme.secondary, strokeWidth: 2.5),
                        )
                      : Text(
                          "Sign Up",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              SizedBox(height: 20),
              if (authProvider.warning.isNotEmpty)
                Text(
                  authProvider.warning,
                  style: TextStyle(
                    color: authProvider.warning.contains("Successful")
                        ? Colors.green
                        : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
