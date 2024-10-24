import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meetcake/user_service/model.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Регистрация с проверкой уникальности имени пользователя
  Future<UserModel?> signUp(
      String username, String email, String password) async {
    try {
      // Проверка уникальности имени пользователя
      QuerySnapshot userSnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        // Если имя пользователя уже существует, возвращаем ошибку
        throw Exception("Имя пользователя уже занято");
      }

      // Если имя уникально, создаем пользователя с email и паролем
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      User user = userCredential.user!;

      // Сохранение имени пользователя и email в Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'username': username,
        'email': email,
      });

      return UserModel.fromFirebase(user);
    } catch (e) {
      // Если произошла ошибка, выводим сообщение
      print("Ошибка регистрации: $e");
      return null;
    }
  }

  // Вход с использованием имени пользователя и пароля
  Future<UserModel?> signIn(String username, String password) async {
    try {
      // Поиск email по имени пользователя
      QuerySnapshot userSnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (userSnapshot.docs.isEmpty) {
        throw Exception("Пользователь с таким именем не найден");
      }

      // Получаем email пользователя
      String email = userSnapshot.docs[0]['email'];

      // Выполняем вход с использованием email и пароля
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      User user = userCredential.user!;

      return UserModel.fromFirebase(user);
    } catch (e) {
      print("Ошибка входа: $e");
      return null;
    }
  }

  // Выход из аккаунта
  Future logOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      return null;
    }
  }

  // Текущий пользователь
  Stream<UserModel?> get currentUser {
    return _firebaseAuth
        .authStateChanges()
        .map((user) => user != null ? UserModel.fromFirebase(user) : null);
  }
}
