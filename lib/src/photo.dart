import 'package:cloud_firestore/cloud_firestore.dart';

class Photo {
  Photo({required this.id, required this.imageUrl, this.createdAt});
  final String id;
  final String imageUrl;
  final DateTime? createdAt;

  factory Photo.fromMap(Map<String, dynamic> map, String id) {
    final createdAt = map['createdAt'];
    return Photo(
      id: id,
      imageUrl: map['imageUrl'] as String,
      // https://stackoverflow.com/a/71731076/436422
      createdAt: createdAt != null ? (createdAt as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'imageUrl': imageUrl,
        if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      };
}
