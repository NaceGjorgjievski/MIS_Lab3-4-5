import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../exam.dart';

class CalendarPage extends StatefulWidget{
  final Map<DateTime,List<Exam>> events;

  const CalendarPage({Key? key, required this.events}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}


class _CalendarPageState extends State<CalendarPage>{

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late final ValueNotifier<List<Exam>> _selectedEvents;

  @override
  void initState(){
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay){
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _selectedEvents.value = _getEventsForDay(selectedDay);
    });
  }

  List<Exam> _getEventsForDay(DateTime day){
    DateTime td = DateTime(
      day.year,
      day.month,
      day.day
    );
    print("The day is ${td}");
    print(widget.events[td]);
    return widget.events[td] ?? [];
  }

  Widget content(){
    return Column(
      children: [
        Container(
          child: TableCalendar(
            headerStyle: const HeaderStyle(formatButtonVisible: false),
            focusedDay: _focusedDay,
            firstDay: DateTime(2020,10,16),
            lastDay: DateTime(2030,10,16),
            selectedDayPredicate: (day) => isSameDay(_selectedDay,day),
            onDaySelected: _onDaySelected,
            eventLoader: _getEventsForDay,
          ),
        ),
        const SizedBox(height: 8.0),
        Expanded(
            child: ValueListenableBuilder(
                valueListenable: _selectedEvents,
                builder: (context, value, _){
                  return ListView.builder(
                      itemCount: value.length,
                      itemBuilder: (context, index){
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                              title: Text('${value[index].name}'),
                              subtitle: Text("${DateFormat('HH:mm').format(value[index].dateTime)}"),),
                        );
                      });
                }))

      ],
    );
  }

  @override
  Widget build(BuildContext context){
    print("Hello");
    print("${widget.events}");
    print("${_selectedEvents}");
    return Scaffold(
      appBar: AppBar(title: const Text("Your events")),
      body: content(),
    );
  }


}