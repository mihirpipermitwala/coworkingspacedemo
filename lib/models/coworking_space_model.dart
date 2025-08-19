import 'package:json_annotation/json_annotation.dart';

part 'coworking_space_model.g.dart';

@JsonSerializable()
class CoworkingSpaceModel {
  final String id;
  final String name;
  final String location;
  final String city;
  final double pricePerHour;
  final double latitude;
  final double longitude;
  final List<String> images;
  final String description;
  final List<String> amenities;
  final Map<String, String> operatingHours;
  final double rating;
  final int capacity;

  CoworkingSpaceModel({
    required this.id,
    required this.name,
    required this.location,
    required this.city,
    required this.pricePerHour,
    required this.latitude,
    required this.longitude,
    required this.images,
    required this.description,
    required this.amenities,
    required this.operatingHours,
    required this.rating,
    required this.capacity,
  });

  factory CoworkingSpaceModel.fromJson(Map<String, dynamic> json) =>
      _$CoworkingSpaceModelFromJson(json);

  Map<String, dynamic> toJson() => _$CoworkingSpaceModelToJson(this);
}
