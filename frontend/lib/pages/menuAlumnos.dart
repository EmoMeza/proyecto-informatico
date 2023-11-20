import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:proyecto_informatico/pages/agregarEventoPrivado.dart';
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
  String id_caa = "6552d3d4ec6e222a40b76125";
  int matricula = 4321;
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool isLoading = true;
  late List<Evento> eventos = []; // Lista para guardar eventos privados

  Future<void> _loadEventos() async {
    Map<String, dynamic> filterDataPersonalEvent = {
      "id_creador": matricula.toString(),
    };

    ApiResponse responsePersonalEvents =
        await ApiService.getEventosFiltrados(filterDataPersonalEvent);

    List<Evento> eventosPersonal = [];

    if (responsePersonalEvents.success && responsePersonalEvents.data is List) {
      eventosPersonal = (responsePersonalEvents.data as List<dynamic>)
          .map((e) => Evento.fromJson(e))
          .toList();
    }

    setState(() {
      if (eventosPersonal.isNotEmpty) {
        eventos = eventosPersonal;
        debugPrint(eventosPersonal.toString());
      } else {
        eventos = [];
      }
      isLoading = false;
    });
  }

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

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CAA "nombre"',
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: IconThemeData(
          color: Theme.of(context)
              .colorScheme
              .onPrimary, // Cambia el color según tu necesidad
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
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
            if (!isLoading)
              // Display the private events
              if (eventos.isNotEmpty)
                Column(
                  children: eventos.map((event) {
                    return ListTile(
                      title: Text(event.nombre),
                      subtitle: Text(event.descripcion),
                      // Add more details as needed
                    );
                  }).toList(),
                ),
          ],
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
              child: const Text(
                'Menú Alumno',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
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
                        builder: (context) => AgregarEventoPrivado()));
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
                        builder: (context) => CalendarioAlumos()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text('Ver flujo de caja'),
              onTap: () {
                Navigator.pop(context);
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
            // Agrega más opciones de menú según sea necesario
          ],
        ),
      ),
    );
  }
}
