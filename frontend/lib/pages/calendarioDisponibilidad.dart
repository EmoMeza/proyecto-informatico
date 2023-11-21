import 'dart:math';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../api_services.dart';



class Evento {
  String id;
  String nombre;
  String categoria;
  String descripcion;
  DateTime fechaInicio;
  DateTime fechaFinal;
  int horaInicio; // Nueva variable para la hora de inicio
  int horaFinal;  // Nueva variable para la hora de término
  bool visible;
  bool global;

  Evento({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.descripcion,
    required this.fechaInicio,
    required this.fechaFinal,
    required this.horaInicio,
    required this.horaFinal,
    required this.visible,
    required this.global,
  });

  factory Evento.fromJson(Map<String, dynamic> json) {
    return Evento(
      id: json['_id'],
      nombre: json['nombre'],
      categoria: json['categoria'],
      descripcion: json['descripcion'],
      fechaInicio: parseDate(json['fecha_inicio']),
      fechaFinal: parseDate(json['fecha_final']),
      horaInicio: parseTime(json['fecha_inicio']),
      horaFinal: parseTime(json['fecha_final']),
      visible: json['visible'],
      global: json['global'],
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

  static int parseTime(String dateString) {
    List<String> parts = dateString.split('T');
    if (parts.length != 2) {
      throw FormatException("Invalid date and time format: $dateString");
    }

    List<String> timeParts = parts[1].split(':');
    if (timeParts.length != 3) {
      throw FormatException("Invalid time format: $dateString");
    }

    int hour = int.parse(timeParts[0]);

    return hour; // Convertir la hora y los minutos a minutos totales
  }

  String toString() {
    return 'Evento{nombre: $nombre, categoria: $categoria, descripcion: $descripcion, fechaInicio: $fechaInicio, fechaFinal: $fechaFinal, horaInicio: $horaInicio, horaFinal: $horaFinal, visible: $visible}';
  }
}

class CalendarioDispoibilidad extends StatefulWidget {
  @override
  _CalendarioDisponibilidadState createState() => _CalendarioDisponibilidadState();
}


class _CalendarioDisponibilidadState extends State<CalendarioDispoibilidad> with SingleTickerProviderStateMixin{
  String id_caa = "6552d3d4ec6e222a40b76125";
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
      duration: const Duration(
          milliseconds:
              300), // Duración de la animación (0.5 segundos en este caso)
    );
    _animation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
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

    ApiResponse responseVisibleFalse =
        await ApiService.getEventosFiltrados(filterDataVisibleFalse);
    ApiResponse responseVisibleTrue =
        await ApiService.getEventosFiltrados(filterDataVisibleTrue);

    List<Evento> eventosVisibleFalse = [];
    List<Evento> eventosVisibleTrue = [];

    if (responseVisibleFalse.success && responseVisibleFalse.data is List) {
      eventosVisibleFalse = (responseVisibleFalse.data as List<dynamic>)
          .map((e) => Evento.fromJson(e))
          .toList();
    }

    if (responseVisibleTrue.success && responseVisibleTrue.data is List) {
      eventosVisibleTrue = (responseVisibleTrue.data as List<dynamic>)
          .map((e) => Evento.fromJson(e))
          .toList();
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
        title: Text('Calendario de eventos',
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: IconThemeData(
          color: Theme.of(context)
              .colorScheme
              .onPrimary, // Cambia el color según tu necesidad
        ),
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
                  Text('Cargando disponibilidad...'), // Texto de carga
                ],
              ),
            ),
          if (!isLoading)
            TableCalendar(
              headerStyle: const HeaderStyle(
                  titleCentered: true, formatButtonVisible: false),
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
                  return (evento.fechaInicio.isBefore(day) ||
                          evento.fechaInicio.isAtSameMomentAs(day)) &&
                      (evento.fechaFinal.isAfter(day) ||
                          evento.fechaFinal.isAtSameMomentAs(day));
                }).toList();
                return events;
              },
              calendarStyle: CalendarStyle(
                  weekendTextStyle:
                      const TextStyle().copyWith(color: Colors.red),
                  markersMaxCount: 1,
                  markersAlignment: Alignment.bottomRight,
                  cellMargin: const EdgeInsets.all(17.0)),
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
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.3),
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
                        alignment: Alignment
                            .center, // Puedes ajustar la alineación según tus necesidades
                        children: [
                          // Círculo seleccionado
                          Positioned(
                            left: 0,
                            right: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              width: 37.0,
                              height: 37.0,
                              child: Center(
                                child: Text(
                                  '${day.day}',
                                  style: const TextStyle()
                                      .copyWith(fontSize: 16.0),
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
                      alignment: AlignmentGeometry.lerp(
                          Alignment.bottomRight, Alignment.topLeft, 0.8)!,
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
              child: _selectedDay != null
                  ? _buildEventList(_getEventosDelDia(_selectedDay!),_selectedDay!)
                  : Container(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventList(List<Evento> eventosDelDia,DateTime fechaSeleccionada) {
  // Crear una lista de eventos ordenada por la hora de inicio
  eventosDelDia.sort((a, b) => a.fechaInicio.compareTo(b.fechaInicio));
  debugPrint(eventosDelDia.toString());
  // Crear una lista de horas del día
  List<int> horasDelDia = List.generate(24, (index) => index);

  // Lista de TableRow
  List<TableRow> filas = [];

  // Encabezado de la tabla
  filas.add(
    TableRow(
      children: [
        TableCell(
          child: Container(
            color: Colors.grey[300],
            padding: const EdgeInsets.all(8.0),
            child: const Center(
              heightFactor: 2,
              child: Text(
                'Hora',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        TableCell(
          child: Container(
            color: Colors.grey[300],
            padding: const EdgeInsets.all(8.0),
            child: const Center(
              heightFactor: 2,
              child: Text(
                'Disponibilidad',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  // Filas de datos
  fechaSeleccionada = fechaSeleccionada.toLocal();
  for (int hora in horasDelDia) {
    //imprimir el tipo de dato de hora
    List<Evento> eventosEnHora = [];
    for (Evento evento in eventosDelDia) {
      if(fechaSeleccionada.isAfter(evento.fechaInicio) && fechaSeleccionada.isBefore(evento.fechaFinal)){
  
        eventosEnHora.add(evento);
      }
      else if(evento.fechaInicio==evento.fechaFinal){ 
        if (evento.horaInicio <= hora && evento.horaFinal > hora) {
          eventosEnHora.add(evento);
        }
      }
      else if(fechaSeleccionada.isBefore(evento.fechaFinal) && fechaSeleccionada == evento.fechaInicio){
        if (evento.horaInicio <= hora) {
          eventosEnHora.add(evento);
        }
      }
      else if(fechaSeleccionada == evento.fechaFinal && fechaSeleccionada.isAfter(evento.fechaInicio)){
        if (evento.horaFinal > hora) {
          eventosEnHora.add(evento);
        }
      }
      
    }

    // Calcular el color en función del número de eventos
    Color colorCelda = _calcularColor(eventosEnHora.length);

    // Agregar fila a la lista
    filas.add(
      TableRow(
        children: [
          TableCell(
            child: Container(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text('$hora:00'),
                ],
              ),
            ),
          ),
          TableCell(
            child: Container(
              height: 32,
              color: colorCelda,
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    '${eventosEnHora.length} evento(s)',
                    style: const TextStyle(fontSize: 12.0),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  return FadeTransition(
    opacity: _animation,
    child: SlideTransition(
      position: Tween<Offset>(begin: const Offset(0.0, 1.0), end: Offset.zero)
          .animate(_animation),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Table(
          columnWidths: {
            0: FixedColumnWidth(100),
            1: FixedColumnWidth(200),
          },
          children: filas,
        ),
      ),
    ),
  );
}
// Función para calcular el color en función del número de eventos
  Color _calcularColor(int numeroEventos) {
    List colors = [Colors.red, Colors.green, Colors.yellow];
    Random random = new Random();

    int index = 0;
    index = random.nextInt(3);
    return colors[index];
  }
  
}
