import 'dart:async';

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

  List<Marker> myMarker = []; // List to store markers

  @override
  void initState() {
    super.initState();
    // packData();
  }

  Future<Position> getUserLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) {
      print('error$error');
    });

    return await Geolocator.getCurrentPosition();
  }

  packData() {
    getUserLocation().then((value) async {
      print('My Location');
      print('${value.latitude} ${value.longitude}');

      myMarker.add(
        Marker(
          markerId: MarkerId('Second'),
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
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              packData();
            },
            child: Icon(Icons.radio_button_off),
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
