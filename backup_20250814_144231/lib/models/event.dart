import 'category.dart';
import 'venue.dart';
import 'district.dart';
import 'neighborhood.dart';

class Event {
  final int id;
  final String title;
  final String description;
  final DateTime date;
  final Venue? venue;
  final Category? category;
  final String posterUrl;
  final String link;
  final District? district;
  final Neighborhood? neighborhood;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.venue,
    this.category,
    required this.posterUrl,
    required this.link,
    this.district,
    this.neighborhood,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: int.tryParse(json['id'].toString()) ?? 0,
      title: json['name'] ?? '',
      description: json['content'] ?? '',
      date: DateTime.tryParse(json['start'] ?? '') ?? DateTime.now(),
      venue: json['venue'] != null ? Venue.fromJson(json['venue']) : null,
      category: json['category'] != null ? Category.fromJson(json['category']) : null,
      posterUrl: json['poster_url'] ?? '',
      link: json['url'] ?? json['web_url'] ?? '',
      district: json['district'] != null ? District.fromJson(json['district']) : null,
      neighborhood: json['neighborhood'] != null ? Neighborhood.fromJson(json['neighborhood']) : null,
    );
  }
}
