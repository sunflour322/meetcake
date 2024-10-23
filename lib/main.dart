import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:meetcake/routes.dart';
import 'package:meetcake/user_service/service.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: 'AIzaSyAZuKYGr6pQg8hJJObCNNpfN8iGrmsc4dQ',
        appId: '1:594015453335:android:6e7ca4b9b63b5d45f369d2',
        messagingSenderId: '594015453335',
        projectId: 'meetcake-2aa94',
        storageBucket: 'meetcake-2aa94.appspot.com'),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamProvider.value(
        initialData: null,
        value: AuthService().currentUser,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'MeetCake',
          initialRoute: '/',
          routes: routes,
        ));
  }
}
