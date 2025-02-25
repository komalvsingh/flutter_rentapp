class Item {
  final String id;
  final String name;
  final String category;
  final int price; // Price in INR
  final String description;
  final String imageUrl;
  final String location;

  // Constructor
  Item({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.location,
  });

  // Convert Item object to Map (for Firestore storage)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
      'location': location
    };
  }

  // Create Item object from Map (for Firestore retrieval)
  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      price: map['price'],
      description: map['description'],
      imageUrl: map['imageUrl'],
      location: map['location'],
    );
  }

  // copyWith method for creating modified copies of an Item
  Item copyWith({
    String? id,
    String? name,
    String? category,
    int? price,
    String? description,
    String? imageUrl,
    String? location,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      location: location ?? this.location,
    );
  }
}
