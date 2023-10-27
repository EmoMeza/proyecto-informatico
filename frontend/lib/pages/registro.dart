<<<<<<< Updated upstream
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
=======
import 'dart:convert';
import 'package:flutter/material.dart';
import '../api_services.dart';
>>>>>>> Stashed changes

class Registro extends StatefulWidget {
  const Registro({Key? key}) : super(key: key);

  @override
  _RegistroState createState() => _RegistroState();
}

class _RegistroState extends State<Registro> {
  TextEditingController nombreController = TextEditingController();
<<<<<<< Updated upstream
  String tipoCuenta = 'Estudiante';

  void guardarDatos() async {
    final login = loginController.text;
    final contrasena = contrasenaController.text;
=======
  TextEditingController apellidoController = TextEditingController();
  TextEditingController matriculaController = TextEditingController();
  String tipoCuenta = 'Estudiante';

  void guardarDatos() async {
    final matricula = matriculaController.text;
>>>>>>> Stashed changes
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

<<<<<<< Updated upstream
    // Configurar la conexión MongoDB
    final db = mongo.Db('mongodb+srv://Jose-BA:profevaras@cluster0.trauygm.mongodb.net/?retryWrites=true&w=majority');

    try {
      await db.open();
      
      await db.collection('usuarios').insert({
        'login': login,
        'contrasena': contrasena,
        'nombre': nombre,
        'tipoCuenta': tipoCuenta,
      });

      await db.close();

=======
    final alumnoData = {
      'matricula': matricula,
      'nombre': nombre,
      'apellido': apellido,
    };

    ApiResponse responseA = await ApiService.postAlumno(nombre, matricula, apellido, alumnoData);

    if (responseA.success) {
      // ignore: use_build_context_synchronously
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
    } catch (e) {
      debugPrint('Error al guardar los datos en MongoDB: $e');
=======
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
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
                controller: loginController,
                decoration: const InputDecoration(labelText: 'Login'),
              ),
              TextField(
                controller: contrasenaController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Contraseña'),
              ),
              TextField(
                controller: repetirContrasenaController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Repetir Contraseña'),
              ),
              TextField(
=======
>>>>>>> Stashed changes
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
