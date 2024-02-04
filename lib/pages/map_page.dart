import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../exam.dart';

class MapPage extends StatefulWidget{
  final List<Marker> markers;

  const MapPage({Key? key, required this.markers}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage>{

  static const _initialCameraPosition = CameraPosition(
    target: LatLng(42.00443918426004, 21.409539069200985),
    zoom: 11.5,
  );


  @override
  Widget build(BuildContext context){
    return  Scaffold(
      body: GoogleMap(
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        initialCameraPosition: _initialCameraPosition,
        markers: Set.from(widget.markers),
      ),
    );
  }
}



