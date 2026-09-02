import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'LoginScreen.dart';
import 'Homepage.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  const SplashScreen({super.key, required this.toggleTheme});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _showLogoPhase = true;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _initializeAndPlay();
    // Absolute failsafe: Never stay stuck on splash screen longer than 6 seconds
    Timer(const Duration(seconds: 6), () {
      if (mounted && !_hasNavigated) {
        _navigateNext();
      }
    });
  }

  void _initializeAndPlay() async {
    _controller = VideoPlayerController.asset('assets/videos/splash.mp4');

    try {
      await _controller.initialize().timeout(const Duration(seconds: 3));
      await _controller.setVolume(0.0);
      _controller.setLooping(false);

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
      Timer(const Duration(milliseconds: 2200), () {
        if (!mounted) return;
        setState(() {
          _showLogoPhase = false;
        });

        _controller.play();
        _controller.addListener(() {
          if (_controller.value.isInitialized &&
              _controller.value.position >= _controller.value.duration) {
            _navigateNext();
          }
        });
        final duration = _controller.value.duration.inSeconds > 0
            ? _controller.value.duration.inSeconds + 1
            : 4;
        Timer(Duration(seconds: duration), () {
          _navigateNext();
        });
      });
    } catch (e) {
      Timer(const Duration(milliseconds: 2200), () {
        if (!mounted) return;
        setState(() {
          _showLogoPhase = false;
        });
        Timer(const Duration(seconds: 3), () {
          _navigateNext();
        });
      });
    }
  }

  void _navigateNext() {
    if (!mounted || _hasNavigated) return;
    _hasNavigated = true;
    try {
      final user = FirebaseAuth.instance.currentUser;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => user != null
              ? HomePage(
                  title: "Main Page",
                  toggleTheme: widget.toggleTheme,
                )
              : LoginScreen(
                  toggleTheme: widget.toggleTheme,
                ),
        ),
      );
    } catch (_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(
            toggleTheme: widget.toggleTheme,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    if (_isInitialized) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 600),
          child: _showLogoPhase
              ? Column(
                  key: ValueKey('logo_phase'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Movies Data is provided by",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 20),
                    SvgPicture.asset(
                      'assets/images/TMDB.svg',
                      width: 160,
                    ),
                  ],
                )

              : Column(
                  key: ValueKey('video_phase'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isInitialized && !_controller.value.hasError)
                      SizedBox(
                        width: 250,
                        height: 250,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            child: VideoPlayer(_controller),
                          ),
                        ),
                      )
                    else
                      Icon(
                        Icons.movie_filter_rounded,
                        size: 100,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    SizedBox(height: 30),
                    Text(
                      "the curtains are opening...",
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Theme.of(context).colorScheme.onSurface,
                        letterSpacing: 1.1,
                      ),
                    ),
                    SizedBox(height: 24),
                    CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                      backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                      strokeWidth: 3,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
