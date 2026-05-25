import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_snack_game/pages/home_page.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyDvjLuiTztjrXKx2H9B-yuAPG0IFW-qOFE",
      authDomain: "snackgame-4a0db.firebaseapp.com",
      projectId: "snackgame-4a0db",
      storageBucket: "snackgame-4a0db.firebasestorage.app",
      messagingSenderId: "576590970482",
      appId: "1:576590970482:web:3894f79df36397f4178ceb",
      measurementId: "G-KKCM0E12WM",
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: HomePage());
  }
}
