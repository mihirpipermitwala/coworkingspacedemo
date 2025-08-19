import 'package:flutter/material.dart' show TimeOfDay;
import 'package:json_annotation/json_annotation.dart';

class TimeOfDayConverter implements JsonConverter<TimeOfDay, String> {
  const TimeOfDayConverter();
  @override
  TimeOfDay fromJson(String json) {
    final parts = json.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  @override
  String toJson(TimeOfDay object) => '${object.hour}:${object.minute}';
}
