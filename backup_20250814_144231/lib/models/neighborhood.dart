class Neighborhood {
  final int id;
  final String name;

  Neighborhood({
    required this.id,
    required this.name,
  });

  factory Neighborhood.fromJson(Map<String, dynamic> json) {
    return Neighborhood(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
    );
  }
}
