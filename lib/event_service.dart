import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'event_model.dart';

class EventService {
  final CollectionReference _ref =
  FirebaseFirestore.instance.collection('events');

  Stream<List<EventModel>> getEvents() {
    return _ref.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return EventModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  Future<void> deleteEvent(String eventId) async {
    await FirebaseFirestore.instance.collection('events').doc(eventId).delete();
  }


  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }


  Future<void> addEvent(EventModel event) async {
    final docRef = FirebaseFirestore.instance.collection('events').doc();
    await docRef.set(event.toMap()..['id'] = docRef.id);
  }


  Future<void> updateEvent(EventModel event) async {
    if (event.id.isEmpty) return;
    final docRef = FirebaseFirestore.instance.collection('events').doc(
        event.id);
    await docRef.update(event.toMap());
  }
}
