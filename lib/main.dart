import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // Firebase.initializeApp(
  //     options: FirebaseOptions(
  //         apiKey: "AIzaSyA8fzfImo8PgTyup_NI-gkwLuPIKD_NdEk",
  //         authDomain: "bus-system-641e0.firebaseapp.com",
  //         projectId: "bus-system-641e0",
  //         storageBucket: "bus-system-641e0.firebasestorage.app",
  //         messagingSenderId: "702515887588",
  //         appId: "1:702515887588:web:fc42a25a7e9634001e1bf1"));
  runApp(MaterialApp(
    home: LoginPage(),
    debugShowCheckedModeBanner: false,
    //home: AdminPage(),
  ));
}
