import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:step_n_get/account/register.dart';
import 'package:step_n_get/account/sign_in.dart';
import 'package:step_n_get/account/verify_screen.dart';
import 'package:step_n_get/firebase/firebase_options.dart';
import 'package:step_n_get/account/signup.dart';
import 'package:step_n_get/screens/bottom_navBar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      routes: {
        'register': (context) => Register(),
        'verify': (context) => VerifyScreen()
      },
      home: Register(),
      // home: StreamBuilder(
      //   stream: FirebaseAuth.instance.authStateChanges(),
      //   builder: (context, snapshot){
      //     if (snapshot.hasData){
      //       return BottomNavBar();
      //     }
      //    else {
      //     return SignInScreen();
      //    }
      //   }
      //
      //   ),
    );
  }
}