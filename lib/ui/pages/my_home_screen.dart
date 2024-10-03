import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MyHomeScreen extends StatefulWidget {
  @override
  State<MyHomeScreen> createState() => _MyHomeScreenState();
}

class _MyHomeScreenState extends State<MyHomeScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final Stream<QuerySnapshot> _dataStream =
      FirebaseFirestore.instance.collection('coordinate_data').snapshots();

  CameraPosition _initialPosition = CameraPosition(
    target: LatLng(-7.68267222, 109.845025),
    zoom: 12.0,
  );

  List<Marker> myMarker = [];
  List<Map<String, dynamic>> nearestPlaces = [];
  double? compassAngle; // Angle for the compass needle

  @override
  void initState() {
    super.initState();
    packData();
  }

  Future<Position> getUserLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) {
      print('error$error');
    });
    return await Geolocator.getCurrentPosition();
  }

  void findNearestLocations(
      Position userPosition, List<QueryDocumentSnapshot> docs) {
    List<Map<String, dynamic>> places = docs.map((doc) {
      Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;

      double distance = _calculateDistance(userPosition.latitude,
          userPosition.longitude, data['latitude'], data['longitude']);
      return {
        'name': data['name'],
        'latitude': data['latitude'],
        'longitude': data['longitude'],
        'degree': data['degree'], // Direction values
        'minute': data['minute'],
        'second': data['second'],
        'distance': distance
      };
    }).toList();

    // Sort by distance
    places.sort((a, b) => a['distance'].compareTo(b['distance']));
    nearestPlaces = places.take(3).toList(); // Take 3 nearest places

    if (nearestPlaces.isNotEmpty) {
      _setCompassDirection(nearestPlaces[0]); // Use the first nearest place
    }

    setState(() {});
  }

  double _calculateDistance(
      double lat1, double lng1, double lat2, double lng2) {
    return ((lat1 - lat2) * (lat1 - lat2)) + ((lng1 - lng2) * (lng1 - lng2));
  }

  void _setCompassDirection(Map<String, dynamic> direction) {
    // Convert all values to double to avoid the type 'int' is not a subtype of type 'double' error
    double degree = direction['degree'].toDouble();
    double minute = direction['minute'].toDouble();
    double second = direction['second'].toDouble();

    // Calculate the angle for the compass needle
    compassAngle = degree + (minute / 60) + (second / 3600);

    // Debugging: Print the compass angle to the console
    print("Compass Angle: $compassAngle");
  }

  packData() {
    getUserLocation().then((value) async {
      print('My Location: ${value.latitude} ${value.longitude}');

      myMarker.add(
        Marker(
          markerId: MarkerId('MyLocation'),
          position: LatLng(value.latitude, value.longitude),
          infoWindow: InfoWindow(
            title: 'My Location',
          ),
        ),
      );

      CameraPosition cameraPosition = CameraPosition(
        target: LatLng(value.latitude, value.longitude),
        zoom: 17.0,
      );
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _dataStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return textResult('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return textResult("Loading");
        }

        // Clear existing markers
        myMarker.clear();

        // Add markers from Firestore data
        snapshot.data!.docs.forEach((DocumentSnapshot document) {
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          LatLng location = LatLng(data['latitude'], data['longitude']);

          myMarker.add(
            Marker(
              markerId: MarkerId(document.id),
              position: location,
              infoWindow: InfoWindow(
                title: data['name'],
              ),
            ),
          );
        });

        // Find nearest locations after fetching data
        getUserLocation().then((userPosition) {
          findNearestLocations(userPosition, snapshot.data!.docs);
        });

        return Scaffold(
          appBar: AppBar(
            title: Text('RSD Qibla'),
          ),
          body: Stack(
            children: [
              GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: _initialPosition,
                markers: Set<Marker>.of(myMarker),
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: false, // Removed the default button
              ),
              Positioned(
                bottom: 20.0,
                left: 20.0,
                child: FloatingActionButton(
                  onPressed: () {
                    packData();
                  },
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  child: Image.asset(
                    'assets/current_location_icon.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: 80.0, // Adjust position
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.white.withOpacity(0.8),
                  height: 150.0, // Height of the list
                  child: nearestPlaces.isNotEmpty
                      ? ListView.builder(
                          itemCount: nearestPlaces.length,
                          itemBuilder: (context, index) {
                            final place = nearestPlaces[index];
                            return ListTile(
                              title: Text(place['name']),
                              subtitle: Text(
                                  'Lat: ${place['latitude']}, Lng: ${place['longitude']}, Distance: ${place['distance'].toStringAsFixed(2)} km'),
                            );
                          },
                        )
                      : Center(child: Text('No nearby locations found')),
                ),
              ),
              // Compass widget floating in the center of the map
              if (compassAngle != null)
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 300, // Size of the compass
                    height: 300,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(
                          'assets/compass_background.png',
                          fit: BoxFit.contain,
                        ), // Compass background
                        Transform.rotate(
                          angle: compassAngle! * (math.pi / 180),
                          child: Image.asset(
                            'assets/compass_needle.png',
                            fit: BoxFit.contain,
                          ), // Compass needle
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget textResult(String text) {
    return Scaffold(
      body: Center(
        child: Text(text),
      ),
    );
  }
}
