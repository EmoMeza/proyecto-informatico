import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationManager {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showNotification(String nombre, String tRestante) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'channel id',
      'channel name',
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iOSNotificationDetails =
        DarwinNotificationDetails();

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iOSNotificationDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      0, // id
      nombre, // titulo
      tRestante, // cuerpo
      notificationDetails, // detalles
    );
  }

  Future<void> scheduleNotification() async {
    const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
        'channel id',
        'channel name',
        importance: Importance.max,
        priority: Priority.high,
      );

    const DarwinNotificationDetails iOSNotificationDetails =
        DarwinNotificationDetails();

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iOSNotificationDetails,
    );

    // final DateTime notificationTime = evento.fecha.subtract(notificationDuration);

    // //convertir a tz
    // final tz.TZDateTime notificationTZDateTime = tz.TZDateTime.from(notificationTime, tz.local);

    // print('Notificación inicial: $notificationTime');
    // print('Notificación programada para: $notificationTZDateTime');

    print('ahora: ${tz.TZDateTime.now(tz.local)}');
    print('5 seg: ${tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5))}');
    print('Zona horaria actual: ${tz.local}');
    print('Zona horaria de Santiago: ${tz.getLocation('America/Santiago')}');
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0, // id del evento
      'prueba', // titulo
      'body', // cuerpo
      //notificationTZDateTime, // fecha programada
      tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
      notificationDetails, // detalles5
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    //print('Notificación programada con id ${evento.id}.');
  }

  Future<int> getActiveNotificationsCount() async {
    final List<PendingNotificationRequest> activeNotifications =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    return activeNotifications.length;
  }

  Future<void> getNotificationDetails(int notificationId) async {
    final List<PendingNotificationRequest> activeNotifications =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();

    final selectedNotification = activeNotifications
        .firstWhere((notification) => notification.id == notificationId);

    if (selectedNotification != null) {
      // Accede a la fecha programada a través de notificationDetails

      // Imprimir detalles de la notificación
      print('Detalles de la notificación con id $notificationId:');
      print('Título: ${selectedNotification.title}');
      print('Cuerpo: ${selectedNotification.body}');
      // Puedes agregar más detalles según tus necesidades

      // Puedes realizar otras acciones con los detalles de la notificación si es necesario
    } else {
      print('No se encontró ninguna notificación con id $notificationId.');
    }
  }

  Future<void> printActiveNotifications() async {
  final List<PendingNotificationRequest> activeNotifications =
      await flutterLocalNotificationsPlugin.pendingNotificationRequests();

  if (activeNotifications.isNotEmpty) {
    print('Notificaciones activas:');
    for (final notification in activeNotifications) {
      print('ID: ${notification.id}');
      print('Título: ${notification.title}');
      print('Cuerpo: ${notification.body}');
      print('---');
    }
  } else {
    print('No hay notificaciones activas en este momento.');
  }
}

  Future<void> cancelAllNotification() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}


class Evento {
  final int id;
  final String nombre;
  final DateTime fecha;

  Evento({required this.id, required this.nombre, required this.fecha});
}

class Notificacion extends StatefulWidget {
  const Notificacion({super.key});

  @override
  State<Notificacion> createState() => _NotificacionState();
}

class _NotificacionState extends State<Notificacion> {
  final NotificationManager notificationManager = NotificationManager();
  
  @override
  void initState() {
    super.initState();
    notificationManager.initializeNotifications();
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Santiago'));
  }
  int notificacionesActivas = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {

            //notificationManager.showNotification("Hola", "Mundo");
            notificationManager.cancelAllNotification();
            final Evento evento = Evento(
              id: 8,
              nombre: 'funciona',
              fecha: DateTime.now(),
            );

            await notificationManager.scheduleNotification();

            notificacionesActivas = await notificationManager.getActiveNotificationsCount();
            print('Notificaciones activas: $notificacionesActivas');

            await notificationManager.getNotificationDetails(0);
          },
          child: const Text('Notificación'),
        ),
      ),
    );
  }
}