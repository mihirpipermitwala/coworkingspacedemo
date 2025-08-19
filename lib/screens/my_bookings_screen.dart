import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/booking_provider.dart';
import '../models/booking_model.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().loadBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BookingProvider>(
      builder: (context, bp, _) {
        if (bp.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (bp.error != null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 12),
                Text(
                  'Error: ${bp.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => bp.loadBookings(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final upcoming = bp.upcomingBookings;
        final past = bp.completedBookings;

        return DefaultTabController(
          length: 2,
          child: Column(
            children: [
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Material(
                  color: Colors.transparent,
                  child: TabBar(
                    labelColor: Theme.of(context).primaryColor,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Theme.of(context).primaryColor,
                    tabs: [
                      Tab(text: 'Upcoming (${upcoming.length})'),
                      Tab(text: 'Past (${past.length})'),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _BookingsList(
                      bookings: upcoming,
                      isUpcoming: true,
                      onRefresh: () => bp.loadBookings(),
                      onCancel: (id) => _confirmAndCancel(context, bp, id),
                    ),
                    _BookingsList(
                      bookings: past,
                      isUpcoming: false,
                      onRefresh: () => bp.loadBookings(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmAndCancel(
    BuildContext context,
    BookingProvider bp,
    String bookingId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel booking?'),
          content: const Text('Are you sure you want to cancel this booking?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Yes, cancel'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await bp.cancelBooking(bookingId);
      if (bp.error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(bp.error!)));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Booking cancelled')));
      }
    }
  }
}

class _BookingsList extends StatelessWidget {
  final List<BookingModel> bookings;
  final bool isUpcoming;
  final Future<void> Function() onRefresh;
  final Future<void> Function(String bookingId)? onCancel;

  const _BookingsList({
    required this.bookings,
    required this.isUpcoming,
    required this.onRefresh,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          children: [
            const SizedBox(height: 120),
            Icon(
              isUpcoming ? Icons.event_busy : Icons.history,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                isUpcoming ? 'No upcoming bookings' : 'No past bookings',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final b = bookings[index];
          return _BookingCard(
            booking: b,
            isUpcoming: isUpcoming,
            onCancel: onCancel,
          );
        },
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingModel booking;
  final bool isUpcoming;
  final Future<void> Function(String bookingId)? onCancel;

  const _BookingCard({
    required this.booking,
    required this.isUpcoming,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEE, MMM d, y').format(booking.date);
    final timeRange = '${_fmt(booking.startTime)} - ${_fmt(booking.endTime)}';
    final statusText = booking.status.toString().split('.').last;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: space name + price
            Row(
              children: [
                Expanded(
                  child: Text(
                    booking.spaceName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2196F3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '₹${booking.totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Date and time
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 18,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 6),
                        Text(dateStr),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 18,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 6),
                        Text(timeRange),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor(context, booking.status).withAlpha(30),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    statusText[0].toUpperCase() + statusText.substring(1),
                    style: TextStyle(
                      color: _statusColor(context, booking.status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            if (isUpcoming) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: onCancel != null
                      ? () => onCancel!(booking.id)
                      : null,
                  icon: const Icon(Icons.cancel, size: 18),
                  label: const Text('Cancel booking'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _fmt(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final suffix = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $suffix';
  }

  static Color _statusColor(BuildContext context, BookingStatus status) {
    switch (status) {
      case BookingStatus.upcoming:
        return Theme.of(context).primaryColor;
      case BookingStatus.completed:
        return Colors.green[700]!;
      case BookingStatus.cancelled:
        return Colors.red[700]!;
    }
  }
}
