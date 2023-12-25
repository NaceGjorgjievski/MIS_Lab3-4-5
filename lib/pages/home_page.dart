import 'package:firebase_auth/firebase_auth.dart';
import 'package:exam_schedule_app/auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../exam.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();



}

class _HomePageState extends State<HomePage>{
  final TextEditingController _controllerExamName = TextEditingController();
  final TextEditingController _controllerDate = TextEditingController();
  DateTime _selectedDate = DateTime.now();

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

  Future<void> _showAddExamDialog(BuildContext context) async{
    return showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(
        title: Text('Add Exam'),
        content: Column(
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
            ElevatedButton(
              onPressed: ()=>_selectDate(context),
              child: Text('Select Date'),
            ),
          ],
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
      );

      _controllerExamName.clear();
    } on FirebaseAuthException catch(e){
      Text('Error creating exam: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _title(),
        actions: <Widget>[
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
                              child: ListTile(
                                title: Text(exams[index].name, style: const TextStyle(fontWeight: FontWeight.bold),),
                                subtitle: Text(DateFormat('dd-MM-yyyy HH:mm').format(exams[index].dateTime)),
                              ),
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
