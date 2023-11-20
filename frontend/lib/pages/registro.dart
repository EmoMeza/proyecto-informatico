import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../api_services.dart';

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

  @override
  void initState() {
    super.initState();
    // Inicia la llamada a la API una vez cuando se inicia el widget
    caaFuture = ApiService.getAllCaa();
  }

  void guardarDatos() async {
    // Resto del código para guardarDatos
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
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(labelText: 'Nombre: '),
              ),
              TextField(
                controller: apellidoController,
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
              const SizedBox(height: 20),
              Row(
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
                  const Text('Es CAA'),
                  const SizedBox(width: 20),
                  // Lista desplegable para seleccionar idCaa
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
              const SizedBox(height: 20),
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
