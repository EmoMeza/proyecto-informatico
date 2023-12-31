// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../api_services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:flutter_image_compress/flutter_image_compress.dart';


class Registro extends StatefulWidget {
  const Registro({Key? key}) : super(key: key);

  @override
  _RegistroState createState() => _RegistroState();
}

class _RegistroState extends State<Registro> {
  TextEditingController nombreController = TextEditingController();
  TextEditingController apellidoController = TextEditingController();
  TextEditingController matriculaController = TextEditingController();
  String tipoCuenta = 'Estudiante';
  bool esCaa = false;
  String idCaa = '';
  late Future<ApiResponse> caaFuture;
  XFile? _pickedImage;
  File? imageFile;

  @override
  void initState() {
    super.initState();
    // Inicia la llamada a la API una vez cuando se inicia el widget
    caaFuture = ApiService.getAllCaa();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    setState(() {
      _pickedImage = pickedFile;
    });
  }

  void guardarDatos() async {
  String nombre = nombreController.text;
  String apellido = apellidoController.text;
  int matricula = matriculaController.text.isEmpty ? 0 : int.parse(matriculaController.text);
  
  // Validation
  if (nombre.length < 2) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('El nombre debe tener al menos 2 caracteres'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    return;
  }
  if (apellido.length < 2) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('El apellido debe tener al menos 2 caracteres'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    return;
  }

  String? base64Image;
  String? imagenConvertida;
  if (_pickedImage != null) {
    List<int> imageBytes = await _pickedImage!.readAsBytes();
    imagenConvertida = base64.encode(imageBytes);
    Uint8List uint8List = Uint8List.fromList(imageBytes);
    List<int> compressedBytes = await FlutterImageCompress.compressWithList(
      uint8List,
      quality: 80, // Adjust the quality as needed (0 to 100)
    );
    base64Image = base64Encode(compressedBytes);
    int originalSizeInBytes = imageBytes.length;
    int encodedSizeInBytes = imagenConvertida!.length;
    int compressedEncodedSizeInBytes = base64Image!.length;
    debugPrint('Original Size: ${originalSizeInBytes / 1024} KB');
    debugPrint('Encoded Size: ${encodedSizeInBytes / 1024} KB');
    debugPrint('Compressed and Encoded Size: ${compressedEncodedSizeInBytes / 1024} KB');
  }
  Map<String, dynamic> postData = {
    'nombre': nombre,
    'apellido': apellido,
    'matricula': matricula,
    'esCaa': esCaa,
    'idCaa': idCaa,
    'imagen': base64Image ?? '',
  };

  ApiResponse response = await ApiService.postAlumno(nombre, apellido, matricula, esCaa, idCaa, postData);

  if (response.success) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Exito'),
            content: const Text('La cuenta se ha creado exitosamente.'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
  } else {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('Ha ocurrido un error al crear la cuenta: ${response.message}.'),
            actions: [
              ElevatedButton(
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
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: nombreController,
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 2) {
                    return 'Introduce al menos 2 caracteres';
                  }
                  return null;
                },
                decoration: const InputDecoration(labelText: 'Nombre: '),
              ),
              TextFormField(
                controller: apellidoController,
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 2) {
                    return 'Introduce al menos 2 caracteres';
                  }
                  return null;
                },
                decoration: const InputDecoration(labelText: 'Apellido: '),
              ),
              TextField(
                controller: matriculaController,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                ],
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Matricula: '),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Color.fromARGB(255,212,212,212),
                      width: 2.0,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Casilla de verificación para esCaa
                    Checkbox(
                      value: esCaa,
                      onChanged: (value) {
                        setState(() {
                          esCaa = value!;
                        });
                      },
                    ),
                    const Text('¿Eres parte de un CAA?'),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Color.fromARGB(255,212,212,212),
                      width: 2.0,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Selecciona tu centro de alumnos: '),
                    FutureBuilder<ApiResponse>(
                      future: caaFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          ApiResponse apiResponse = snapshot.data as ApiResponse;
                          if (apiResponse.success) {
                            List<dynamic> caas = apiResponse.data as List<dynamic>;

                            // Verifica si idCaa es válido y establece un valor predeterminado si no lo es
                            if (idCaa.isEmpty || !caas.any((caa) => caa['_id'] == idCaa)) {
                              idCaa = caas.first['_id']; // Puedes ajustar esto según tus necesidades
                            }

                            return DropdownButton<String>(
                              value: idCaa,
                              hint: const Text('Seleccionar CAA'),
                              items: caas.map((caa) {
                                return DropdownMenuItem<String>(
                                  value: caa['_id'],
                                  child: Text(caa['nombre']),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  idCaa = value!;
                                });
                              },
                            );
                          } else {
                            return Text('Error en la respuesta de la API: ${apiResponse.message}');
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('Selecciona una imagen de perfil:'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      IconButton(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo),
                        tooltip: 'Seleccionar imagen',
                      ),
                      const Text('Seleccionar de la galería'),
                    ],
                  ),
                  const SizedBox(width: 20), // Add some spacing between icons and text
                  Column(
                    children: [
                      IconButton(
                        onPressed: () => _pickImage(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt),
                          tooltip: 'Tomar foto',
                        ),
                      const Text('Tomar una foto'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20), // Add some spacing between rows
              _pickedImage != null
                ? Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Imagen seleccionada:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _pickedImage = null;
                              });
                            },
                            icon: const Icon(Icons.delete),
                            tooltip: 'Eliminar imagen',
                          ),
                        ],
                      ),
                      Image.file(
                        File(_pickedImage!.path),
                        height: 100,
                        width: 100,
                      ),
                    ],
                  )
                : const Text('No se ha seleccionado ninguna imagen'),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: guardarDatos,
                    child: const Text('Guardar'),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Volver'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
