import 'package:cloud_firestore/cloud_firestore.dart';

class MeetsCRUD {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Future<void> addMeet(
      String name, double lat, double long, List<String> usersID) async {
    try {
      await _firebaseFirestore.collection('meets').doc().set({
        'name': name,
        'lat': lat,
        'long': long,
        'users': usersID,
      });
    } catch (e) {
      return;
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
