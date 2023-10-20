import 'dart:math';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';


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
}


class Calendario extends StatefulWidget {
  @override
  _CalendarioState createState() => _CalendarioState();
}


class _CalendarioState extends State<Calendario> {
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Random random = Random();

  List<Evento> eventos = [
    Evento(
      nombre: 'Completada bailable',
      categoria: 'Actividad',
      descripcion: 'Venta de completos CAINF',
      fechaInicio: DateTime(2023, 10, 20),
      fechaFinal: DateTime(2023, 10, 22),
      visible: false,
    ),
    Evento(
      nombre: 'Tarreo Infomatica',
      categoria: 'Actividad',
      descripcion: 'Actividad de recreacion para los alumnos de informatica',
      fechaInicio: DateTime(2023, 10, 10),
      fechaFinal: DateTime(2023, 10, 11),
      visible: true,
    ),
    Evento(
      nombre: 'Carrete mechon',
      categoria: 'Actividad',
      descripcion: 'Actividad de recreacion para nuevos alumnos de informatica',
      fechaInicio: DateTime(2023, 10, 20),
      fechaFinal: DateTime(2023, 10, 21),
      visible: true,
    ),
    
    // Agrega más eventos según sea necesario
  ];

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
                    alignment: AlignmentGeometry.lerp(Alignment.bottomRight, Alignment.topLeft, 0.8)!
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
    return ListView.builder(
      itemCount: eventosDelDia.length,
      itemBuilder: (context, index) {
        Evento evento = eventosDelDia[index];
        return ListTile(
          title: Text(evento.nombre),
          subtitle: Text(evento.descripcion),
          // Puedes mostrar más detalles del evento si es necesario
        );
      },
    );
  }
}
