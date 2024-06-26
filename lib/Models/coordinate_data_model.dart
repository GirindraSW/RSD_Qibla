import 'package:equatable/equatable.dart';

class CoordinateDataModel extends Equatable {
  final String id;
  final String name;
  final double longitude;
  final double latitude;
  final int degree;
  final double minute;
  final double second;

  CoordinateDataModel({
    required this.id,
    required this.name,
    required this.longitude,
    required this.latitude,
    required this.degree,
    required this.minute,
    required this.second,
  });

  @override
  List<Object> get props =>
      [id, name, longitude, latitude, degree, minute, second];
}
