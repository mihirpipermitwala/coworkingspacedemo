// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coworking_space_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CoworkingSpaceModel _$CoworkingSpaceModelFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'CoworkingSpaceModel',
      json,
      ($checkedConvert) {
        final val = CoworkingSpaceModel(
          id: $checkedConvert('id', (v) => v as String),
          name: $checkedConvert('name', (v) => v as String),
          location: $checkedConvert('location', (v) => v as String),
          city: $checkedConvert('city', (v) => v as String),
          pricePerHour: $checkedConvert(
            'price_per_hour',
            (v) => (v as num).toDouble(),
          ),
          latitude: $checkedConvert('latitude', (v) => (v as num).toDouble()),
          longitude: $checkedConvert('longitude', (v) => (v as num).toDouble()),
          images: $checkedConvert(
            'images',
            (v) => (v as List<dynamic>).map((e) => e as String).toList(),
          ),
          description: $checkedConvert('description', (v) => v as String),
          amenities: $checkedConvert(
            'amenities',
            (v) => (v as List<dynamic>).map((e) => e as String).toList(),
          ),
          operatingHours: $checkedConvert(
            'operating_hours',
            (v) => Map<String, String>.from(v as Map),
          ),
          rating: $checkedConvert('rating', (v) => (v as num).toDouble()),
          capacity: $checkedConvert('capacity', (v) => (v as num).toInt()),
        );
        return val;
      },
      fieldKeyMap: const {
        'pricePerHour': 'price_per_hour',
        'operatingHours': 'operating_hours',
      },
    );

// ignore: unused_element
abstract class _$CoworkingSpaceModelPerFieldToJson {
  // ignore: unused_element
  static Object? id(String instance) => instance;
  // ignore: unused_element
  static Object? name(String instance) => instance;
  // ignore: unused_element
  static Object? location(String instance) => instance;
  // ignore: unused_element
  static Object? city(String instance) => instance;
  // ignore: unused_element
  static Object? pricePerHour(double instance) => instance;
  // ignore: unused_element
  static Object? latitude(double instance) => instance;
  // ignore: unused_element
  static Object? longitude(double instance) => instance;
  // ignore: unused_element
  static Object? images(List<String> instance) => instance;
  // ignore: unused_element
  static Object? description(String instance) => instance;
  // ignore: unused_element
  static Object? amenities(List<String> instance) => instance;
  // ignore: unused_element
  static Object? operatingHours(Map<String, String> instance) => instance;
  // ignore: unused_element
  static Object? rating(double instance) => instance;
  // ignore: unused_element
  static Object? capacity(int instance) => instance;
}

Map<String, dynamic> _$CoworkingSpaceModelToJson(
  CoworkingSpaceModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'location': instance.location,
  'city': instance.city,
  'price_per_hour': instance.pricePerHour,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'images': instance.images,
  'description': instance.description,
  'amenities': instance.amenities,
  'operating_hours': instance.operatingHours,
  'rating': instance.rating,
  'capacity': instance.capacity,
};
