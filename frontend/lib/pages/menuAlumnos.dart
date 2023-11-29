// ignore_for_file: camel_case_types, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:proyecto_informatico/pages/agregarEventoPrivado.dart';
import 'menuCAA.dart';
import 'calendarioAlumos.dart';
import '../api_services.dart';
import 'detallesEventoAlumno.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

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

  //controladores para los filtros
  TextEditingController searchController = TextEditingController();
  TextEditingController dateStartController = TextEditingController();
  TextEditingController dateEndController = TextEditingController();

  DateTime? filtroFechaInicio; // Filtro de fecha inicial
  DateTime? filtroFechaFinal; //  filtro de fecha final
  List<Evento> filteredEventos = []; // Lista para guardar eventos filtrados
  List<Evento> filteredEventosDateFiltered =
      []; // Lista para guardar eventos filtrados por fecha
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
    searchController.addListener(() {
      _setFilterState();
    });
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

  void _filterSearch() {
    if (searchController.text.isNotEmpty) {
      filteredEventos = eventos
          .where((evento) => evento.nombre
              .toLowerCase()
              .contains(searchController.text.toLowerCase()))
          .toList();
    } else {
      // If the search is empty, use the date-filtered list
      filteredEventos = List.from(filteredEventosDateFiltered ?? eventos);
    }
    setState(() {});
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  //Filter by date
  void _filterDate() {
    // Perform date and time filtering and store it in a separate list
    List<Evento> dateFilteredEvents = List.from(eventos);

    if (filtroFechaInicio != null) {
      dateFilteredEvents = dateFilteredEvents
          .where((evento) =>
              evento.fechaInicio.isAfter(filtroFechaInicio!) ||
              (isSameDay(evento.fechaInicio, filtroFechaInicio!) &&
                  evento.fechaInicio.isAfter(filtroFechaInicio!)))
          .toList();
    }

    if (filtroFechaFinal != null) {
      filtroFechaFinal = filtroFechaFinal!.add(const Duration(days: 1));
      dateFilteredEvents = dateFilteredEvents
          .where((evento) =>
              evento.fechaInicio.isBefore(filtroFechaFinal!) ||
              (isSameDay(evento.fechaInicio, filtroFechaFinal!) &&
                  evento.fechaFinal.isAfter(filtroFechaFinal!)))
          .toList();
      filtroFechaFinal = filtroFechaFinal!.subtract(const Duration(days: 1));
    }

    // Update the date-filtered list
    filteredEventosDateFiltered = dateFilteredEvents;

    // Call _filterSearch to update the search filter as well
    _filterSearch();

    setState(() {});
  }

  void _setFilterState() {
    _filterDate();
    _filterSearch();
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
      filteredEventos = List.from(eventos);
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

  void _openDateErrorDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: const Text(
              'La fecha inicial debe ser menor o igual a la fecha final.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Eventos',
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
                    child: Text('No hay eventos personales ni asistidos.'),
                  ),
                if (!isLoading && eventos.isNotEmpty)
                  Column(children: [
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 12.0, top: 8.0, bottom: 8, right: 8),
                            child: TextField(
                              controller: searchController,
                              decoration: InputDecoration(
                                labelText: 'Buscar',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50.0),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 20.0,
                                ),
                                suffixIcon: InkWell(
                                  onTap: () {
                                    // Clear the search text and reset filters
                                    searchController.clear();
                                    _setFilterState();
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.all(10.0),
                                    child: Icon(Icons.clear),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (BuildContext context) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      tileColor:
                                          Theme.of(context).colorScheme.primary,
                                      title: const Text(
                                        'Filtrar por Fecha',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.0,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    ListTile(
                                      title: TextField(
                                        decoration: const InputDecoration(
                                          labelText: 'Fecha inicial',
                                        ),
                                        controller: dateStartController,
                                        readOnly: true,
                                        onTap: () async {
                                          DateTime? pickedDateStart =
                                              await showDatePicker(
                                            context: context,
                                            initialDate: filtroFechaInicio ??
                                                DateTime.now(),
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime(2101),
                                          );
                                          if (pickedDateStart != null &&
                                              pickedDateStart !=
                                                  filtroFechaInicio) {
                                            setState(() {
                                              filtroFechaInicio =
                                                  pickedDateStart;
                                              dateStartController.text =
                                                  DateFormat('dd-MM-yyyy')
                                                      .format(
                                                          filtroFechaInicio!);
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                    ListTile(
                                      title: TextField(
                                        decoration: const InputDecoration(
                                          labelText: 'Fecha final',
                                        ),
                                        controller: dateEndController,
                                        readOnly: true,
                                        onTap: () async {
                                          DateTime? pickedDateEnd =
                                              await showDatePicker(
                                            context: context,
                                            initialDate: filtroFechaFinal ??
                                                DateTime.now(),
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime(2101),
                                          );
                                          if (pickedDateEnd != null &&
                                              pickedDateEnd !=
                                                  filtroFechaFinal) {
                                            setState(() {
                                              filtroFechaFinal = pickedDateEnd;
                                              dateEndController.text =
                                                  DateFormat('dd-MM-yyyy')
                                                      .format(
                                                          filtroFechaFinal!);
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 10.0),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                filtroFechaInicio = null;
                                                filtroFechaFinal = null;
                                                dateStartController.text = "";
                                                dateEndController.text = "";
                                                _setFilterState();
                                              });
                                            },
                                            child:
                                                const Text("Limpiar filtros")),
                                        ElevatedButton(
                                          onPressed: () {
                                            // comparamos los controladores para ver si la fecha inicial es menor a la final
                                            if (filtroFechaInicio != null &&
                                                filtroFechaFinal != null) {
                                              if (filtroFechaInicio!.isBefore(
                                                      filtroFechaFinal!) ||
                                                  filtroFechaInicio!
                                                      .isAtSameMomentAs(
                                                          filtroFechaFinal!)) {
                                                _setFilterState();
                                                Navigator.pop(context);
                                              } else {
                                                _openDateErrorDialog();
                                              }
                                            } else {
                                              _setFilterState();
                                              Navigator.pop(context);
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                          child: const Text(
                                            'Aplicar Filtros',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                          ),
                          child: const Padding(
                            padding: EdgeInsets.only(
                                left: 7, right: 7, top: 12, bottom: 12),
                            child:
                                Icon(Icons.calendar_today, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // const Text(
                    //   'Eventos creados y asistidos por ti:',
                    //   style: TextStyle(
                    //     fontSize: 18.0, // Set the font size as needed
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const ScrollPhysics(),
                      itemCount: filteredEventos.length,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 2.0, // Set the elevation as needed
                          margin: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: ListTile(
                            title: Text(filteredEventos[index].nombre),
                            subtitle: Text(filteredEventos[index].descripcion),
                            // Add more details as needed
                            onTap: () =>
                                _showEventoDetails(filteredEventos[index]),
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
                  CircleAvatar(
                    backgroundImage: widget.alumnoData.containsKey('imagen')
                        ? MemoryImage(base64Decode(widget.alumnoData['imagen']))
                        : Image.asset('assets/images/user_placeholder.png')
                            .image,
                    radius: 30,
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
