import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:meetcake/database/collections/user_collection.dart';
import 'package:meetcake/user_service/service.dart';
import 'package:toast/toast.dart';

class RegPage extends StatefulWidget {
  const RegPage({super.key});

  @override
  State<RegPage> createState() => _RegPageState();
}

class _RegPageState extends State<RegPage> {
  bool _isChecked = false;
  int selectedIndex = 0;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  AuthService authService = AuthService();
  UserCRUD _userCRUD = UserCRUD(); // Используем AuthService для авторизации
  String _smsCode = '';
  bool _codeSent = false; // Отслеживаем, отправлен ли код

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return Scaffold(
      body: Container(
        color: const Color.fromRGBO(255, 159, 159, 1),
        height: double.infinity,
        width: double.infinity,
        alignment: Alignment.center,
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
                color: const Color.fromRGBO(255, 159, 159, 1),
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
                            "Login",
                            style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                color: Colors.white),
                          ),
                        ),
                        const Spacer(),
                        // Поле ввода телефона
                        TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          controller: emailController,
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w500),
                          decoration: const InputDecoration(
                            labelText: "Email",
                            labelStyle: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500),
                            suffixIcon: Icon(
                              Icons.email_outlined,
                              color: Colors.white,
                            ),
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.auto,
                          ),
                          cursorColor: Colors.white,
                        ),
                        // Показываем поле ввода кода только если код был отправлен

                        const Spacer(),
                        TextFormField(
                          controller: nameController,
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w500),
                          decoration: InputDecoration(
                            labelText: "Name",
                            labelStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500),
                            suffixIcon: const Icon(
                              Icons.account_circle_outlined,
                              color: Colors.white,
                            ),
                            border: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.auto,
                          ),
                          cursorColor: Colors.white,
                        ),
                        const Spacer(),
                        TextFormField(
                          controller: passwordController,
                          obscureText: true,
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w500),
                          decoration: InputDecoration(
                            labelText: "Password",
                            labelStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500),
                            suffixIcon: const Icon(
                              Icons.lock,
                              color: Colors.white,
                            ),
                            border: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.auto,
                          ),
                          cursorColor: Colors.white,
                        ),
                        const Spacer(),
                        const Spacer(),
                        // Кнопка для отправки кода или входа с кодом
                        ElevatedButton(
                          onPressed: () async {
                            if (nameController.text.isEmpty ||
                                emailController.text.isEmpty ||
                                passwordController.text.isEmpty) {
                              Toast.show('Fill in the fields!');
                            } else {
                              var user = await _userCRUD
                                  .fetchUsername(nameController.text);
                              if (user != null) {
                                Toast.show('Choose another name');
                              } else {
                                await authService.signUp(
                                    nameController.text,
                                    emailController.text,
                                    passwordController.text);
                                Toast.show('Success');
                                Navigator.popAndPushNamed(context, '/');
                              }
                            }
                          },
                          child: Container(
                            height: 40,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "Register",
                              style: const TextStyle(
                                  color: Color.fromRGBO(255, 159, 159, 1),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16),
                            ),
                          ),
                        ),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.popAndPushNamed(context, '/auth');
                            },
                            child: const Text(
                              "Have an account? AUTHORIZE",
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
    );
  }
}
