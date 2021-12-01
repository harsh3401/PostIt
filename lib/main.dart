import 'package:flutter/material.dart';
import 'package:post_it/views/profile.dart';
import 'views/login.dart';
import 'views/mainpage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'views/Register.dart';
import 'views/profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(home: Mainpage()));
}
