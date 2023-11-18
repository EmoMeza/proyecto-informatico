import '../api_services.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:excel/excel.dart';

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
  String nombreEvento = '';
  late String eventId;
  @override
  void initState() {
    super.initState();
    eventId = widget.eventId;
    _getEventData();

  }
  Future<void> _getEventData() async{
    ApiResponse response = await ApiService.getEvento(eventId);
    if (response.success) {
      // Muestra una ventana emergente con un mensaje
      setState(() {
        nombreEvento = response.data['nombre'];
        asistencias = (response.data['asistencia'] as List<dynamic>).map((e) => e.toString()).toList();
        _loadAlumnosInfo();
      });
    }
  }
  

  Future<void> _loadAlumnosInfo() async {
    List<AlumnoInfo> alumnos = [];

    for (String matricula in asistencias) {
      debugPrint(matricula);
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
  
  Future<void> _exportToExcel() async {
    var excel = Excel.createExcel();
    var sheet = excel['ListaAsistencia'];

    // Headers
    sheet.appendRow(['Matrícula', 'Nombre', 'Apellido']);

    // Data
    for (var alumno in alumnosInfo) {
      sheet.appendRow([alumno.matricula, alumno.nombre, alumno.apellido]);
    }

   // Guarda el archivo Excel en la memoria del dispositivo
    final directory = await getExternalStorageDirectory();
    final filePath = '${directory!.path}/lista_asistencia-$nombreEvento.xlsx';

    // Usa 'encode' en lugar de 'save'
    final fileBytes = excel.encode();

    if (fileBytes != null) {
      await File(filePath).writeAsBytes(fileBytes);

      // Comparte el archivo Excel
      Share.shareFiles([filePath], text: 'Lista de Asistencia - $nombreEvento');
    } else {
      // Handle the case where fileBytes is null (optional)
      print('Error creating Excel file');
    }
  }

  
  Future<void> _exportToPdf() async {
    final pdf = pw.Document();

    // Agrega una página al PDF
    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(level: 1, text: 'Lista de Asistencia $nombreEvento'),
          pw.SizedBox(height: 10),
          pw.TableHelper.fromTextArray(
            context: context,
            cellAlignment: pw.Alignment.center,
            cellStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(
              color: PdfColors.grey300,
            ),
            data: <List<String>>[
              ['Matrícula', 'Nombre', 'Apellido'],
              for (var alumno in alumnosInfo)
                [alumno.matricula, alumno.nombre, alumno.apellido],
            ],
          ),
        ],
      ),
    );

    // Obtiene el directorio temporal en el dispositivo móvil
    final directory = await getTemporaryDirectory();

    // Crea la ruta del archivo
    final filePath = '${directory.path}/lista_asistencia.pdf';

    // Guarda el PDF en la ruta del archivo
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    // Comparte el archivo PDF
    Share.shareFiles([filePath], text: 'Lista de Asistencia - $nombreEvento');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Asistencia'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed:() {
              _exportToPdf();
            },
          ),
          IconButton(
            icon: const Icon(Icons.table_chart),
            onPressed: _exportToExcel,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              const Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 8.0),
                  Text('Cargando asistencias...'),
                ],
              ),
            if (!isLoading)
              Expanded(
                child: DataTable(
                  columns: const [
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

