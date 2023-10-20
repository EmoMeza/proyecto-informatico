// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

class Registro extends StatefulWidget {
  const Registro({Key? key}) : super(key: key);

  @override
  _RegistroState createState() => _RegistroState();
}

class _RegistroState extends State<Registro> {
  TextEditingController loginController = TextEditingController();
  TextEditingController contrasenaController = TextEditingController();
  TextEditingController repetirContrasenaController = TextEditingController();
  TextEditingController nombreController = TextEditingController();
  String tipoCuenta = 'Estudiante';

  void guardarDatos() async {
    final login = loginController.text;
    final contrasena = contrasenaController.text;
    final nombre = nombreController.text;

    if (contrasena != repetirContrasenaController.text) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Las contraseñas no coinciden.'),
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
    } catch (e) {
      debugPrint('Error al guardar los datos en MongoDB: $e');
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
                controller: nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              Row(
                children: [
                  const Text('Seleccionar tipo de cuenta:'),
                  DropdownButton<String>(
                    value: tipoCuenta,
                    onChanged: (String? value) {
                      setState(() {
                        tipoCuenta = value!;
                      });
                    },
                    items: <String>['Estudiante', 'Centro de Alumnos']
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
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
