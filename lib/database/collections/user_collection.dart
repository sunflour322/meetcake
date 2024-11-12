import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserCRUD {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? userId = FirebaseAuth.instance.currentUser?.uid;
  Future<String?> fetchUserID(String username) async {
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

  Future<String?> fetchUsername() async {
    if (userId != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      return userDoc['username'];
    }
    return null;
  }
}
