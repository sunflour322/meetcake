import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:meetcake/generated/l10n.dart';
import 'package:meetcake/theme_lng/change_lng.dart';
import 'package:meetcake/theme_lng/change_theme.dart';
import 'package:meetcake/user_service/user_service.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  int selectedIndex = 0;
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
                      child: Image.asset('assets/logo.png'),
                    ),
                    Container(
                      height: 400,
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 30),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaY: 5, sigmaX: 5),
                          child: Padding(
                            padding: const EdgeInsets.all(25),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Spacer(),
                                Center(
                                  child: Text(
                                    S.of(context).login,
                                    style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white),
                                  ),
                                ),
                                const Spacer(),
                                TextFormField(
                                  controller: nameController,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500),
                                  decoration: InputDecoration(
                                    labelText: S.of(context).name,
                                    labelStyle: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500),
                                    suffixIcon: const Icon(
                                      Icons.account_circle_outlined,
                                      color: Colors.white,
                                    ),
                                    border: const UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    focusedBorder: const UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    enabledBorder: const UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.auto,
                                  ),
                                  cursorColor: Colors.white,
                                ),
                                const Spacer(),
                                TextFormField(
                                  controller: passwordController,
                                  obscureText: true,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500),
                                  decoration: InputDecoration(
                                    labelText: S.of(context).password,
                                    labelStyle: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500),
                                    suffixIcon: const Icon(
                                      Icons.lock,
                                      color: Colors.white,
                                    ),
                                    border: const UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    focusedBorder: const UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    enabledBorder: const UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.auto,
                                  ),
                                  cursorColor: Colors.white,
                                ),
                                const Spacer(),
                                const Spacer(),
                                Container(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        padding: const EdgeInsets.all(0),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        )),
                                    onPressed: () async {
                                      if (nameController.text.isEmpty ||
                                          passwordController.text.isEmpty ||
                                          passwordController.text.length < 6) {
                                        Toast.show(
                                            S.of(context).fillInTheFields);
                                      } else {
                                        await authService.signIn(
                                            nameController.text,
                                            passwordController.text);
                                        Toast.show(S.of(context).success);
                                        Navigator.popAndPushNamed(context, '/');
                                      }
                                    },
                                    child: Text(
                                      S.of(context).logIn,
                                    ),
                                  ),
                                ),
                                Center(
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.popAndPushNamed(
                                          context, '/reg');
                                    },
                                    child: Text(
                                      S.of(context).dontHaveAnAccountRegister,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ),
                                const Spacer(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: Row(
              children: [
                FloatingActionButton.small(
                  backgroundColor: Color.fromRGBO(148, 185, 255, 1),
                  heroTag: 'languageBtn',
                  onPressed: () {
                    if (localeProvider.locale.languageCode == 'en') {
                      localeProvider.setLocale(const Locale('ru'));
                    } else {
                      localeProvider.setLocale(const Locale('en'));
                    }
                  },
                  child: const Icon(
                    Icons.language,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                FloatingActionButton.small(
                  backgroundColor: Color.fromRGBO(148, 185, 255, 1),
                  heroTag: 'themeBtn',
                  onPressed: () {
                    themeProvider.toggleTheme();
                  },
                  child: const Icon(
                    Icons.brightness_6_rounded,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
