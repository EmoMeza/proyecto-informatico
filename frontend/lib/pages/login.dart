import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:proyecto_informatico/api_services.dart';
import 'package:proyecto_informatico/pages/registro.dart';

import 'menuAlumnos.dart';
import 'menuCAA.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController matriculaController = TextEditingController();
  TextEditingController contrasenaController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void irARegistro() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Registro()),
    );
  }

  Future<void> verificarCredenciales() async {
    final matricula = matriculaController.text;
    final contrasena = contrasenaController.text;

    if (matricula.length < 4 || contrasena.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('La matricula o contraseña estan erroneas.'),
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
    final responseContrasena = await ApiService.login(matricula, contrasena);
    if (responseContrasena.success){
      debugPrint('contra success');
    }
    final responseAlumno = await ApiService.getAlumno(matricula);
    if (responseAlumno.success){
      debugPrint('alumno success');
    }
    if (responseContrasena.success && responseAlumno.success) {
      final alumnoData = responseAlumno.data;
      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => menuAlumnos(alumnoData: alumnoData)));
    } else {
      showErrorMessage("Contraseña o matricula incorrectas");
    }    
  }

  void showErrorMessage(String mensaje) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(mensaje),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[100],
        title: const Text("EventiCAA"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Image.asset(
              'assets/images/logo_udec.jpg',
              width: MediaQuery.of(context).size.width,
              height: 150,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 10),
                const Text("Matricula: "),
                Container(
                  width: 200,
                  height: 40,
                  child: TextField(
                    controller: matriculaController,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 10),
                const Text("Contraseña: "),
                const SizedBox(width: 47),
                Container(
                  width: 200,
                  height: 40,
                  child: TextField(
                    controller: contrasenaController,
                    obscureText: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: verificarCredenciales,
              child: const Text("Ingresar"),
            ),
            const SizedBox(height: 80),
            Center(
              child: InkWell(
                onTap: irARegistro,
                child: const Text(
                  'Registrarse',
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
