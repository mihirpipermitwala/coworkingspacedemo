import 'package:flutter/material.dart';

enum BookingStatus { upcoming, completed, cancelled }

class BookingModel {
  final String id;
  final String spaceId;
  final String spaceName;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final double totalPrice;
  final BookingStatus status;
  final DateTime bookedAt;

  BookingModel({
    required this.id,
    required this.spaceId,
    required this.spaceName,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.totalPrice,
    required this.status,
    required this.bookedAt,
  });

  double get durationInHours {
    final start = startTime.hour + startTime.minute / 60.0;
    final end = endTime.hour + endTime.minute / 60.0;
    return end - start;
  }

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'],
      spaceId: json['spaceId'],
      spaceName: json['spaceName'],
      date: DateTime.parse(json['date']),
      startTime: TimeOfDay(
        hour: json['startTimeHour'],
        minute: json['startTimeMinute'],
      ),
      endTime: TimeOfDay(
        hour: json['endTimeHour'],
        minute: json['endTimeMinute'],
      ),
      totalPrice: json['totalPrice'].toDouble(),
      status: BookingStatus.values.firstWhere(
        (e) => e.toString() == 'BookingStatus.${json['status']}',
      ),
      bookedAt: DateTime.parse(json['bookedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'spaceId': spaceId,
      'spaceName': spaceName,
      'date': date.toIso8601String(),
      'startTimeHour': startTime.hour,
      'startTimeMinute': startTime.minute,
      'endTimeHour': endTime.hour,
      'endTimeMinute': endTime.minute,
      'totalPrice': totalPrice,
      'status': status.toString().split('.').last,
      'bookedAt': bookedAt.toIso8601String(),
    };
  }
}
