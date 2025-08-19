import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/coworking_space_model.dart';
import '../providers/booking_provider.dart';

class BookingScreen extends StatefulWidget {
  final CoworkingSpaceModel space;

  const BookingScreen({super.key, required this.space});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isBooking = false;

  @override
  Widget build(BuildContext context) {
    final canShowTotal =
        _startTime != null && _endTime != null && _isValidTimeRange();
    return Scaffold(
      appBar: AppBar(title: const Text('Book Space')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Space info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.space.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.space.location,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '₹${widget.space.pricePerHour}/hour',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2196F3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Date selection
            const Text(
              'Select Date',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.grey),
                    const SizedBox(width: 12),
                    Text(
                      _selectedDate != null
                          ? DateFormat(
                              'EEEE, MMM dd, yyyy',
                            ).format(_selectedDate!)
                          : 'Choose a date',
                      style: TextStyle(
                        fontSize: 16,
                        color: _selectedDate != null
                            ? Colors.black
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Time selection
            const Text(
              'Select Time',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectStartTime(context),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Start Time',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _startTime?.format(context) ?? 'Select',
                            style: TextStyle(
                              fontSize: 16,
                              color: _startTime != null
                                  ? Colors.black
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectEndTime(context),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'End Time',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _endTime?.format(context) ?? 'Select',
                            style: TextStyle(
                              fontSize: 16,
                              color: _endTime != null
                                  ? Colors.black
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Price calculation
            if (canShowTotal) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Amount',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '₹${_calculateTotalPrice().toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canBook() && !_isBooking ? _onBook : null,
                child: _isBooking
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text('Confirm Booking'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final initial = _selectedDate ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(now) ? now : initial,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
        if (_endTime != null && !_isValidTimeRangeWith(picked, _endTime!)) {
          _endTime = null;
        }
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    if (_startTime == null) {
      _showSnack('Please select start time first');
      return;
    }
    final picked = await showTimePicker(
      context: context,
      initialTime:
          _endTime ??
          TimeOfDay(
            hour: (_startTime!.hour + 1) % 24,
            minute: _startTime!.minute,
          ),
    );
    if (picked != null) {
      if (_isValidTimeRangeWith(_startTime!, picked)) {
        setState(() {
          _endTime = picked;
        });
      } else {
        _showSnack('End time must be after start time');
      }
    }
  }

  bool _canBook() {
    return _selectedDate != null &&
        _startTime != null &&
        _endTime != null &&
        _isValidTimeRange();
  }

  bool _isValidTimeRange() {
    if (_startTime == null || _endTime == null) return false;
    return _isValidTimeRangeWith(_startTime!, _endTime!);
  }

  bool _isValidTimeRangeWith(TimeOfDay start, TimeOfDay end) {
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    return endMinutes > startMinutes;
  }

  double _calculateTotalPrice() {
    if (_startTime == null || _endTime == null) return 0;
    final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
    final endMinutes = _endTime!.hour * 60 + _endTime!.minute;
    final durationHours = (endMinutes - startMinutes) / 60.0;
    return durationHours * widget.space.pricePerHour;
  }

  Future<void> _onBook() async {
    if (!_canBook()) return;
    if (_selectedDate == null) {
      _showSnack('Please select a date');
      return;
    }
    setState(() {
      _isBooking = true;
    });
    final ok = await context.read<BookingProvider>().createBooking(
      spaceId: widget.space.id,
      spaceName: widget.space.name,
      date: _selectedDate!,
      startTime: _startTime!,
      endTime: _endTime!,
      pricePerHour: widget.space.pricePerHour,
    );
    setState(() {
      _isBooking = false;
    });
    if (ok) {
      _showSnack('Booking confirmed');
      if (!mounted) return;
      Navigator.pop(context);
    } else {
      if (!mounted) return;
      final error =
          context.read<BookingProvider>().error ?? 'Failed to create booking';
      _showSnack(error);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
