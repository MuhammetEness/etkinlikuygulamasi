import 'city.dart';
import 'district.dart';
import 'neighborhood.dart';

class Venue {
  final int id;
  final String name;
  final City? city;
  final District? district;
  final Neighborhood? neighborhood;
  final String? address;
  final double? lat;
  final double? lng;

  Venue({
    required this.id,
    required this.name,
    this.city,
    this.district,
    this.neighborhood,
    this.address,
    this.lat,
    this.lng,
  });

  factory Venue.fromJson(Map<String, dynamic> json) {
    return Venue(
      id: json['id'],
      name: json['name'] ?? '',
      city: json['city'] != null ? City.fromJson(json['city']) : null,
      district: json['district'] != null ? District.fromJson(json['district']) : null,
      neighborhood: json['neighborhood'] != null ? Neighborhood.fromJson(json['neighborhood']) : null,
      address: json['address'],
      lat: (json['lat'] != null)
          ? double.tryParse(json['lat'].toString())
          : null,
      lng: (json['lng'] != null)
          ? double.tryParse(json['lng'].toString())
          : null,
    );
  }
}
