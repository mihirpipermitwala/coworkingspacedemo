import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/coworking_space_model.dart';
import '../models/booking_model.dart';
import '../models/notification_model.dart';

class ApiService {
  static const String _spacesKey = 'coworking_spaces';
  static const String _bookingsKey = 'user_bookings';
  static const String _notificationsKey = 'user_notifications';

  // Mock API delay to simulate network calls
  static Future<void> _delay() async {
    await Future.delayed(Duration(milliseconds: 500 + Random().nextInt(1000)));
  }

  static Future<List<CoworkingSpaceModel>> getCoworkingSpaces() async {
    await _delay();

    final prefs = await SharedPreferences.getInstance();
    final String? spacesJson = prefs.getString(_spacesKey);

    if (spacesJson != null) {
      final List<dynamic> spacesList = json.decode(spacesJson);
      return spacesList
          .map((json) => CoworkingSpaceModel.fromJson(json))
          .toList();
    }

    // Initialize with mock data if not found
    final mockSpaces = _getMockSpaces();
    await _saveSpaces(mockSpaces);
    return mockSpaces;
  }

  static Future<void> _saveSpaces(List<CoworkingSpaceModel> spaces) async {
    final prefs = await SharedPreferences.getInstance();
    final spacesJson = json.encode(
      spaces.map((space) => space.toJson()).toList(),
    );
    await prefs.setString(_spacesKey, spacesJson);
  }

  static List<CoworkingSpaceModel> _getMockSpaces() {
    return [
      CoworkingSpaceModel(
        id: '1',
        name: 'TechHub Mumbai',
        location: 'Bandra Kurla Complex, Mumbai',
        city: 'Mumbai',
        pricePerHour: 150.0,
        latitude: 19.0596,
        longitude: 72.8295,
        images: [
          'https://images.unsplash.com/photo-1497366216548-37526070297c?w=800',
          'https://images.unsplash.com/photo-1497366412874-3415097a27e7?w=800',
        ],
        description:
            'A modern coworking space in the heart of Mumbai\'s business district.',
        amenities: [
          'High-speed WiFi',
          'Meeting Rooms',
          'Coffee Bar',
          'Parking',
          '24/7 Access',
        ],
        operatingHours: {
          'Monday': '9:00 AM - 10:00 PM',
          'Tuesday': '9:00 AM - 10:00 PM',
          'Wednesday': '9:00 AM - 10:00 PM',
          'Thursday': '9:00 AM - 10:00 PM',
          'Friday': '9:00 AM - 10:00 PM',
          'Saturday': '10:00 AM - 8:00 PM',
          'Sunday': '10:00 AM - 6:00 PM',
        },
        rating: 4.5,
        capacity: 50,
      ),
      CoworkingSpaceModel(
        id: '2',
        name: 'Creative Space Delhi',
        location: 'Connaught Place, New Delhi',
        city: 'Delhi',
        pricePerHour: 120.0,
        latitude: 28.6315,
        longitude: 77.2167,
        images: [
          'https://images.unsplash.com/photo-1497366754035-f200968a6e72?w=800',
          'https://images.unsplash.com/photo-1519389950473-47ba0277781c?w=800',
        ],
        description:
            'A creative workspace designed for innovators and entrepreneurs.',
        amenities: [
          'High-speed WiFi',
          'Printing',
          'Event Space',
          'Kitchen',
          'Lockers',
        ],
        operatingHours: {
          'Monday': '8:00 AM - 9:00 PM',
          'Tuesday': '8:00 AM - 9:00 PM',
          'Wednesday': '8:00 AM - 9:00 PM',
          'Thursday': '8:00 AM - 9:00 PM',
          'Friday': '8:00 AM - 9:00 PM',
          'Saturday': '9:00 AM - 7:00 PM',
          'Sunday': 'Closed',
        },
        rating: 4.2,
        capacity: 40,
      ),
      CoworkingSpaceModel(
        id: '3',
        name: 'Startup Hub Bangalore',
        location: 'Koramangala, Bangalore',
        city: 'Bangalore',
        pricePerHour: 180.0,
        latitude: 12.9279,
        longitude: 77.6271,
        images: [
          'https://images.unsplash.com/photo-1497366811353-6870744d04b2?w=800',
          'https://images.unsplash.com/photo-1556761175-4b46a572b786?w=800',
        ],
        description:
            'The premier startup ecosystem hub in India\'s Silicon Valley.',
        amenities: [
          'High-speed WiFi',
          'Conference Rooms',
          'Gaming Zone',
          'Gym',
          'Cafe',
        ],
        operatingHours: {
          'Monday': '24/7',
          'Tuesday': '24/7',
          'Wednesday': '24/7',
          'Thursday': '24/7',
          'Friday': '24/7',
          'Saturday': '24/7',
          'Sunday': '24/7',
        },
        rating: 4.8,
        capacity: 100,
      ),
      CoworkingSpaceModel(
        id: '4',
        name: 'Ocean View Workspace',
        location: 'Marine Drive, Mumbai',
        city: 'Mumbai',
        pricePerHour: 200.0,
        latitude: 18.9433,
        longitude: 72.8232,
        images: [
          'https://images.unsplash.com/photo-1497366754035-f200968a6e72?w=800',
        ],
        description: 'Work with a stunning view of the Arabian Sea.',
        amenities: [
          'High-speed WiFi',
          'Sea View',
          'Restaurant',
          'Valet Parking',
        ],
        operatingHours: {
          'Monday': '8:00 AM - 8:00 PM',
          'Tuesday': '8:00 AM - 8:00 PM',
          'Wednesday': '8:00 AM - 8:00 PM',
          'Thursday': '8:00 AM - 8:00 PM',
          'Friday': '8:00 AM - 8:00 PM',
          'Saturday': '9:00 AM - 6:00 PM',
          'Sunday': '9:00 AM - 6:00 PM',
        },
        rating: 4.6,
        capacity: 30,
      ),
      CoworkingSpaceModel(
        id: '5',
        name: 'Tech Valley Pune',
        location: 'Hinjewadi, Pune',
        city: 'Pune',
        pricePerHour: 100.0,
        latitude: 18.5957,
        longitude: 73.7004,
        images: [
          'https://images.unsplash.com/photo-1497366216548-37526070297c?w=800',
        ],
        description: 'Affordable workspace in Pune\'s IT hub.',
        amenities: ['High-speed WiFi', 'Food Court', 'Parking', 'AC'],
        operatingHours: {
          'Monday': '9:00 AM - 9:00 PM',
          'Tuesday': '9:00 AM - 9:00 PM',
          'Wednesday': '9:00 AM - 9:00 PM',
          'Thursday': '9:00 AM - 9:00 PM',
          'Friday': '9:00 AM - 9:00 PM',
          'Saturday': '10:00 AM - 6:00 PM',
          'Sunday': 'Closed',
        },
        rating: 4.0,
        capacity: 60,
      ),
    ];
  }

  static Future<List<BookingModel>> getUserBookings() async {
    await _delay();

    final prefs = await SharedPreferences.getInstance();
    final String? bookingsJson = prefs.getString(_bookingsKey);

    if (bookingsJson != null) {
      final List<dynamic> bookingsList = json.decode(bookingsJson);
      return bookingsList.map((json) => BookingModel.fromJson(json)).toList();
    }

    return [];
  }

  static Future<void> createBooking(BookingModel booking) async {
    await _delay();

    final prefs = await SharedPreferences.getInstance();
    final String? bookingsJson = prefs.getString(_bookingsKey);

    List<BookingModel> bookings = [];
    if (bookingsJson != null) {
      final List<dynamic> bookingsList = json.decode(bookingsJson);
      bookings = bookingsList
          .map((json) => BookingModel.fromJson(json))
          .toList();
    }

    bookings.add(booking);
    final updatedJson = json.encode(bookings.map((b) => b.toJson()).toList());
    await prefs.setString(_bookingsKey, updatedJson);
  }

  static Future<void> cancelBooking(String bookingId) async {
    await _delay();

    final prefs = await SharedPreferences.getInstance();
    final String? bookingsJson = prefs.getString(_bookingsKey);

    if (bookingsJson != null) {
      final List<dynamic> bookingsList = json.decode(bookingsJson);
      List<BookingModel> bookings = bookingsList
          .map((json) => BookingModel.fromJson(json))
          .toList();

      final index = bookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        bookings[index] = BookingModel(
          id: bookings[index].id,
          spaceId: bookings[index].spaceId,
          spaceName: bookings[index].spaceName,
          date: bookings[index].date,
          startTime: bookings[index].startTime,
          endTime: bookings[index].endTime,
          totalPrice: bookings[index].totalPrice,
          status: BookingStatus.cancelled,
          bookedAt: bookings[index].bookedAt,
        );

        final updatedJson = json.encode(
          bookings.map((b) => b.toJson()).toList(),
        );
        await prefs.setString(_bookingsKey, updatedJson);
      }
    }
  }

  static Future<List<NotificationModel>> getNotifications() async {
    await _delay();

    final prefs = await SharedPreferences.getInstance();
    final String? notificationsJson = prefs.getString(_notificationsKey);

    if (notificationsJson != null) {
      final List<dynamic> notificationsList = json.decode(notificationsJson);
      return notificationsList
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    }

    // Initialize with sample notifications
    final mockNotifications = [
      NotificationModel(
        id: '1',
        title: 'Welcome!',
        message:
            'Welcome to CoWorking Booking. Find your perfect workspace today!',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];

    final newNotificationsJson = json.encode(
      mockNotifications.map((n) => n.toJson()).toList(),
    );
    await prefs.setString(_notificationsKey, newNotificationsJson);
    return mockNotifications;
  }

  static Future<void> markNotificationAsRead(String notificationId) async {
    await _delay();

    final prefs = await SharedPreferences.getInstance();
    final String? notificationsJson = prefs.getString(_notificationsKey);

    if (notificationsJson != null) {
      final List<dynamic> notificationsList = json.decode(notificationsJson);
      List<NotificationModel> notifications = notificationsList
          .map((json) => NotificationModel.fromJson(json))
          .toList();

      final index = notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        notifications[index] = notifications[index].copyWith(isRead: true);

        final updatedJson = json.encode(
          notifications.map((n) => n.toJson()).toList(),
        );
        await prefs.setString(_notificationsKey, updatedJson);
      }
    }
  }

  static Future<void> markAllNotificationsAsRead() async {
    await _delay();

    final prefs = await SharedPreferences.getInstance();
    final String? notificationsJson = prefs.getString(_notificationsKey);

    if (notificationsJson != null) {
      final List<dynamic> notificationsList = json.decode(notificationsJson);
      List<NotificationModel> notifications = notificationsList
          .map((json) => NotificationModel.fromJson(json))
          .toList();

      notifications = notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();

      final updatedJson = json.encode(
        notifications.map((n) => n.toJson()).toList(),
      );
      await prefs.setString(_notificationsKey, updatedJson);
    }
  }

  static Future<void> addNotification(NotificationModel notification) async {
    final prefs = await SharedPreferences.getInstance();
    final String? notificationsJson = prefs.getString(_notificationsKey);

    List<NotificationModel> notifications = [];
    if (notificationsJson != null) {
      final List<dynamic> notificationsList = json.decode(notificationsJson);
      notifications = notificationsList
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    }

    notifications.insert(0, notification);
    final updatedJson = json.encode(
      notifications.map((n) => n.toJson()).toList(),
    );
    await prefs.setString(_notificationsKey, updatedJson);
  }
}
