import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:photosharing/view/homeScreen/homescreen.dart';
import 'package:photosharing/view/login/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: initialization,
      builder: ((context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text("Welcome to PhotoSharing CLone App"),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text("Some Error occured,Please Wait/.."),
              ),
            ),
          );
        } else {
          return MaterialApp(
              title: "Flutter PhotoSharing App",
              home: FirebaseAuth.instance.currentUser == null
                  ? LoginScreen()
                  : HomeScreen());
        }
      }),
    );
  }
}
