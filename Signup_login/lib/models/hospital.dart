class Hospital {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String website;
  final double rating;
  final double distance;
  final double travelTime;
  final String openingHours;
  final List<Review> reviews;
  final String category;

  Hospital({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.website,
    required this.rating,
    required this.distance,
    required this.travelTime,
    required this.openingHours,
    required this.reviews,
    required this.category,
  });

  factory Hospital.fromMap(Map<String, dynamic> map) {
    return Hospital(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      phone: map['phone'] ?? '',
      website: map['website'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      distance: (map['distance'] ?? 0).toDouble(),
      travelTime: (map['travelTime'] ?? 0).toDouble(),
      openingHours: map['openingHours'] ?? '',
      reviews: (map['reviews'] as List<dynamic>? ?? []).map((e) => Review.fromMap(e)).toList(),
      category: map['category'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'website': website,
      'rating': rating,
      'distance': distance,
      'travelTime': travelTime,
      'openingHours': openingHours,
      'reviews': reviews.map((e) => e.toMap()).toList(),
      'category': category,
    };
  }
}

class Review {
  final String user;
  final String comment;
  final double rating;

  Review({required this.user, required this.comment, required this.rating});

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      user: map['user'] ?? '',
      comment: map['comment'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user': user,
      'comment': comment,
      'rating': rating,
    };
  }
} 