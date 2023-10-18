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
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Random random =  Random();
  //para testear
  List<Evento> eventos = [
    Evento(
      nombre: 'Final de Proyecto',
      categoria: 'Academico',
      descripcion: 'Examen final del curso de matemáticas.',
      fechaInicio: DateTime(2023, 10, 20),
      fechaFinal: DateTime(2023, 10, 22),
      visible: true,
    ),
    Evento(
      nombre: 'Final de Proyecto',
      categoria: 'Academico',
      descripcion: 'Examen final del curso de matemáticas.',
      fechaInicio: DateTime(2023, 10, 10),
      fechaFinal: DateTime(2023, 10, 11),
      visible: true,
    ),
  // Agrega más eventos según sea necesario
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Caledario de eventos'),
      ),
      body: TableCalendar(
        headerStyle: const HeaderStyle(titleCentered: true,formatButtonVisible: false),
        locale: 'es_ES',
        firstDay: DateTime.utc(2023, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay; // update `_focusedDay` here as well
          });
        },
        eventLoader: (day) {
          // Filtra los eventos que caen en el rango de fecha de inicio y fecha de fin, incluyendo el día de inicio y fin
          var events = eventos.where((evento) {
            return (evento.fechaInicio.isBefore(day) || evento.fechaInicio.isAtSameMomentAs(day)) &&
                (evento.fechaFinal.isAfter(day) || evento.fechaFinal.isAtSameMomentAs(day));
          }).toList();

          return events;
        },
       
      ),
    );
  }
}