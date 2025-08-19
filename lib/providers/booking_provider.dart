import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

class BookingProvider with ChangeNotifier {
  List<BookingModel> _bookings = [];
  bool _isLoading = false;
  String? _error;

  List<BookingModel> get bookings => _bookings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<BookingModel> get upcomingBookings {
    return _bookings
        .where(
          (booking) =>
              booking.status == BookingStatus.upcoming &&
              booking.date.isAfter(
                DateTime.now().subtract(const Duration(days: 1)),
              ),
        )
        .toList();
  }

  List<BookingModel> get completedBookings {
    return _bookings
        .where(
          (booking) =>
              booking.status == BookingStatus.completed ||
              (booking.date.isBefore(DateTime.now()) &&
                  booking.status == BookingStatus.upcoming),
        )
        .toList();
  }

  Future<void> loadBookings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _bookings = await ApiService.getUserBookings();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createBooking({
    required String spaceId,
    required String spaceName,
    required DateTime date,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required double pricePerHour,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final booking = BookingModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        spaceId: spaceId,
        spaceName: spaceName,
        date: date,
        startTime: startTime,
        endTime: endTime,
        totalPrice: _calculateTotalPrice(startTime, endTime, pricePerHour),
        status: BookingStatus.upcoming,
        bookedAt: DateTime.now(),
      );

      await ApiService.createBooking(booking);
      _bookings.add(booking);

      // Send confirmation notification
      await NotificationService.showNotification(
        'Booking Confirmed',
        'Your booking for $spaceName has been confirmed for ${_formatDate(date)}',
      );

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  double _calculateTotalPrice(
    TimeOfDay start,
    TimeOfDay end,
    double pricePerHour,
  ) {
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    final durationHours = (endMinutes - startMinutes) / 60.0;
    return durationHours * pricePerHour;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> cancelBooking(String bookingId) async {
    try {
      await ApiService.cancelBooking(bookingId);
      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        _bookings[index] = BookingModel(
          id: _bookings[index].id,
          spaceId: _bookings[index].spaceId,
          spaceName: _bookings[index].spaceName,
          date: _bookings[index].date,
          startTime: _bookings[index].startTime,
          endTime: _bookings[index].endTime,
          totalPrice: _bookings[index].totalPrice,
          status: BookingStatus.cancelled,
          bookedAt: _bookings[index].bookedAt,
        );
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
