import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class SetLocationMapPage extends StatefulWidget{
  const SetLocationMapPage({Key? key}) : super(key: key);

  @override
  State<SetLocationMapPage> createState() => _SetLocationMapPageState();
}

class _SetLocationMapPageState extends State<SetLocationMapPage>{

  static const _initialCameraPosition = CameraPosition(
    target: LatLng(42.00443918426004, 21.409539069200985),
    zoom: 11.5,
  );



  var _location;

  LatLng? _selectedLocation;

  void _addMarker(LatLng pos){
    setState(() {
      _location = Marker(
        markerId: const MarkerId('location'),
        infoWindow: const InfoWindow(title: "Location of Exam"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        position: pos,
      );
    });

    _selectedLocation = pos;
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: GoogleMap(
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        initialCameraPosition: _initialCameraPosition,
        markers: {
          if(_location != null) _location,
        },
        onTap: _addMarker,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.black,
        onPressed: () {
          if(_selectedLocation != null){
            Navigator.pop(context, _selectedLocation);
          }
          else{
            Navigator.pop(context);
          }
           // Go back to the previous screen (dialog)
        },
        child: const Icon(Icons.arrow_back),
      ),
    );
  }
}