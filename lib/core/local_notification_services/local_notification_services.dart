// import 'dart:async';
// import 'dart:io';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_timezone/flutter_timezone.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:timezone/data/latest_all.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;
//
// class LocalNotificationServices {
//   // ✅ Singleton setup
//   static final LocalNotificationServices _instance = LocalNotificationServices._internal();
//   factory LocalNotificationServices() => _instance;
//   LocalNotificationServices._internal();
//
//   static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//   FlutterLocalNotificationsPlugin();
//
//   static String? _timeZone;
//
//   static StreamController<NotificationResponse> streamController =StreamController();
//
//   static Future<void> onTap(NotificationResponse notificationResponse) async {
//     print("🔔 Notification tapped with payload: ${notificationResponse.payload}");
//     if (notificationResponse.id != null) {
//       // await  LocalNotificationServices.cancelNotification(id: notificationResponse.id!);
//     }
//
//     streamController.add(notificationResponse);
//   }
//
//   static Future<void> init() async {
//     tz.initializeTimeZones();
//     _timeZone = await FlutterTimezone.getLocalTimezone();
//     tz.setLocalLocation(tz.getLocation(_timeZone!));
//
//     final settings = InitializationSettings(
//       android: AndroidInitializationSettings('@mipmap/ic_launcher'),
//       iOS: DarwinInitializationSettings(),
//     );
//
//     await flutterLocalNotificationsPlugin.initialize(
//       settings,
//       onDidReceiveNotificationResponse: onTap,
//       onDidReceiveBackgroundNotificationResponse: onTap,
//     );
//
//     if (Platform.isAndroid) {
//       var status = await Permission.notification.status;
//       if (status.isDenied || status.isPermanentlyDenied) {
//         final result = await Permission.notification.request();
//         if (result.isGranted) {
//           print('✅ تم منح إذن الإشعارات');
//         }
//       }
//     }
//   }
//
//   static Future<void> showBasicNotification({
//     String title = "title",
//     String body = "body",
//     int id = 0,
//     String? payload,
//     String? soundPath,
//   }) async {
//     final notificationDetails = NotificationDetails(
//       android: AndroidNotificationDetails(
//
//         //soundPathشيل منه assets/
//         sound: (soundPath!=null)?RawResourceAndroidNotificationSound(soundPath.split('.').first):null,
//
//
//
//         'id_0',
//         'basic notification',
//         importance: Importance.max,
//         priority: Priority.high,
//         visibility: NotificationVisibility.public,
//         autoCancel: false, // ما يختفيش لو الشاشة اتقفلت
//       ),
//       iOS: DarwinNotificationDetails(),
//     );
//
//     await flutterLocalNotificationsPlugin.show(
//       id,
//       title,
//       body,
//       notificationDetails,
//       payload: payload,
//     );
//   }
//
//
//
//   static Future<void> showRepeatedNotification({
//     String title = "title",
//     String body = "body",
//     int id = 1,
//     String? payload,
//     String? soundPath,
//
//     RepeatInterval interval = RepeatInterval.everyMinute,
//   }) async {
//     await flutterLocalNotificationsPlugin
//         .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
//         ?.requestExactAlarmsPermission();
//
//     final notificationDetails = NotificationDetails(
//       android: AndroidNotificationDetails(
//         'id_1',
//         'repeated notification',
//
//
//         //soundPathشيل منه assets/
//         sound: (soundPath!=null)?RawResourceAndroidNotificationSound(soundPath.split('.').first):null,
//
//
//         importance: Importance.max,
//         priority: Priority.high,
//         visibility: NotificationVisibility.public,
//         autoCancel: false, // ما يختفيش لو الشاشة اتقفلت
//       ),
//       iOS: DarwinNotificationDetails(),
//     );
//
//     await flutterLocalNotificationsPlugin.periodicallyShow(
//       id,
//       title,
//       body,
//       interval,
//       notificationDetails,
//       payload: payload,
//       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//     );
//   }
//
//   static Future<void> showScheduledNotification({
//     required bool isDaily,
//     int id = 2,
//     String title = "title",
//     String body = "body",
//     int hour = 12,
//     int minute = 0,
//     String? soundPath,
//     String? payload,
//   }) async {
//     await flutterLocalNotificationsPlugin
//         .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
//         ?.requestExactAlarmsPermission();
//
//     final notificationDetails = NotificationDetails(
//       android: AndroidNotificationDetails(
//         'id_2',
//         'scheduled notification',
//
//
//
//         //soundPathشيل منه assets/
//         sound: (soundPath!=null)?RawResourceAndroidNotificationSound(soundPath.split('.').first):null,
//
//
//
//
//         importance: Importance.max,
//         priority: Priority.high,
//         playSound: true,
//         visibility: NotificationVisibility.public,
//         autoCancel: false, // ما يختفيش لو الشاشة اتقفلت
//       ),
//       iOS: DarwinNotificationDetails(),
//     );
//
//     final scheduleTime = await _nextInstanceOfTime(hour, minute);
//
//     await flutterLocalNotificationsPlugin.zonedSchedule(
//       id,
//       title,
//       body,
//       scheduleTime,
//       notificationDetails,
//       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//       matchDateTimeComponents: isDaily ? DateTimeComponents.time : null,
//       payload: payload,
//     );
//   }
//
//   static Future<void> cancelNotification({required int id}) async {
//     await flutterLocalNotificationsPlugin.cancel(id);
//   }
//
//   static Future<void> cancelAllNotification() async {
//     await flutterLocalNotificationsPlugin.cancelAll();
//   }
//
//   static Future<tz.TZDateTime> _nextInstanceOfTime(int hour, int minute) async {
//     final location = tz.getLocation(_timeZone ?? await FlutterTimezone.getLocalTimezone());
//
//     final now = tz.TZDateTime.now(location);
//     var scheduledDate = tz.TZDateTime(location, now.year, now.month, now.day, hour, minute);
//
//     if (scheduledDate.isBefore(now)) {
//       scheduledDate = scheduledDate.add(Duration(days: 1));
//     }
//
//     return scheduledDate;
//   }
// }
