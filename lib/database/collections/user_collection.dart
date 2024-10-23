import 'package:cloud_firestore/cloud_firestore.dart';

class UserCRUD {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> fetchUsername(String username) async {
    try {
      QuerySnapshot userSnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();
      var docId = userSnapshot.docs.first.id;
      return docId;
    } catch (e) {
      return null;
    }
  }
}
