import 'dart:math';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../api_services.dart';



class Evento {
  String nombre;
  String categoria;
  String descripcion;
  DateTime fechaInicio;
  DateTime fechaFinal;
  bool visible;

  Evento({
    required this.nombre,
    required this.categoria,
    required this.descripcion,
    required this.fechaInicio,
    required this.fechaFinal,
    required this.visible,
  });
  factory Evento.fromJson(Map<String, dynamic> json) {
    return Evento(
      nombre: json['nombre'],
      categoria: json['categoria'],
      descripcion: json['descripcion'],
      fechaInicio: parseDate(json['fecha_inicio']),
      fechaFinal: parseDate(json['fecha_final']),
      visible: json['visible']??true,
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

}


class Calendario extends StatefulWidget {
  @override
  _CalendarioState createState() => _CalendarioState();
}


class _CalendarioState extends State<Calendario> with SingleTickerProviderStateMixin{
  late AnimationController _animationController;
  late Animation<double> _animation;
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Random random = Random();
  late List<Evento> eventos = [];

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
    ApiResponse response = await  ApiService.getAllEventos();
    if (response.success) {
      setState(() {
        eventos = (response.data as List<dynamic>).map((e) => Evento.fromJson(e)).toList();
      });
    } else {
      // Handle error here
      print('Error cargando eventos: ${response.message}');
    }
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
            ),
            calendarBuilders: CalendarBuilders(
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
                        top: 4,
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
              padding: const EdgeInsets.all(8.0),
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
              // se puede mostrar más detalles del evento si es necesario
            );
          },
        ),
      ),
    );
  }
}
