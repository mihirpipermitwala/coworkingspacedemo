import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/space_provider.dart';
import '../providers/booking_provider.dart';
import '../providers/notification_provider.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    // Load initial data
    await Future.wait([
      context.read<SpaceProvider>().loadSpaces(),
      context.read<BookingProvider>().loadBookings(),
      context.read<NotificationProvider>().loadNotifications(),
    ]);

    // Wait for animation to complete
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2196F3),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.work_outline,
                  size: 60,
                  color: Color(0xFF2196F3),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'CoWorking',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Find Your Perfect Workspace',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
