import 'package:rds_qibla/Models/coordinate_data_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CoordinateDataServices {
  CollectionReference _coordinatedataReference =
      FirebaseFirestore.instance.collection('coordinate_data');

  Future<void> setCoordinateData(CoordinateDataModel coordinateData) async {
    try {
      _coordinatedataReference.doc(coordinateData.id).set({
        'name': coordinateData.name,
        'longitude': coordinateData.longitude,
        'latitude': coordinateData.latitude,
        'degree': coordinateData.degree,
        'minute': coordinateData.minute,
        'second': coordinateData.second,
      });
    } catch (e) {
      throw e;
    }
  }

  Future<CoordinateDataModel> getCoordinateDataById(String id) async {
    try {
      DocumentSnapshot snapshot = await _coordinatedataReference.doc(id).get();
      return CoordinateDataModel(
        id: id,
        name: snapshot['name'],
        longitude: snapshot['longitude'],
        latitude: snapshot['latitude'],
        degree: snapshot['degree'],
        minute: snapshot['minute'],
        second: snapshot['second'],
      );
    } catch (e) {
      throw e;
    }
  }
}
