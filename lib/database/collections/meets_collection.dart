import 'package:cloud_firestore/cloud_firestore.dart';

class MeetsCRUD {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Future<String?> addMeet(
      double lat, double long, String place, String username) async {
    try {
      DocumentReference newMeetRef =
          await _firebaseFirestore.collection('meets').add({
        'name': '',
        'datetime': '',
        'place': place,
        'lat': lat,
        'long': long,
        'users': [username],
        'requestUsers': [],
      });

      return newMeetRef.id;
    } catch (e) {
      print('Error creating meet: $e');
      return null;
    }
  }

  Future<void> updateMeet(String id, String name, double lat, double long,
      List<String> usersID) async {
    try {
      await _firebaseFirestore.collection('meets').doc(id).update({
        'uid': id,
        'name': name,
        'lat': lat,
        'long': long,
        'users': usersID,
      });
    } catch (e) {
      return;
    }
  }

  Future<void> deleteMeet(dynamic docs) async {
    try {
      await _firebaseFirestore.collection('meets').doc(docs.id).delete();
    } catch (e) {
      return;
    }
  }
}
