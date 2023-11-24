// ignore_for_file: camel_case_types, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:proyecto_informatico/pages/agregarEventoPrivado.dart';
import 'menuCAA.dart';
import 'calendarioAlumos.dart';
import '../api_services.dart';
import 'detallesEventoAlumno.dart';

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

  const menuAlumnos({Key? key, required this.alumnoData}) : super(key: key);

  @override
  _menuAlumnosState createState() => _menuAlumnosState();
}

class _menuAlumnosState extends State<menuAlumnos>
    with TickerProviderStateMixin {
  final GlobalKey<_menuAlumnosState> _key = GlobalKey<_menuAlumnosState>();
  late Map<String, dynamic> alumnoData;
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool isLoading = true;
  late List<Evento> eventos = []; // Lista para guardar eventos privados

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

  static Future<List<Evento>> getEventosByIds(List<dynamic> eventIds) async {
    List<Evento> eventos = [];

    for (String eventId in eventIds) {
      ApiResponse response = await ApiService.getEvento(eventId);

      if (response.success && response.data != null) {
        Map<String, dynamic> eventData = response.data;
        Evento evento = Evento.fromJson(eventData);
        eventos.add(evento);
      }
    }

    return eventos;
  }

  Future<void> _loadEventos() async {
    alumnoData = widget.alumnoData;
    Map<String, dynamic> filterDataPersonalEvent = {
      "id_creador": alumnoData['matricula'].toString(),
      "visible": "false"
    };
    // Obtener eventos privados
    ApiResponse responsePersonalEvents =
        await ApiService.getEventosFiltrados(filterDataPersonalEvent);
    List<Evento> eventosPersonal = [];
    if (responsePersonalEvents.success && responsePersonalEvents.data is List) {
      eventosPersonal = (responsePersonalEvents.data as List<dynamic>)
          .map((e) => Evento.fromJson(e))
          .toList();
    }
    // Obtener eventos asistidos
    List<Evento> eventosAsistidos = [];
    eventosAsistidos = await getEventosByIds(alumnoData['mis_asistencias']);
    debugPrint(eventosAsistidos.toString());
    // Actualizar la lista de eventos
    setState(() {
      if (eventosPersonal.isNotEmpty || eventosAsistidos.isNotEmpty) {
        eventos = [...eventosPersonal, ...eventosAsistidos];
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
            content: const Text('Error al cargar detalles del evento'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
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
      body: RefreshIndicator(
        key: _key,
        onRefresh: () async {
          await _loadEventos();
        },
        child: SingleChildScrollView(
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
                  Column(children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Eventos creados y asistidos por ti:',
                      style: TextStyle(
                        fontSize: 18.0, // Set the font size as needed
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const ScrollPhysics(),
                      itemCount: eventos.length,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 2.0, // Set the elevation as needed
                          margin: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: ListTile(
                            title: Text(eventos[index].nombre),
                            subtitle: Text(eventos[index].descripcion),
                            // Add more details as needed
                            onTap: () => _showEventoDetails(eventos[index]),
                          ),
                        );
                      },
                    ),
                  ]),
              ],
            ),
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
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AgregarEventoPrivado(
                      alumnoData: widget.alumnoData,
                    ),
                  ),
                );

                if (result == true) {
                  // If the result is true, refresh the events
                  _loadEventos();
                }
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
