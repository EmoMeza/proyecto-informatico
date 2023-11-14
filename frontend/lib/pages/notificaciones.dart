import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';


class NotificationStorage {
  static const String _notificationMapKey = 'notificationMap';

  final SharedPreferences _prefs;
  Map<String, int> _eventToNotificationIdMap = {};

  NotificationStorage(this._prefs);

  Map<String, int> get eventToNotificationIdMap => _eventToNotificationIdMap;

  Future<void> loadNotificationMap() async {
    final String? notificationMapString = _prefs.getString(_notificationMapKey);
    if (notificationMapString != null) {
      final Map<String, dynamic> notificationMap =
          Map<String, dynamic>.from(jsonDecode(notificationMapString));
      _eventToNotificationIdMap = notificationMap.map(
          (key, value) => MapEntry<String, int>(key, value as int));
    }
  }

  Future<void> saveNotificationMap() async {
    await _prefs.setString(
        _notificationMapKey, jsonEncode(_eventToNotificationIdMap));
  }

  Future<void> clearNotificationMap() async {
    _eventToNotificationIdMap.clear();
    await saveNotificationMap();
  }
}
class NotificationManager {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  late SharedPreferences _prefs;
  late NotificationStorage _notificationStorage;

  NotificationManager() {
    _init();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    _notificationStorage = NotificationStorage(_prefs);
    await _notificationStorage.loadNotificationMap();

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

  Future<void> scheduleNotification(Evento evento, Duration scheduledHour) async {

    // Eliminar notificaciones del mapa que ya pasaron
    await deleteOldNotifications();

    // ------ Inicializar notificaciones ------ //
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

    // ------ Calcular fecha de notificación ------ //
    final DateTime notificationDate = evento.fecha.subtract(scheduledHour);
    final tz.TZDateTime notificationTZDateTime =
        tz.TZDateTime.from(notificationDate, tz.local);

    print('Fecha de evento: ${evento.fecha}.');
    print('Fecha de notificación: $notificationTZDateTime.');

    // ------ Guardar id de notificación ------ //
    int notificationId = -1;
    if (_notificationStorage.eventToNotificationIdMap.containsKey(evento.id)) {
      // Cancelar notificación anterior si existe
      await flutterLocalNotificationsPlugin.cancel(
          _notificationStorage.eventToNotificationIdMap[evento.id]!);
      notificationId =
          _notificationStorage.eventToNotificationIdMap[evento.id]!;
    } else {
      // Generar nuevo id de notificación
      notificationId = DateTime.now().millisecondsSinceEpoch % (1 << 31);
      _notificationStorage.eventToNotificationIdMap[evento.id] = notificationId;
    }

    print('Notificación programada con id $notificationId.');

    // Imprimir el mapa
    print('Mapa de notificaciones:');
    _notificationStorage.eventToNotificationIdMap.forEach((key, value) {
      print('Evento: $key, id de notificación: $value');
    });

    String message = formatDuration(scheduledHour, evento.nombre);

    // ------ Programar notificaciones ------ //
    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId, // id de notificación
      evento.nombre, // titulo
      message,// cuerpo
      notificationTZDateTime, // fecha programada
      notificationDetails, // detalles5
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    // Guardar el mapa actualizado
    await _notificationStorage.saveNotificationMap();
  }

  //Funcion para formatear un mensaje segun el tiempo restante
  String formatDuration(Duration duration, String titulo) {
    String message = '';
    String faltanText = duration.inMinutes == 1 ? 'Falta' : 'Faltan';

    if (duration.inDays > 0) {
      message = '$faltanText ${duration.inDays} día${duration.inDays == 1 ? '' : 's'} para $titulo.';
    } else if (duration.inHours > 0) {
      message = '$faltanText ${duration.inHours} hora${duration.inHours == 1 ? '' : 's'} para $titulo.';
    } else if (duration.inMinutes > 0) {
      message = '$faltanText ${duration.inMinutes} minuto${duration.inMinutes == 1 ? '' : 's'} para $titulo.';
    } else if (duration.inSeconds > 0) {
      message = 'Falta menos de 1 minuto para $titulo.';
    } else {
      message = '¡$titulo ya comenzó!';
    }

    return message;
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
  //Eliminar notificaciones del mapa que ya pasaron
  Future<void> deleteOldNotifications() async {

    final List<PendingNotificationRequest> activeNotifications =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
      
    // Si no hay notificaciones activas, elimino todas las notificaciones del mapa
    if (activeNotifications.isEmpty) {
      await _notificationStorage.clearNotificationMap();
      return;
    }

    // Obtengo los ids de las notificaciones activas
    final List<int> activeNotificationIds = 
      activeNotifications.map((notification) => notification.id).toList();

    // Creo una lista de claves que quiero eliminar
    final List<String> keysToRemove = [];

    // Recorro el mapa y añado las claves a la lista de claves a eliminar si no están en la lista de notificaciones activas
    _notificationStorage.eventToNotificationIdMap.forEach((key, value) {
      if (!activeNotificationIds.contains(value)) {
        keysToRemove.add(key);
      }
    });

    // Elimino las claves de la lista del mapa
    for (var key in keysToRemove) {
      _notificationStorage._eventToNotificationIdMap.remove(key);
    }

    // Guardo el mapa
    await _notificationStorage.saveNotificationMap();
  }

  //Imprimir el mapa
  Future<void> printNotificationMap() async {
    print('Mapa de notificaciones:');
    _notificationStorage.eventToNotificationIdMap.forEach((key, value) {
      print('Evento: $key, id de notificación: $value');
    });
  }
}


class Evento {
  final String id;
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
  late final NotificationManager notificationManager;
  
  @override
  void initState() {
    super.initState();
    notificationManager = NotificationManager();
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
            
            //notificationManager.cancelAllNotification();
            final Evento evento = Evento(
              id: '2',
              nombre: 'funciona',
              fecha: DateTime.now().add(const Duration(seconds: 30)),
            );

            // final Evento evento2 = Evento(
            //   id: '2',
            //   nombre: 'funciona2',
            //   fecha: DateTime.now().add(const Duration(minutes: 5)),
            // );

            Duration cuantoFalta = const Duration(seconds: 10);
            await notificationManager.scheduleNotification(evento, cuantoFalta);

            // await notificationManager.scheduleNotification(evento2, const Duration(seconds: 120));

            //Imprimir mapa
            //await notificationManager.printNotificationMap();

            //Imprimir notificaciones activas
            //await notificationManager.printActiveNotifications();

            notificacionesActivas = await notificationManager.getActiveNotificationsCount();
            print('Notificaciones activas: $notificacionesActivas');
          },
          child: const Text('Mondongo'),
        ),
      ),
    );
  }
}