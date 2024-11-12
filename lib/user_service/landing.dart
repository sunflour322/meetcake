import 'package:flutter/material.dart';
import 'package:meetcake/pages/auth.dart';
import 'package:meetcake/pages/catalog.dart';
import 'package:meetcake/pages/meets.dart';
import 'package:meetcake/user_service/model.dart';
import 'package:provider/provider.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final UserModel? userModel = Provider.of<UserModel?>(context);
    print(userModel);
    final bool check = userModel != null;
    print(check);
    return check ? const MeetPage() : const AuthPage();
  }
}
