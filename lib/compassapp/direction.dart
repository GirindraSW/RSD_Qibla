import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;

class CompassPage extends StatefulWidget {
  @override
  _CompassPageState createState() => _CompassPageState();
}

class _CompassPageState extends State<CompassPage> {
  List<Map<String, double>> directions = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchDirectionData();
  }

  Future<void> _fetchDirectionData() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('coordinate_data').get();

      List<Map<String, double>> fetchedDirections = [];
      querySnapshot.docs.forEach((DocumentSnapshot document) {
        Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
        fetchedDirections.add({
          'degree': data['degree'].toDouble(),
          'minute': data['minute'].toDouble(),
          'second': data['second'].toDouble(),
        });
      });

      setState(() {
        directions = fetchedDirections;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching direction data: $e';
        isLoading = false;
      });
      print('Error fetching direction data: $e');
    }
  }

  double _calculateAngle(Map<String, double> direction) {
    return direction['degree']! +
        (direction['minute']! / 60) +
        (direction['second']! / 3600);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Compass'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              CircularProgressIndicator()
            else if (errorMessage.isNotEmpty)
              Text(errorMessage)
            else if (directions.isNotEmpty)
              Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset('assets/compass_background.png'),
                  Transform.rotate(
                    angle: _calculateAngle(directions[0]) * (math.pi / 180),
                    child: Image.asset('assets/compass_needle.png'),
                  ),
                ],
              ),
            SizedBox(height: 20),
            if (!isLoading && errorMessage.isEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: directions.length,
                  itemBuilder: (context, index) {
                    final direction = directions[index];
                    return ListTile(
                      title: Text(
                        "${direction['degree']}° ${direction['minute']}' ${direction['second']}\"",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
