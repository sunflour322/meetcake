import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

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

  Future<void> updateMeet(String id, String name, Point point,
      List<String> usersID, List<String> requestUsers) async {
    try {
      await _firebaseFirestore.collection('meets').doc(id).update({
        'name': name,
        'lat': point.latitude,
        'long': point.longitude,
        'users': usersID,
        'requestUsers': requestUsers
      });
    } catch (e) {
      return;
    }
  }

  Future<void> deleteMeet(dynamic docs) async {
    try {
      await _firebaseFirestore.collection('meets').doc(docs).delete();
    } catch (e) {
      return;
    }
  }
}
