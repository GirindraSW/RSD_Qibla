import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:rds_qibla/ui/pages/my_home_screen.dart';
// import 'package:rds_qibla/ui/nearest_location.dart';
// import 'package:rds_qibla/compassapp/compass.dart';
// import 'package:rds_qibla/compassapp/direction.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Platform.isAndroid
      ? await Firebase.initializeApp(
          options: const FirebaseOptions(
          apiKey: "WOW",
          appId: "1:739784990220:android:eef744b9f9bf99cad55829",
          messagingSenderId: "739784990220",
          projectId: "rdsqibla",
        ))
      : await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomeScreen(),
    );
  }
}

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(title: Text('Nearest Places')),
//         body: NearestPlacesWidget(),
//       ),
//     );
//   }
// }
