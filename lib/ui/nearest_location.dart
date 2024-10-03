import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return Future.error('Location permissions are permanently denied.');
      }
    }

    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied.');
    }

    return await Geolocator.getCurrentPosition();
  }
}

class Place {
  final String name;
  final double latitude;
  final double longitude;

  Place({required this.name, required this.latitude, required this.longitude});

  factory Place.fromDocument(DocumentSnapshot doc) {
    return Place(
      name: doc['name'],
      latitude: doc['latitude'],
      longitude: doc['longitude'],
    );
  }
}

double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  return sqrt(pow(lat1 - lat2, 2) + pow(lon1 - lon2, 2));
}

Future<List<Place>> fetchAndSortPlaces(Position userPosition) async {
  final firestore = FirebaseFirestore.instance;
  final snapshot = await firestore.collection('coordinate_data').get();
  List<Place> places =
      snapshot.docs.map((doc) => Place.fromDocument(doc)).toList();

  places.sort((a, b) {
    double distanceA = calculateDistance(
        userPosition.latitude, userPosition.longitude, a.latitude, a.longitude);
    double distanceB = calculateDistance(
        userPosition.latitude, userPosition.longitude, b.latitude, b.longitude);
    return distanceA.compareTo(distanceB);
  });

  return places.take(3).toList(); // Return the top 3 closest places
}

class NearestPlacesWidget extends StatefulWidget {
  @override
  _NearestPlacesWidgetState createState() => _NearestPlacesWidgetState();
}

class _NearestPlacesWidgetState extends State<NearestPlacesWidget> {
  Position? _currentPosition;
  List<Place> _nearestPlaces = [];
  bool _loading = true;

  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _fetchLocationAndSortPlaces();
  }

  Future<void> _fetchLocationAndSortPlaces() async {
    try {
      _currentPosition = await _locationService.determinePosition();
      _nearestPlaces = await fetchAndSortPlaces(_currentPosition!);
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: _nearestPlaces.length,
      itemBuilder: (context, index) {
        final place = _nearestPlaces[index];
        return ListTile(
          title: Text(place.name),
          subtitle: Text(
              'Latitude: ${place.latitude}, Longitude: ${place.longitude}'),
        );
      },
    );
  }
}
