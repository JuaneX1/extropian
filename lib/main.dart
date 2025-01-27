import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:extropian/auth/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if(kIsWeb){
    await Firebase.initializeApp(options: const FirebaseOptions(
      apiKey: "AIzaSyCyXdK8Nz7cdCuVkvW6aA8xB0TahTi9NPs",
      authDomain: "ucfproject-3d077.firebaseapp.com",
      projectId: "ucfproject-3d077",
      storageBucket: "ucfproject-3d077.firebasestorage.app",
      messagingSenderId: "911713877672",
      appId: "1:911713877672:web:1eb29f42676184c4b20c9d",
      measurementId: "G-8J89T7FNYC"
    ));
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        debugShowCheckedModeBanner: false, home: LoginPage());
  }
}
