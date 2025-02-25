// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name =
        (locale.countryCode?.isEmpty ?? false)
            ? locale.languageCode
            : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Login`
  String get login {
    return Intl.message('Login', name: 'login', desc: '', args: []);
  }

  /// `User name`
  String get name {
    return Intl.message('User name', name: 'name', desc: '', args: []);
  }

  /// `Password`
  String get password {
    return Intl.message('Password', name: 'password', desc: '', args: []);
  }

  /// `Fill in the fields!`
  String get fillInTheFields {
    return Intl.message(
      'Fill in the fields!',
      name: 'fillInTheFields',
      desc: '',
      args: [],
    );
  }

  /// `Success`
  String get success {
    return Intl.message('Success', name: 'success', desc: '', args: []);
  }

  /// `Log In`
  String get logIn {
    return Intl.message('Log In', name: 'logIn', desc: '', args: []);
  }

  /// `Don't have an account? REGISTER`
  String get dontHaveAnAccountRegister {
    return Intl.message(
      'Don\'t have an account? REGISTER',
      name: 'dontHaveAnAccountRegister',
      desc: '',
      args: [],
    );
  }

  /// `en`
  String get en {
    return Intl.message('en', name: 'en', desc: '', args: []);
  }

  /// `Have an account? AUTHORIZE`
  String get haveAnAccountAuthorize {
    return Intl.message(
      'Have an account? AUTHORIZE',
      name: 'haveAnAccountAuthorize',
      desc: '',
      args: [],
    );
  }

  /// `Register`
  String get register {
    return Intl.message('Register', name: 'register', desc: '', args: []);
  }

  /// `Choose another name`
  String get chooseAnotherName {
    return Intl.message(
      'Choose another name',
      name: 'chooseAnotherName',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get email {
    return Intl.message('Email', name: 'email', desc: '', args: []);
  }

  /// `Registration`
  String get registration {
    return Intl.message(
      'Registration',
      name: 'registration',
      desc: '',
      args: [],
    );
  }

  /// `Search...`
  String get search {
    return Intl.message('Search...', name: 'search', desc: '', args: []);
  }

  /// `no meetings..(`
  String get noMeetings {
    return Intl.message(
      'no meetings..(',
      name: 'noMeetings',
      desc: '',
      args: [],
    );
  }

  /// `no one..(`
  String get noOne {
    return Intl.message('no one..(', name: 'noOne', desc: '', args: []);
  }

  /// `Name`
  String get nameMeet {
    return Intl.message('Name', name: 'nameMeet', desc: '', args: []);
  }

  /// `Time`
  String get time {
    return Intl.message('Time', name: 'time', desc: '', args: []);
  }

  /// `Location`
  String get location {
    return Intl.message('Location', name: 'location', desc: '', args: []);
  }

  /// `Select a leisure category`
  String get chooseCategory {
    return Intl.message(
      'Select a leisure category',
      name: 'chooseCategory',
      desc: '',
      args: [],
    );
  }

  /// `close`
  String get close {
    return Intl.message('close', name: 'close', desc: '', args: []);
  }

  /// `Add friends`
  String get addFriends {
    return Intl.message('Add friends', name: 'addFriends', desc: '', args: []);
  }

  /// `Your friends`
  String get yourFriends {
    return Intl.message(
      'Your friends',
      name: 'yourFriends',
      desc: '',
      args: [],
    );
  }

  /// `Friend requests`
  String get friendRequests {
    return Intl.message(
      'Friend requests',
      name: 'friendRequests',
      desc: '',
      args: [],
    );
  }

  /// `Friends`
  String get friends {
    return Intl.message('Friends', name: 'friends', desc: '', args: []);
  }

  /// `Categories`
  String get categories {
    return Intl.message('Categories', name: 'categories', desc: '', args: []);
  }

  /// `Your meets`
  String get yourMeets {
    return Intl.message('Your meets', name: 'yourMeets', desc: '', args: []);
  }

  /// `Invitations to a meeting`
  String get meetsRequest {
    return Intl.message(
      'Invitations to a meeting',
      name: 'meetsRequest',
      desc: '',
      args: [],
    );
  }

  /// `Past meetings`
  String get pastMeetings {
    return Intl.message(
      'Past meetings',
      name: 'pastMeetings',
      desc: '',
      args: [],
    );
  }

  /// `Members: `
  String get members {
    return Intl.message('Members: ', name: 'members', desc: '', args: []);
  }

  /// `The time has come`
  String get theTimeHasCome {
    return Intl.message(
      'The time has come',
      name: 'theTimeHasCome',
      desc: '',
      args: [],
    );
  }

  /// `Enter message...`
  String get enterMessage {
    return Intl.message(
      'Enter message...',
      name: 'enterMessage',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ru'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
