import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';



class Calendario extends StatefulWidget {
  @override
  _CalendarioState createState() => _CalendarioState();
}

class _CalendarioState extends State<Calendario> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  final DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

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
        
      ),
    );
  }
}