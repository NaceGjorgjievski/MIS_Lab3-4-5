import 'package:exam_schedule_app/directions_repository.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../exam.dart';
import 'directions_model.dart';

class DirectionsPage extends StatefulWidget{
  final Marker marker;
  final Marker position;

  const DirectionsPage({Key? key, required this.marker,required this.position}) : super(key: key);

  @override
  State<DirectionsPage> createState() => _DirectionsPageState();
}

class _DirectionsPageState extends State<DirectionsPage>{

  static const _initialCameraPosition = CameraPosition(
    target: LatLng(42.00443918426004, 21.409539069200985),
    zoom: 11.5,
  );

  Directions? _info;

  @override
  void initState(){
    super.initState();
    _getDirections();
  }

  Future<void> _getDirections() async {
    final directions = await DirectionsRepository()
        .getDirections(origin: widget.position.position, destination: widget.marker.position);
    setState(() => _info = directions);
  }




  @override
  Widget build(BuildContext context){
    return  Scaffold(
      body: GoogleMap(
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        initialCameraPosition: _initialCameraPosition,
        markers: {widget.marker, widget.position},
        polylines: {
          if(_info != null)
            Polyline(
              polylineId: const PolylineId('overview_polyline'),
              color: Colors.red,
              width: 5,
              points: _info!.polylinePoints
                .map((e) => LatLng(e.latitude, e.longitude))
                .toList(),
            )
        },
      ),
    );
  }
}



