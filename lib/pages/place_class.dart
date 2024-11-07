class Place {
  final String id;
  final String name;
  final double lat;
  final double long;
  final String description;
  final String imageUrl;

  Place({
    required this.id,
    required this.name,
    required this.lat,
    required this.long,
    required this.description,
    required this.imageUrl,
  });

  // You can add a factory constructor to create a Place instance from JSON data if you fetch places from an API
  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'] ?? '', // Provide a default or handle null
      name: json['name'] ?? 'Unnamed Place',
      lat: json['lat']?.toDouble() ?? 0.0,
      long: json['long']?.toDouble() ?? 0.0,
      description: json['description'] ?? 'No description available',
      imageUrl: json['imageUrl'] ?? '', // Add a default image URL if desired
    );
  }
}
