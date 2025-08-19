// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'NotificationModel',
      json,
      ($checkedConvert) {
        final val = NotificationModel(
          id: $checkedConvert('id', (v) => v as String),
          title: $checkedConvert('title', (v) => v as String),
          message: $checkedConvert('message', (v) => v as String),
          timestamp: $checkedConvert(
            'timestamp',
            (v) => DateTime.parse(v as String),
          ),
          isRead: $checkedConvert('is_read', (v) => v as bool? ?? false),
          bookingId: $checkedConvert('booking_id', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {'isRead': 'is_read', 'bookingId': 'booking_id'},
    );

// ignore: unused_element
abstract class _$NotificationModelPerFieldToJson {
  // ignore: unused_element
  static Object? id(String instance) => instance;
  // ignore: unused_element
  static Object? title(String instance) => instance;
  // ignore: unused_element
  static Object? message(String instance) => instance;
  // ignore: unused_element
  static Object? timestamp(DateTime instance) => instance.toIso8601String();
  // ignore: unused_element
  static Object? isRead(bool instance) => instance;
  // ignore: unused_element
  static Object? bookingId(String? instance) => instance;
}

Map<String, dynamic> _$NotificationModelToJson(NotificationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'message': instance.message,
      'timestamp': instance.timestamp.toIso8601String(),
      'is_read': instance.isRead,
      'booking_id': ?instance.bookingId,
    };
