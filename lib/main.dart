import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:meetcake/generated/l10n.dart';
import 'package:meetcake/routes.dart';
import 'package:meetcake/theme_lng/change_lng.dart';
import 'package:meetcake/theme_lng/change_theme.dart';
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
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LocaleProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    return StreamProvider.value(
        initialData: null,
        value: AuthService().currentUser,
        child: MaterialApp(
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          locale: localeProvider.locale,
          theme: themeProvider.theme,
          supportedLocales: S.delegate.supportedLocales,
          debugShowCheckedModeBanner: false,
          title: 'MeetCake',
          initialRoute: '/',
          routes: routes,
        ));
  }
}
