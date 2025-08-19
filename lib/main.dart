import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

import 'providers/booking_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/space_provider.dart';
import 'screens/my_bookings_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Initialize minimal local notifications in the background isolate
  await NotificationService.initializeLocalOnly();
  await NotificationService.handleBackgroundMessage(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize notifications
  await NotificationService.initialize(onTap: _handleNotificationTap);

  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const CoworkingApp());
}

final GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();

// Decide where to go based on data payload from the push
void _handleNotificationTap(Map<String, dynamic> data) {
  final route = data['screen'];
  if (route == 'notifications') {
    _navKey.currentState?.push(
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
  } else if (route == 'bookings') {
    _navKey.currentState?.push(
      MaterialPageRoute(builder: (_) => const MyBookingsScreen()),
    );
  }
  // Add more branches as needed
}

class CoworkingApp extends StatelessWidget {
  const CoworkingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SpaceProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MaterialApp(
        navigatorKey: _navKey,
        title: 'Coworking Booking',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: const Color(0xFF2196F3),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF2196F3),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
        ),
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
