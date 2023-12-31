import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../api_services.dart';
import 'package:proyecto_informatico/pages/notificaciones.dart';
import 'dart:convert';
import 'dart:typed_data';

class EventoPopup extends StatefulWidget {
  final Map<String, dynamic> eventData;
  final int matricula;

  EventoPopup({required this.eventData, required this.matricula});

  @override
  _EventoPopupState createState() => _EventoPopupState();
}

class _EventoPopupState extends State<EventoPopup> {
  late int matricula;
  late Map<String, dynamic> eventData;
  late List<String> asistencias;
  late bool isAsistireButtonEnabled;
  late String nombreCA;
  Uint8List? base64Image;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    matricula = widget.matricula;
    eventData = widget.eventData;
    asistencias = [];
    isAsistireButtonEnabled = true;
    nombreCA = '';
    if (widget.eventData.containsKey('imagen')) {
      // Decode base64 image
      base64Image = base64Decode(widget.eventData['imagen']);
    }
    // Ejecuta código asíncrono después de que initState ha completado
    Future.delayed(Duration.zero, () async {
      await _loadAsistencias();

      if (widget.eventData['id_creador'].toString().length < 10) {
        await _loadnombreAlumno();
      } else {
        await _loadnombreCA();
      }
    });
  }

  Future<void> _loadAsistencias() async {
    ApiResponse response =
        await ApiService.getAsistenciasEvento(widget.eventData['_id']);

    if (response.success && response.data is List) {
      List<dynamic> asistenciasData = response.data;
      setState(() {
        asistencias = asistenciasData.map((e) => e.toString()).toList();
        isAsistireButtonEnabled = !asistencias.contains(matricula.toString());
        if (eventData['visible'] == false) {
          isAsistireButtonEnabled = false;
        }
      });
    } else {
      // Manejar el error
      setState(() {
        asistencias = [];
        isAsistireButtonEnabled = false;
      });
    }
  }

  Future<void> _loadnombreCA() async {
    debugPrint(widget.eventData['id_creador'].toString().length.toString());
    ApiResponse response =
        await ApiService.getCaa(widget.eventData['id_creador']);
    if (response.success) {
      // Muestra una ventana emergente con un mensaje
      setState(() {
        nombreCA = response.data['nombre'];
      });
    } else {
      // Muestra una ventana emergente con un mensaje de error
      setState(() {
        nombreCA = 'ID no encontrado';
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _loadnombreAlumno() async {
    debugPrint(widget.eventData['id_creador'].toString().length.toString());
    ApiResponse response =
        await ApiService.getAlumno(widget.eventData['id_creador']);

    if (response.success) {
      // Muestra una ventana emergente con un mensaje
      setState(() {
        nombreCA = response.data['nombre'] + ' ' + response.data['apellido'];
      });
    } else {
      // Muestra una ventana emergente con un mensaje de error
      setState(() {
        nombreCA = 'ID no encontrado';
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Formatear las fechas
    DateTime fechaInicio = DateTime.parse(widget.eventData['fecha_inicio']);
    DateTime fechaFinal = DateTime.parse(widget.eventData['fecha_final']);

    // Define a DateFormat instance for the desired format
    final dateFormat = DateFormat('dd-MM-yyyy  HH:mm', 'es_ES');

    String formattedFechaInicio = dateFormat.format(fechaInicio);
    String formattedFechaFinal = dateFormat.format(fechaFinal);

    // Obtener la información del creador

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return AlertDialog(
        title: Text(widget.eventData['nombre'],
            style: const TextStyle(fontSize: 22)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 30),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10.0),
              _buildLabelText('Categoría:'),
              _buildText(widget.eventData['categoria']),
              const SizedBox(height: 10.0),
              _buildLabelText('Descripción:'),
              _buildText(widget.eventData['descripcion']),
              const SizedBox(height: 10.0),
              _buildLabelText('Fecha de inicio:'),
              _buildText(formattedFechaInicio),
              const SizedBox(height: 10.0),
              _buildLabelText('Fecha de fin:'),
              _buildText(formattedFechaFinal),
              const SizedBox(height: 10.0),
              if (widget.eventData['categoria'] == 'actividad' ||
                  widget.eventData['categoria'] == 'Actividad') ...[
                _buildLabelText('Evento de tipo:'),
                _buildText(widget.eventData['global'] == true
                    ? 'Global'
                    : 'De carrera')
              ],
              const SizedBox(height: 10.0),
              _buildLabelText('Creador:'),
              _buildText(nombreCA),
              if (base64Image?.isNotEmpty == true &&
                  widget.eventData['visible'] == true) ...[
                const SizedBox(height: 10.0),
                _buildImage(base64Image!),
              ],
            ],
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
              const SizedBox(width: 8), // Espaciado entre los botones
              isAsistireButtonEnabled
                  ? ElevatedButton(
                      onPressed: () {
                        _handleAsistireButtonPressed(widget.eventData['_id']);
                      },
                      child: const Text('Asistiré'),
                    )
                  : InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return NotificationDialog(
                              id: eventData['_id'],
                              nombre: eventData['nombre'],
                              fecha: fechaInicio,
                            );
                          },
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.notifications, color: Colors.white),
                            SizedBox(width: 8),
                            Text('Notificar',
                                style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
            ],
          ),
        ],
      );
    }
  }

  Widget _buildImage(Uint8List base64Image) {
    return Image.memory(
      base64Image,
      width: 400, // Adjust the width as needed
      height: 400, // Adjust the height as needed
      fit: BoxFit.cover,
    );
  }

  Widget _buildLabelText(String label) {
    return Text(
      label,
      style: const TextStyle(
          fontSize: 17,
          color: Colors.black,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.none),
    );
  }

  Widget _buildText(String text) {
    return Text(
      text,
      style: const TextStyle(
          fontSize: 17,
          color: Color.fromARGB(166, 0, 0, 0),
          decoration: TextDecoration.none),
    );
  }

  void _handleAsistireButtonPressed(String eventId) async {
    debugPrint('Asistiré al evento $eventId y mi matricula es $matricula');
    ApiResponse response =
        await ApiService.postAsistenciaEvento(eventId, matricula.toString());

    if (response.success) {
      // Muestra una ventana emergente con un mensaje
      setState(() {
        isAsistireButtonEnabled = false;
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text('Gracias por tu participación'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
            ],
          );
        },
      );
    } else {
      // Muestra una ventana emergente con un mensaje de error
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text('Error al registrar asistencia'),
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
}
