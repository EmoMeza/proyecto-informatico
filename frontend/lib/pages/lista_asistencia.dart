import 'package:flutter/material.dart';
import '../api_services.dart';

class ListaAsistenciaPage extends StatefulWidget {
  final String eventId;

  ListaAsistenciaPage(this.eventId);

  @override
  _ListaAsistenciaPageState createState() => _ListaAsistenciaPageState();
}

class _ListaAsistenciaPageState extends State<ListaAsistenciaPage> {
  List<String> asistencias = [];
  List<AlumnoInfo> alumnosInfo = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAsistencias();
  }

  Future<void> _loadAsistencias() async {
    ApiResponse response = await ApiService.getAsistenciasEvento(widget.eventId);

    setState(() {
      if (response.success && response.data is List) {
        asistencias = (response.data as List<dynamic>).map((e) => e.toString()).toList();
        _loadAlumnosInfo();
      } else {
        asistencias = [];
        isLoading = false;
      }
    });
  }

  Future<void> _loadAlumnosInfo() async {
    List<AlumnoInfo> alumnos = [];

    for (String matricula in asistencias) {
      ApiResponse response = await ApiService.getAlumno(matricula);

      if (response.success && response.data != null) {
        alumnos.add(AlumnoInfo.fromJson(response.data));
      }
    }

    setState(() {
      alumnosInfo = alumnos;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Asistencia'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 8.0),
                  Text('Cargando asistencias...'),
                ],
              ),
            if (!isLoading)
              Expanded(
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('Matrícula')),
                    DataColumn(label: Text('Nombre')),
                    DataColumn(label: Text('Apellido')),
                  ],
                  rows: alumnosInfo.map((alumno) {
                    return DataRow(cells: [
                      DataCell(Text(alumno.matricula)),
                      DataCell(Text(alumno.nombre)),
                      DataCell(Text(alumno.apellido)),
                    ]);
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class AlumnoInfo {
  final String matricula;
  final String nombre;
  final String apellido;

  AlumnoInfo({
    required this.matricula,
    required this.nombre,
    required this.apellido,
  });

  factory AlumnoInfo.fromJson(Map<String, dynamic> json) {
    return AlumnoInfo(
      matricula: json['matricula'].toString(),
      nombre: json['nombre'],
      apellido: json['apellido'],
    );
  }
}