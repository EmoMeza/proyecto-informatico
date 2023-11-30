import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../api_services.dart';
import 'lista_asistencia.dart';
import 'dart:convert';
import 'dart:typed_data';

class EventoPopupCA extends StatefulWidget {
  final Map<String, dynamic> eventData;
  final String id_caa;

  EventoPopupCA({required this.eventData, required this.id_caa});

  @override
  _EventoPopupCAState createState() => _EventoPopupCAState();
}

class _EventoPopupCAState extends State<EventoPopupCA> {
  late String id_caa;
  late Map<String, dynamic> eventData;
  late List<String> asistencias;
  late bool isAsistenciaButtonEnabled;
  late String nombreCA;
  Uint8List? base64Image;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    id_caa = widget.id_caa;
    eventData = widget.eventData;
    if (widget.eventData.containsKey('imagen')) {
      // Decode base64 image
      base64Image = base64Decode(widget.eventData['imagen']);
    }
    asistencias = [];
    isAsistenciaButtonEnabled = false;
    nombreCA = '';
    _setpermisos();
    _loadnombreCA();
  }

  void _setpermisos() {
    if (id_caa == eventData['id_creador']) {
      setState(() {
        isAsistenciaButtonEnabled = true;
      });
    }
  }

  Future<void> _loadnombreCA() async {
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
              if (base64Image?.isNotEmpty == true) ...[
                const SizedBox(height: 10.0),
                _buildImage(base64Image!),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cerrar")),
          if (isAsistenciaButtonEnabled)
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ListaAsistenciaPage(eventData['_id']),
                  ),
                );
              },
              child: const Text('Lista Asistencia'),
            )
        ],
      );
    }
  }

  Widget _buildImage(Uint8List base64Image) {
    return Image.memory(
      base64Image,
      width: 400,
      height: 400,
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
}
