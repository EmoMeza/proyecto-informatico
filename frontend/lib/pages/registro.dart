// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
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

  void guardarDatos() async {
    final matricula = matriculaController.text;
    final nombre = nombreController.text;
    final apellido = apellidoController.text;

    if (matricula.length < 4 || nombre.isEmpty || apellido.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('La matricula no es válida.'),
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

    final alumnoData = {
      'matricula': matricula,
      'nombre': nombre,
      'apellido': apellido,
    };

    ApiResponse responseA = await ApiService.postAlumno(nombre, apellido, matricula, alumnoData);

    if (responseA.success) {
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Éxito'),
            content: const Text('Se ha creado su cuenta con éxito. Puede iniciar sesión.'),
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
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('Error al registrar al alumno: ${responseA.message}'),
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
                decoration: const InputDecoration(labelText: 'Matricula: '),
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
