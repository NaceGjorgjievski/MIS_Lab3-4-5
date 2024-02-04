import 'package:exam_schedule_app/NotiClass.dart';
import 'package:exam_schedule_app/pages/directions_page.dart';
import 'package:exam_schedule_app/pages/map_page.dart';
import 'package:exam_schedule_app/pages/set_location_map_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:exam_schedule_app/auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:geolocator/geolocator.dart';

import '../exam.dart';
import 'calendar_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();



}

class _HomePageState extends State<HomePage>{
  final TextEditingController _controllerExamName = TextEditingController();
  final TextEditingController _controllerDate = TextEditingController();
  final TextEditingController _controllerLocation = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  Map<DateTime, List<Exam>> _events = {};
  List<Marker> markers = [];

  double? examLongitude;
  double? examLatitude;

  Position? userPosition;

  NotificationServices notificationServices = NotificationServices();

  final User? user = Auth().currentUser;

  Future<void> signOut() async {
    await Auth().signOut();
  }

  Widget _title() {
    return const Text('Exam Scheduler');
  }

  Widget _userUid() {
    return Text(user?.email ?? '');
  }

  Widget _signOutButton() {
    return ElevatedButton(
      onPressed: signOut,
      child: const Text('Sign Out'),
    );
  }

  Future<void> _showSetLocation(BuildContext context) async{
    LatLng? selectedLocation = await showDialog(
      context: context,
      builder: (BuildContext context){
        return SetLocationMapPage();
      },
    );

    if(selectedLocation != null){
      setState(() {
        _controllerLocation.text = "(${selectedLocation.latitude}, ${selectedLocation.longitude})";
        examLongitude = selectedLocation.longitude;
        examLatitude = selectedLocation.latitude;
      });
    } else {
      _controllerLocation.text = "No location selected";
    }
  }

  Future<void> _showAddExamDialog(BuildContext context) async{
    return showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(
        title: Text('Add Exam'),
        content: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              TextField(
                controller: _controllerExamName,
                decoration: const InputDecoration(labelText: 'Exam Name'),
              ),
              TextField(
                readOnly: true,
                enabled: false,
                enableInteractiveSelection: false,
                controller: _controllerDate,
                decoration: const InputDecoration(labelText: 'Date'),
              ),
              TextField(
                readOnly: true,
                enabled: false,
                enableInteractiveSelection: false,
                controller: _controllerLocation,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              ElevatedButton(
                onPressed: ()=>_selectDate(context),
                child: const Text('Select Date'),
              ),
              ElevatedButton(
                onPressed: (){
                  _showSetLocation(context);
                },
                child: const Text('Set Location'),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
              onPressed: (){
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
          ),
          ElevatedButton(
              onPressed: (){
                _createExam();
                notificationServices.scheduleNotification(_events);
                Navigator.of(context).pop();
              },
              child: Text('Add'),
          ),
        ],
      );
    },);
  }

  Future<void> _selectDate(BuildContext context) async{
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2101)
    );

    if(picked != null){
      TimeOfDay? selectedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );

      if(picked != null){
        setState(() {
          _selectedDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            selectedTime!.hour,
            selectedTime.minute,
          );

          String formatedDateTime = DateFormat('dd-MM-yyyy HH:mm').format(_selectedDate);
          _controllerDate.text = formatedDateTime;
        });
      }
    }
  }

  Future<void> _createExam() async{
    try{
      await Auth().createExam(
        name: _controllerExamName.text,
        dateTime: _selectedDate,
        latitude: examLatitude ?? 0,
        longitude: examLongitude ?? 0,
      );

      _controllerExamName.clear();
      _controllerDate.clear();
      _controllerLocation.clear();
    } on FirebaseAuthException catch(e){
      Text('Error creating exam: $e');
    }
  }

  void _updateEvents(List<Exam> exams){
    _events = {};
    for (var exam in exams) {
      DateTime date = DateTime(
        exam.dateTime.year,
        exam.dateTime.month,
        exam.dateTime.day,
      );

      if (_events[date] == null) {
        _events[date] = [];
      }

      _events[date]!.add(exam);
    }

    for(Exam exam in exams){
      markers.add(Marker(
        markerId: const MarkerId('location'),
        infoWindow:  InfoWindow(title: exam.name,),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        position: LatLng(exam.latitude,exam.longitude),
      ));
    }


  }

  Marker _makeMarker(Exam exam){
    return Marker(
      markerId: const MarkerId('location'),
      infoWindow:  InfoWindow(title: exam.name,),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      position: LatLng(exam.latitude,exam.longitude),
    );
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  void _savePostion() async{
    userPosition = await _determinePosition();
  }








  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _title(),
        actions: <Widget>[
          IconButton(
              onPressed: (){
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>  MapPage(markers: markers,))
                );
              },
              icon: const Icon(Icons.map_sharp)),
          IconButton(
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CalendarPage(events: _events,))
                );
              },
              icon: const Icon(Icons.calendar_month)),
          IconButton(onPressed: ()=>_showAddExamDialog(context), icon: const Icon(Icons.add))
        ],
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            _userUid(),
            _signOutButton(),
            const SizedBox(height: 20),
            Text('Your Exams: '),
            Expanded(
                child: StreamBuilder<List<Exam>>(
                  stream: Auth().getExams(),
                  builder: (context, snapshot) {
                    if(snapshot.hasData){
                      List<Exam> exams = snapshot.data!;
                      _updateEvents(exams);
                      return GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8.0,
                            mainAxisSpacing: 8.0,
                          ),
                          itemCount: exams.length,
                          itemBuilder: (context, index) {
                            return Card(
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(width: 2.0, color: Colors.black),
                                borderRadius: BorderRadius.circular(8.0)
                              ),
                              child: Column(
                                children: [
                                  ListTile(
                                    title: Text(exams[index].name, style: const TextStyle(fontWeight: FontWeight.bold),),
                                    subtitle: Text(DateFormat('dd-MM-yyyy HH:mm').format(exams[index].dateTime)),
                                  ),
                                  ElevatedButton(onPressed: () async {
                                    Position position = await _determinePosition();
                                    Marker userMarker = Marker(
                                      markerId: const MarkerId('location'),
                                      infoWindow:  InfoWindow(title: 'My location',),
                                      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                                      position: LatLng(position.latitude,position.longitude),
                                    );
                                    if(position != null){
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => DirectionsPage(marker: _makeMarker(exams[index]),position: userMarker,)));
                                    }

                                  },child:Text('Get Direction'))
                                ],
                              )
                            );
                          },
                      );
                    } else{
                      return Text('Loading exams...');
                    }
                  },
                )),
          ],
        ),
      ),
    );
  }
}
