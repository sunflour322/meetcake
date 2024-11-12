import 'package:meetcake/pages/account.dart';
import 'package:meetcake/pages/auth.dart';
import 'package:meetcake/pages/meets.dart';
import 'package:meetcake/pages/reg.dart';
import 'package:meetcake/user_service/landing.dart';

final routes = {
  '/': (context) => const LandingPage(),
  '/auth': (context) => const AuthPage(),
  '/reg': (context) => const RegPage(),
  '/meets': (context) => const MeetPage(),
  '/acc': (context) => const FriendsPage()
};
