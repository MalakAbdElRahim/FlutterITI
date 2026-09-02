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
  Timer? _failsafeTimer;

  @override
  void initState() {
    super.initState();
    _initializeAndPlay();
  }

  void _startFailsafe(Duration timeout) {
    _failsafeTimer?.cancel();
    _failsafeTimer = Timer(timeout, () {
      if (mounted && !_hasNavigated) {
        _navigateNext();
      }
    });
  }

  void _initializeAndPlay() async {
    _controller = VideoPlayerController.asset('assets/videos/splash.mp4');

    try {
      await _controller.initialize().timeout(const Duration(seconds: 5));
      await _controller.setVolume(0.0);
      _controller.setLooping(false);

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }

      final videoDurationMs = _controller.value.duration.inMilliseconds;
      const logoPhaseMs = 2200;
      final totalMs = logoPhaseMs + videoDurationMs + 2000;
      _startFailsafe(Duration(milliseconds: totalMs));

      Timer(const Duration(milliseconds: logoPhaseMs), () {
        if (!mounted) return;
        setState(() {
          _showLogoPhase = false;
        });

        _controller.play();

        _controller.addListener(() {
          final value = _controller.value;
          if (value.isInitialized &&
              !value.hasError &&
              value.duration > Duration.zero &&
              value.position >= value.duration) {
            _navigateNext();
          }
        });
      });
    } catch (e) {
      _startFailsafe(const Duration(milliseconds: 5200));

      Timer(const Duration(milliseconds: 2200), () {
        if (!mounted) return;
        setState(() {
          _showLogoPhase = false;
        });
      });
    }
  }

  void _navigateNext() {
    if (!mounted || _hasNavigated) return;
    _hasNavigated = true;
    _failsafeTimer?.cancel();
    try {
      final user = FirebaseAuth.instance.currentUser;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => user != null
              ? HomePage(title: 'Main Page', toggleTheme: widget.toggleTheme)
              : LoginScreen(toggleTheme: widget.toggleTheme),
        ),
      );
    } catch (_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(toggleTheme: widget.toggleTheme),
        ),
      );
    }
  }

  @override
  void dispose() {
    _failsafeTimer?.cancel();
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
          duration: const Duration(milliseconds: 600),
          child: _showLogoPhase
              ? Column(
                  key: const ValueKey('logo_phase'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Movies Data is provided by',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SvgPicture.asset('assets/images/TMDB.svg', width: 160),
                  ],
                )
              : Column(
                  key: const ValueKey('video_phase'),
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
                    const SizedBox(height: 30),
                    Text(
                      'the curtains are opening...',
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Theme.of(context).colorScheme.onSurface,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 24),
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
