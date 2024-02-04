import 'package:dio/dio.dart';
import 'package:exam_schedule_app/pages/directions_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class DirectionsRepository{
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/directions/json?';

  final Dio _dio;

  DirectionsRepository({Dio? dio}) : _dio = dio ?? Dio();

  Future<Directions>getDirections({
    required LatLng origin,
    required LatLng destination,
  }) async{
    final response = await _dio.get(
      _baseUrl,
      queryParameters: {
        'origin': '${origin.latitude},${origin.longitude}',
        'destination': '${destination.latitude},${destination.longitude}',
        'key': 'AIzaSyAnvQ8PxuLZWZAcsMdmLUXOQ0oMm2scZP8',
      }
    );

    return Directions.fromMap(response.data);
    /*
    if(response.statusCode == 200){
      return Directions.fromMap(response.data);
    }

    return null;
    */
  }
}