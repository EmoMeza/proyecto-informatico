import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:proyecto_informatico/api_services.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async{

            // Obtener el evento con id
            String id = '652de1acd03e38b13a1feb23';

            ApiResponse response = await ApiService.getEvento(id);

            if (response.success){
              Evento evento = Evento(
                id: response.data['_id'],
                nombre: response.data['nombre'],
                fecha: DateTime.parse('2023-11-16T10:00:00.000Z'),
              );

              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return NotificationDialog(evento: evento);
                },
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(response.message),
                ),
              );
            }
          },
          child: const Text('Mondongo'),
        ),
      ),
    );
  }
}


class NotificationDialog extends StatefulWidget {

  final Evento evento;

  const NotificationDialog({Key? key, required this.evento}) : super(key: key);

  @override
  State<NotificationDialog> createState() => _NotificationDialogState();
}

class _NotificationDialogState extends State<NotificationDialog> {

  late final NotificationManager notificationManager;
  final TextEditingController numberController = TextEditingController(text: '10');
  String? selectedFormat = 'minutos';
  final _formKey = GlobalKey<FormState>();  

  final List<DropdownMenuEntry<String>> dropdownMenuEntries = 
    <DropdownMenuEntry<String>>[
      for (final String format in ['minutos', 'horas', 'dias', 'semanas']) 
        DropdownMenuEntry<String>(value: format, label: format)
    ];

  bool isFormTouched = false;
  bool isFormValid = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    notificationManager = NotificationManager();
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Santiago'));
  }

  @override
  Widget build(BuildContext context) {
    Evento evento = widget.evento;
    return AlertDialog(
      title: const Text('Programar notificación'),
      content: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState){
          return Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: numberController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d{0,5}'))
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Duración',
                          counterText: '',
                          counterStyle: TextStyle( fontSize: 0 ),
                        ),
                        maxLength: 5,
                        onChanged: (String value) {
                          setState(() {
                            isFormTouched = true;
                            isFormValid = true;
                            errorMessage = null;
                          });
                        },
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            isFormValid = false;
                            errorMessage = 'Ingrese un valor.';
                            return null;
                          }
                          int? parsedValue = int.tryParse(value);
                          if (parsedValue == null || parsedValue <= 0 || !_isValidValue(parsedValue)) {
                            isFormValid = false;
                            errorMessage = _getErrorText(selectedFormat);
                            return '';
                          }

                          DateTime now = DateTime.now();
                          DateTime scheduledTime = now.add(_calculateDuration(parsedValue));

                          // Asegurar que la notificación programada ocurra antes de la fecha del evento
                          if (scheduledTime.isAfter(evento.fecha)) {
                            isFormValid = false;
                            errorMessage = 'La notificación debe ocurrir antes de la fecha del evento.';
                            return '';
                          }

                          isFormValid = true;
                          errorMessage = null;
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    DropdownMenu<String>(
                      dropdownMenuEntries: dropdownMenuEntries,
                      label: const Text('Formato'),
                      initialSelection: selectedFormat,
                      menuStyle: MenuStyle(
                        backgroundColor: MaterialStateProperty.all(
                          Theme.of(context).colorScheme.background
                        ),
                      ),
                      onSelected: (String? value) {
                        setState(() {
                          selectedFormat = value;
                          isFormTouched = true;
                        });
                      },
                    )
                  ]
                ),
                const SizedBox(height: 16),
                if (isFormTouched && !(_formKey.currentState?.validate() ?? false))
                  Text(
                    errorMessage!,
                    style: const TextStyle(
                      color: Colors.red
                    )
                  ),
              ],
            ),
          );
        },
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async{
            if (isFormTouched && (_formKey.currentState?.validate() ?? false)){
              final int selectedNumber = int.parse(numberController.text);
              final Duration scheduledHour = _calculateDuration(selectedNumber);

              await notificationManager.scheduleNotification(
                evento,
                scheduledHour,
              );

              Navigator.of(context).pop();
            }
          },
          child: const Text('Aceptar'),
        ),
      ],
    );
  }

  bool _isValidValue(int value) {
    switch (selectedFormat) {
      case 'minutos':
        return value <= 4 * 7 * 24 * 60;
      case 'horas':
        return value <= 4 * 7 * 24;
      case 'dias':
        return value <= 4 * 7;
      case 'semanas':
        return value <= 4;
      default:
        return false;
    }
  }

  String _getErrorText(String? selectedFormat) {
    switch (selectedFormat) {
      case 'minutos':
        return 'La duracion debe ser mayor a 0 y menor a ${4 * 7 * 24 * 60} minutos.';
      case 'horas':
        return 'La duracion debe ser mayor a 0 y menor a ${4 * 7 * 24} horas.';
      case 'dias':
        return 'La duracion debe ser mayor a 0 y menor a ${4 * 7} días.';
      case 'semanas':
        return 'La duracion debe ser mayor a 0 y menor a 4 semanas.';
      default:
        return 'Formato no válido.';
    }
  }

  Duration _calculateDuration(int selectedNumber) {
    if (selectedFormat != null) {
      switch (selectedFormat) {
        case 'minutos':
          return Duration(minutes: selectedNumber);
        case 'horas':
          return Duration(hours: selectedNumber);
        case 'dias':
          return Duration(days: selectedNumber);
        case 'semanas':
          return Duration(days: selectedNumber * 7);
        default:
          return Duration.zero;
      }
    } else {
      return Duration.zero;
    }
  }

}