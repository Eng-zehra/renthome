import 'dart:convert';

class Property {
  final int id;
  final String title;
  final String description;
  final String type;
  final double pricePerNight;
  final String location;
  final String city;
  final int bedrooms;
  final int beds;
  final int bathrooms;
  final int maxGuests;
  final List<String> amenities;
  final List<String> images;
  final double rating;
  final int? hostId;

  Property({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.pricePerNight,
    required this.location,
    required this.city,
    required this.bedrooms,
    required this.beds,
    required this.bathrooms,
    required this.maxGuests,
    required this.amenities,
    required this.images,
    required this.rating,
    this.hostId,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'],
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? '',
      type: json['type'] ?? 'Apartment',
      pricePerNight: double.tryParse(json['price_per_night']?.toString() ?? '0') ?? 0.0,
      location: json['location'] ?? 'Unknown',
      city: json['city'] ?? 'Unknown',
      bedrooms: json['bedrooms'] ?? 1,
      beds: json['beds'] ?? 1,
      bathrooms: json['bathrooms'] ?? 1,
      maxGuests: json['max_guests'] ?? 4,
      amenities: json['amenities'] is String 
          ? List<String>.from(jsonDecode(json['amenities'])) 
          : List<String>.from(json['amenities'] ?? []),
      images: json['images'] is String 
          ? List<String>.from(jsonDecode(json['images'])) 
          : List<String>.from(json['images'] ?? []),
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0,
      hostId: json['host_id'],
    );
  }
}
