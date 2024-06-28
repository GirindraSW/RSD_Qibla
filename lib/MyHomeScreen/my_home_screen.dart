import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;

class MyHomeScreen extends StatefulWidget {
  @override
  State<MyHomeScreen> createState() => _MyHomeScreenState();
}

class _MyHomeScreenState extends State<MyHomeScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final Stream<QuerySnapshot> _dataStream =
      FirebaseFirestore.instance.collection('coordinate_data').snapshots();

  loc.LocationData? currentLocation;
  loc.Location location = loc.Location();

  CameraPosition _initialPosition = CameraPosition(
    target: LatLng(-7.68267222, 109.845025),
    zoom: 12.0,
  );

  List<Marker> myMarker = []; // List to store markers

  @override
  void initState() {
    super.initState();
    _getLocation();
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
          double latitude = data['latitude'];
          double longitude = data['longitude'];
          LatLng location = LatLng(latitude, longitude);

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

        return Scaffold(
          body: GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _initialPosition,
            markers: Set<Marker>.of(myMarker),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
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

  Future<void> _getLocation() async {
    bool serviceEnabled;
    loc.PermissionStatus permissionStatus;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionStatus = await location.hasPermission();
    if (permissionStatus == loc.PermissionStatus.denied) {
      permissionStatus = await location.requestPermission();
      if (permissionStatus != loc.PermissionStatus.granted) {
        return;
      }
    }

    loc.LocationData _locationData = await location.getLocation();
    setState(() {
      currentLocation = _locationData;
      _initialPosition = CameraPosition(
        target: LatLng(
          _locationData.latitude ?? 0,
          _locationData.longitude ?? 0,
        ),
        zoom: 12.0,
      );
    });
  }
}
