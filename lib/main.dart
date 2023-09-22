import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import 'package:step_n_get/account/register.dart';
import 'package:step_n_get/provider/userauth.dart';

import 'package:step_n_get/screens/bottom_navBar.dart';

import 'firebase_options.dart';
import 'provider/pointsprovider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  MobileAds.instance.initialize();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize the user provider and load the user ID from local storage
  final userProvider = UserProvider();
  await userProvider.initUser();

  runApp(
    MultiProvider(
      providers: [
        // Wrap your app with the ChangeNotifierProvider for UserProvider
        ChangeNotifierProvider(create: (_) => userProvider),
        // Add a ChangeNotifierProvider for PointsProvider
        ChangeNotifierProvider(create: (context) => PointsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      // routes: {
      //   'register': (context) => Register(),
      //   // 'verify': (context) => VerifyScreen()
      // },
      // home: Register(),
      home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return BottomNavBar();
            } else {
              return Register();
            }
          }),
    );
  }
}
