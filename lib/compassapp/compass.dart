import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double? heading = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FlutterCompass.events!.listen((event) {
      setState(() {
        heading = event.heading;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.grey.shade900,
          centerTitle: true,
          title: Text(
            "Compass App",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "${heading!.ceil()}",
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(18),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset("assets/cadrant.png"),
                  Transform.rotate(
                    angle: ((heading ?? 0) * (pi / 180) * -1),
                    child: Image.asset(
                      "assets/compass.png",
                      scale: 1.1,
                    ),
                  ),
                ],
              ),
            )
          ],
        ));
  }
}
