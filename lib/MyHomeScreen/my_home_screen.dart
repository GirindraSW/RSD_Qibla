import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MyHomeScreen extends StatefulWidget {
  @override
  State<MyHomeScreen> createState() => _MyHomeScreenState();
}

class _MyHomeScreenState extends State<MyHomeScreen> {
  final Completer<GoogleMapController> _controller = Completer();

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(-7.68267222, 109.845025),
    zoom: 17.75,
  );

  final List<Marker> myMarker = [];
  final List<Marker> markerList = const [
    Marker(
      markerId: MarkerId('First'),
      position: LatLng(-7.68267222, 109.845025),
      infoWindow: InfoWindow(
        title: 'Masjid Abdurrahman',
      ),
    ),
    Marker(
      markerId: MarkerId('Second'),
      position: LatLng(-7.74070833, 110.52637222),
      infoWindow: InfoWindow(
        title: 'Masjid Al- Barokah',
      ),
    ),
    Marker(
      markerId: MarkerId('Third'),
      position: LatLng(-7.77902222, 110.30361667),
      infoWindow: InfoWindow(
        title: 'Masjid Al- Hasanah',
      ),
    ),
    Marker(
      markerId: MarkerId('Fourth'),
      position: LatLng(-7.84025833, 110.36602222),
      infoWindow: InfoWindow(
        title: 'Masjid Al Hidayah',
      ),
    ),
    Marker(
      markerId: MarkerId('Fiveth'),
      position: LatLng(-7.74046111, 110.35174167),
      infoWindow: InfoWindow(
        title: 'Masjid Al- Hikmah',
      ),
    ),
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myMarker.addAll(markerList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GoogleMap(
          initialCameraPosition: _initialPosition,
          mapType: MapType.normal,
          markers: Set<Marker>.of(myMarker),
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
        ),
      ),
    );
  }
}
