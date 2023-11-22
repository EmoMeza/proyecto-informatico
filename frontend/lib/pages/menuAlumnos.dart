// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:proyecto_informatico/pages/agregarEventoPrivado.dart';
import 'menuCAA.dart';
import 'calendarioAlumos.dart';
import '../api_services.dart';
import 'detallesEventoAlumno.dart';
import 'dart:math';

class Evento {
  String id;
  String nombre;
  String categoria;
  String descripcion;
  DateTime fechaInicio;
  DateTime fechaFinal;
  bool visible;
  bool global;

  Evento(
      {required this.id,
      required this.nombre,
      required this.categoria,
      required this.descripcion,
      required this.fechaInicio,
      required this.fechaFinal,
      required this.visible,
      required this.global});
  factory Evento.fromJson(Map<String, dynamic> json) {
    return Evento(
        id: json['_id'],
        nombre: json['nombre'],
        categoria: json['categoria'],
        descripcion: json['descripcion'],
        fechaInicio: parseDate(json['fecha_inicio']),
        fechaFinal: parseDate(json['fecha_final']),
        visible: json['visible'],
        global: json['global']);
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

class menuAlumnos extends StatefulWidget {
  final Map<String, dynamic> alumnoData;

  menuAlumnos({Key? key, required this.alumnoData}) : super(key: key);

  @override
  _menuAlumnosState createState() => _menuAlumnosState();
}

class _menuAlumnosState extends State<menuAlumnos>
    with TickerProviderStateMixin {
  late Map<String, dynamic> alumnoData;
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool isLoading = true;
  late List<Evento> eventos = []; // Lista para guardar eventos privados

  @override
  void initState() {
    super.initState();
    alumnoData = widget.alumnoData;
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
    Map<String, dynamic> filterDataPersonalEvent = {
      "id_creador": alumnoData['matricula'].toString(),
      "visible": "false"
    };
    // Obtener eventos asistidos por el alumno
    Map<String, dynamic> filterAssistedEvents = {
      "matricula": alumnoData['matricula'].toString(),
    };

    // Obtener eventos privados

    ApiResponse responsePersonalEvents =
        await ApiService.getEventosFiltrados(filterDataPersonalEvent);
    // Obtener eventos asistidos
    List<Evento> eventosPersonal = [];

    if (responsePersonalEvents.success && responsePersonalEvents.data is List) {
      eventosPersonal = (responsePersonalEvents.data as List<dynamic>)
          .map((e) => Evento.fromJson(e))
          .toList();
    }

    setState(() {
      if (eventosPersonal.isNotEmpty) {
        eventos = eventosPersonal;
        print(eventosPersonal.toString());
        debugPrint(eventosPersonal.toString());
      } else {
        eventos = [];
      }
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showEventoDetails(Evento evento) async {
    ApiResponse response = await ApiService.getEvento(evento.id);

    if (response.success && response.data != null) {
      Map<String, dynamic> eventData = response.data;
      EventoPopup eventoPopup =
          EventoPopup(eventData: eventData, matricula: alumnoData['matricula']);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return eventoPopup;
        },
      );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alumno: ${alumnoData['nombre']} ${alumnoData['apellido']}',
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: IconThemeData(
          color: Theme.of(context)
              .colorScheme
              .onPrimary, // Cambia el color según tu necesidad
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      SizedBox(height: 200),
                      CircularProgressIndicator(),
                      SizedBox(height: 8.0),
                      Text('Cargando eventos...'),
                    ],
                  ),
                ),
              if (!isLoading && eventos.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No hay eventos personales.'),
                ),
              if (!isLoading && eventos.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const ScrollPhysics(),
                  itemCount: eventos.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                        title: Text(eventos[index].nombre),
                        subtitle: Text(eventos[index].descripcion),
                        // Add more details as needed
                        onTap: () => _showEventoDetails(eventos[index]));
                  },
                ),
            ],
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage:
                        NetworkImage('https://via.placeholder.com/200'),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Text(
                      '${alumnoData['nombre']} ${alumnoData['apellido']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Agregar Evento'),
              onTap: () {
                // Navegar a la página 1
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AgregarEventoPrivado(
                            alumnoData: widget.alumnoData)));
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month_outlined),
              title: const Text('Ver calendario'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CalendarioAlumos(
                            matricula: alumnoData['matricula'],
                            id_caa: alumnoData['id_caa'])));
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text('Ver flujo de caja'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            // Cursed code
            if (alumnoData['es_caa'] == 'true') const Divider(),
            if (alumnoData['es_caa'] == 'true')
              ListTile(
                leading: const Icon(Icons.now_widgets_outlined),
                title: const Text('Menú CAA'),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              menuCAA(id_caa: alumnoData['id_caa'])));
                },
              ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar sesión'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
