import 'dart:math';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../api_services.dart';
import 'package:intl/intl.dart';
import 'lista_asistencia.dart';


class Evento {
  String id;
  String nombre;
  String categoria;
  String descripcion;
  DateTime fechaInicio;
  DateTime fechaFinal;
  bool visible;
  bool global;

  Evento({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.descripcion,
    required this.fechaInicio,
    required this.fechaFinal,
    required this.visible,
    required this.global
  });
  factory Evento.fromJson(Map<String, dynamic> json) {
    return Evento(
      id: json['_id'],
      nombre: json['nombre'],
      categoria: json['categoria'],
      descripcion: json['descripcion'],
      fechaInicio: parseDate(json['fecha_inicio']),
      fechaFinal: parseDate(json['fecha_final']),
      visible: json['visible'],
      global: json['global']
    );
  }
  static DateTime parseDate(String dateString) {
    List<String> parts = dateString.split('T');
    if (parts.length != 2) {
      throw FormatException("Invalid date format: $dateString");
    }

    List<String> dateParts = parts[0].split('-');
    if (dateParts.length != 3) {
      throw FormatException("Invalid date format: $dateString");
    }

    int year = int.parse(dateParts[0]);
    int month = int.parse(dateParts[1]);
    int day = int.parse(dateParts[2]);

    return DateTime(year, month, day);
  }
  String toString() {
    return 'Evento{nombre: $nombre, categoria: $categoria, descripcion: $descripcion, fechaInicio: $fechaInicio, fechaFinal: $fechaFinal, visible: $visible}';
  }

}


class Calendario extends StatefulWidget {
  @override
  _CalendarioState createState() => _CalendarioState();
}


class _CalendarioState extends State<Calendario> with SingleTickerProviderStateMixin{
  String id_caa = "652976834af6fedf26f3493d";
  late AnimationController _animationController;
  late Animation<double> _animation;
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Random random = Random();
  late List<Evento> eventos = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300), // Duración de la animación (0.5 segundos en este caso)
    );
    _animation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _loadEventos();
  }

  

  Future<void> _loadEventos() async {
    Map<String, dynamic> filterDataVisibleFalse = {
      "id_creador": id_caa,
      "global": false.toString(),
    };

    Map<String, dynamic> filterDataVisibleTrue = {
      "global": true.toString(),
    };

    ApiResponse responseVisibleFalse = await ApiService.getEventosFiltrados(filterDataVisibleFalse);
    ApiResponse responseVisibleTrue = await ApiService.getEventosFiltrados(filterDataVisibleTrue);

    List<Evento> eventosVisibleFalse = [];
    List<Evento> eventosVisibleTrue = [];

    if (responseVisibleFalse.success && responseVisibleFalse.data is List) {
      eventosVisibleFalse = (responseVisibleFalse.data as List<dynamic>).map((e) => Evento.fromJson(e)).toList();
    }

    if (responseVisibleTrue.success && responseVisibleTrue.data is List) {
      eventosVisibleTrue = (responseVisibleTrue.data as List<dynamic>).map((e) => Evento.fromJson(e)).toList();
    }

    setState(() {
      if (eventosVisibleFalse.isNotEmpty || eventosVisibleTrue.isNotEmpty) {
        eventos = [...eventosVisibleFalse, ...eventosVisibleTrue];
        debugPrint(eventos.toString());
      } else {
        eventos = []; // Calendario vacío
      }
      isLoading = false;
    });
  }
  

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }


  List<Evento> _getEventosDelDia(DateTime day) {
    // Filtra los eventos que caen en el rango de fechas de inicio y fin, incluyendo ambos extremos
    return eventos.where((evento) {
      return day.isAtSameMomentAs(evento.fechaInicio) ||
          day.isAtSameMomentAs(evento.fechaFinal) ||
          (day.isAfter(evento.fechaInicio) && day.isBefore(evento.fechaFinal));
    }).toList();
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario de eventos'),
      ),
      body: Column(
        children: [
          if (isLoading) // Muestra la barra de carga y el texto de carga mientras isLoading es true
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SizedBox(height: 200),
                  CircularProgressIndicator(), // Barra de carga circular
                  SizedBox(height: 8.0),
                  Text('Cargando eventos...'), // Texto de carga
                ],
              ),
            ),
          if(!isLoading)
            TableCalendar(
            headerStyle: const HeaderStyle(titleCentered: true, formatButtonVisible: false),
            locale: 'es_ES',
            firstDay: DateTime.utc(2023, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            startingDayOfWeek: StartingDayOfWeek.monday,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _animationController.reset();
              _animationController.forward();
            },
            eventLoader: (day) {
              var events = eventos.where((evento) {
                return (evento.fechaInicio.isBefore(day) || evento.fechaInicio.isAtSameMomentAs(day)) &&
                    (evento.fechaFinal.isAfter(day) || evento.fechaFinal.isAtSameMomentAs(day));
              }).toList();
              return events;
            },
            calendarStyle: CalendarStyle(
              weekendTextStyle: const TextStyle().copyWith(color: Colors.red),
              markersMaxCount: 1,
              markersAlignment: Alignment.bottomRight,
              cellMargin: const EdgeInsets.all(17.0)
            ),
            calendarBuilders: CalendarBuilders(
            todayBuilder: (context, day, focusedDay) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Círculo seleccionado
                  Positioned(
                    left: 0,
                    right: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      width: 37.0,
                      height: 37.0,
                      child: Center(
                        child: Text(
                          '${day.day}',
                          style: const TextStyle(fontSize: 16.0),
                        ),
                      ),
                    ),
                  ),
                  // Otros elementos que quieras agregar encima del círculo
                ],
              );
            },
              selectedBuilder: (context, day, focusedDay) {
                return FadeTransition(
                  opacity: _animation,
                  child: ScaleTransition(
                    scale: _animation,
                    child: Stack(
                      alignment: Alignment.center, // Puedes ajustar la alineación según tus necesidades
                      children: [
                        // Círculo seleccionado
                        Positioned(
                          left: 0,
                          right: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            width: 37.0,
                            height: 37.0,
                            child: Center(
                              child: Text(
                                '${day.day}',
                                style: const TextStyle().copyWith(fontSize: 16.0),
                              ),
                            ),
                          ),
                        ),
                        // Otros elementos que quieras agregar encima del círculo
                      ],
                    ),
                  ),
                );
              },
              singleMarkerBuilder: (context, day, events) {
                var eventosDelDia = _getEventosDelDia(day);
                if (eventosDelDia.isNotEmpty) {
                  return Stack(
                    alignment: AlignmentGeometry.lerp(Alignment.bottomRight, Alignment.topLeft, 0.8)!,
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.deepPurple,
                          shape: BoxShape.circle,
                        ),
                        width: 20.0,
                        height: 20.0,
                      ),
                      Positioned(
                        top: 3,
                        left: 6,
                        child: Text(
                          '${eventosDelDia.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return Container();
                }
              },
            ),
          ),
          
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: _selectedDay != null ? _buildEventList(_getEventosDelDia(_selectedDay!)) : Container(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventList(List<Evento> eventosDelDia) {
    return FadeTransition(
      opacity: _animation,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0.0, 1.0), end: Offset.zero).animate(_animation),
        child: ListView.builder(
          itemCount: eventosDelDia.length,
          itemBuilder: (context, index) {
            Evento evento = eventosDelDia[index];
            return ListTile(
              title: Text(evento.nombre),
              subtitle: Text(evento.descripcion),
              onTap: () => _showEventoDetails(evento),
            );
          },
        ),
      ),
    );
  }


  void _showEventoDetails(Evento evento) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 8.0),
              Text('Cargando detalles del evento...'),
            ],
          ),
        );
      },
    );

    ApiResponse response = await ApiService.getEvento(evento.id);

    Navigator.pop(context);

    if (response.success && response.data != null) {
      Map<String, dynamic> eventData = response.data;
      _showEventoPopup(eventData);
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text('Error al cargar detalles del evento'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cerrar'),
              ),
            ],
          );
        },
      );
    }
  }

  void _showEventoPopup(Map<String, dynamic> eventData) async {
    // Formatear las fechas
    DateTime fechaInicio = DateTime.parse(eventData['fecha_inicio']);
    DateTime fechaFinal = DateTime.parse(eventData['fecha_final']);

    // Define a DateFormat instance for the desired format
    final dateFormat = DateFormat('dd-MM-yyyy  HH:mm', 'es_ES');

    String formattedFechaInicio = dateFormat.format(fechaInicio);
    String formattedFechaFinal = dateFormat.format(fechaFinal);

    // Obtener la información del creador
    ApiResponse response = await ApiService.getCaa(eventData['id_creador']);
    String creador = response.success ? response.data['nombre'] : 'ID no encontrado';

    // Crear y mostrar el AlertDialog
    AlertDialog alertDialog = AlertDialog(
      title: Text(eventData['nombre'], style: const TextStyle(fontSize: 22)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 30),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10.0),
          _buildLabelText('Categoría:'),
          if (eventData['categoria'] == 'actividad')
            _buildText('Actividad')
          else
            _buildText(eventData['Evaluación']),
          const SizedBox(height: 10.0),
          _buildLabelText('Descripción:'),
          _buildText(eventData['descripcion']),
          const SizedBox(height: 10.0),
          _buildLabelText('Fecha de inicio:'),
          _buildText(formattedFechaInicio),
          const SizedBox(height: 10.0),
          _buildLabelText('Fecha de fin:'),
          _buildText(formattedFechaFinal),
          const SizedBox(height: 10.0),
          _buildLabelText('Tipo de evento:'),
          if (eventData['global'])
            _buildText('Publico')
          else
            _buildText('De carrera'),
          const SizedBox(height: 10.0),
          _buildLabelText('Anfitrión:'),
          _buildText(creador),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
        ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ListaAsistenciaPage(eventData['_id']),
            ),
          );
        },
  child: Text('Lista Asistencia'),
)
      ],
    );

    // Mostrar el AlertDialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alertDialog;
      },
    );
  }

  Widget _buildLabelText(String label) {
    return Text(
      label,
      style: const TextStyle(fontSize: 17, color: Colors.black, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
    );
  }

  Widget _buildText(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 17, color: Color.fromARGB(166, 0, 0, 0), decoration: TextDecoration.none),
    );
  }
}
