import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../api_services.dart';

class EventoPopup extends StatefulWidget {
  final Map<String, dynamic> eventData;
  final int matricula;

  EventoPopup({required this.eventData,required this.matricula});

  @override
  _EventoPopupState createState() => _EventoPopupState();
}

class _EventoPopupState extends State<EventoPopup> {
  late int matricula;
  late Map<String, dynamic> eventData;
  late List<String> asistencias;
  late bool isAsistireButtonEnabled;
  late String nombreCA;
  bool isLoading = true;


  @override
  void initState() {
    super.initState();
    matricula = widget.matricula;
    eventData = widget.eventData;
    asistencias = [];
    isAsistireButtonEnabled = true;
    nombreCA = '';
    _loadAsistencias();
    _loadnombreCA();

  }

  Future<void> _loadAsistencias() async {
    ApiResponse response = await ApiService.getAsistenciasEvento(widget.eventData['_id']);

    if (response.success && response.data is List) {
      List<dynamic> asistenciasData = response.data;
      setState(() {
        asistencias = asistenciasData.map((e) => e.toString()).toList();
        isAsistireButtonEnabled = !asistencias.contains(matricula.toString());
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
    ApiResponse response = await ApiService.getCaa(widget.eventData['id_creador']);
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
  Widget build(BuildContext context){
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
    }
    else{ 
      return AlertDialog(
        title: Text(widget.eventData['nombre'], style: const TextStyle(fontSize: 22)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 30),
        content: Column(
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
            _buildLabelText('Global:'),
            _buildText(widget.eventData['global'].toString()),
            const SizedBox(height: 10.0),
            _buildLabelText('Creador:'),
            _buildText(nombreCA),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
              SizedBox(width: 8), // Espaciado entre los botones
              isAsistireButtonEnabled
                  ? ElevatedButton(
                      onPressed: () => _handleAsistireButtonPressed(widget.eventData['_id']),
                      child: const Text('Asistiré'),
                    )
                  : InkWell(
                      onTap: () {
                        // Lógica para mostrar notificación o realizar alguna acción
                        // Puedes agregar aquí la lógica que desees cuando se presiona la campanita
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.notifications, color: Colors.white),
                            const SizedBox(width: 8),
                            const Text('Notificar', style: TextStyle(color: Colors.white)),
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

  Widget _buildLabelText(String label) {
    return Text(
      label,
      style: const TextStyle(fontSize: 17, color: Colors.black, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
    );
  }

  Widget _buildText(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 17, color: Color.fromARGB(166, 0, 0, 0), decoration: TextDecoration.none),
    );
  }
  void _handleAsistireButtonPressed(String eventId) async {
    debugPrint('Asistiré al evento $eventId y mi matricula es $matricula');
    ApiResponse response = await ApiService.postAsistenciaEvento(eventId, matricula.toString());

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