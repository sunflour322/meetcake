import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  String? id;
  UserModel.fromFirebase(User user) {
    id = user.uid;
  }
}
