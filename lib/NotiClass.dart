import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'exam.dart';

class NotificationServices{
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final AndroidInitializationSettings androidInitializationSettings =  const AndroidInitializationSettings('notification_icon');

  void initialNotification() async {
    InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings
    );

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void sendNotification() async {
    initialNotification();
    AndroidNotificationDetails androidNotificationDetails = const AndroidNotificationDetails(
        "channelId",
        "channelName",
        importance: Importance.max,
        priority: Priority.max
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails
    );

    await flutterLocalNotificationsPlugin.show(
        0,
        'Title',
        "body",
        notificationDetails,
    );
  }


  void scheduleNotification(Map<DateTime, List<Exam>> events) async {

    DateTime now = DateTime.now();
    DateTime? firstUpcomingDateTime = events.keys.first;
    List<Exam>? firstUpcomingExams = events[firstUpcomingDateTime];

    for (DateTime dateTime in events.keys) {
      if (dateTime.isAfter(now)) {
        if(dateTime.isBefore(firstUpcomingDateTime!)){
          firstUpcomingDateTime = dateTime;
          firstUpcomingExams = events[dateTime];
        }
      }
    }

    firstUpcomingExams?.sort((a,b) => a.dateTime.compareTo(b.dateTime));

    if (firstUpcomingDateTime != null && firstUpcomingExams != null) {
      initialNotification();
      AndroidNotificationDetails androidNotificationDetails = const AndroidNotificationDetails(
          "channelId",
          "channelName",
          importance: Importance.max,
          priority: Priority.max
      );

      NotificationDetails notificationDetails = NotificationDetails(
          android: androidNotificationDetails
      );

      print("NOTIFICATION ACTIVATED");

      await flutterLocalNotificationsPlugin.show(
        0,
        'EXAM REMINDER',
        "Upcoming exam: ${firstUpcomingExams[0].name}",
        notificationDetails,
      );
    }




  }
}