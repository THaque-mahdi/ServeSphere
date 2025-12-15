import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String title;
  final String category;
  final String description;
  final String location;
  final DateTime dateTime;
  final int maxParticipants;
  final int joinedCount;
  final String imageUrl;

  EventModel({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.location,
    required this.dateTime,
    required this.maxParticipants,
    required this.joinedCount,
    required this.imageUrl,
  });

  factory EventModel.fromMap(Map<String, dynamic> map, String id) {
    return EventModel(
      id: id,
      title: map['title'] ?? '',
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      dateTime: (map['dateTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      maxParticipants: (map['maxParticipants'] ?? 0).toInt(),
      joinedCount: (map['joinedCount'] ?? 0).toInt(),
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'description': description,
      'location': location,
      'dateTime': Timestamp.fromDate(dateTime),
      'maxParticipants': maxParticipants,
      'joinedCount': joinedCount,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
