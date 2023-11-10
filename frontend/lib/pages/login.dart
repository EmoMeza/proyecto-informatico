import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:proyecto_informatico/api_services.dart';
import 'package:proyecto_informatico/pages/registro.dart';

import 'menuAlumnos.dart';
import 'menuCAA.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController matriculaController = TextEditingController();
  TextEditingController contrasenaController = TextEditingController();
  bool _showPassword = false;

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

  void irACAA() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => menuCAA()),
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
    if (responseContrasena.success) {
      debugPrint('contra success');
    }
    final responseAlumno = await ApiService.getAlumno(matricula);
    if (responseAlumno.success) {
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
        title: const Text("EventiCAA"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Image.asset(
              'assets/images/logo_udec.jpg',
              width: MediaQuery.of(context).size.width,
              height: 150,
            ),
            const SizedBox(height: 40),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 10),
                    // ignore: sized_box_for_whitespace
                    Container(
                      width:
                          300, // Reducí el ancho para dar espacio a los iconos
                      height: 60,
                      child: TextField(
                        controller: matriculaController,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                        ],
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "Matricula",
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.blue, width: 2.0),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          suffixIcon:
                              const Icon(Icons.person), // Icono de usuario
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 10),
                    // ignore: sized_box_for_whitespace
                    Container(
                      width:
                          300, // Reducí el ancho para dar espacio a los iconos
                      height: 60,
                      child: TextField(
                        controller: contrasenaController,
                        obscureText:
                            !_showPassword, // Oculta o muestra la contraseña
                        decoration: InputDecoration(
                          hintText: "Contraseña",
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.blue, width: 2.0),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(_showPassword
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                _showPassword = !_showPassword;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
              ],
            ),
            ElevatedButton(
              onPressed: verificarCredenciales,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 75),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
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
            const SizedBox(height: 80),
            Center(
              child: InkWell(
                onTap: irACAA,
                child: const Text(
                  'ir a menu CAA (temporal)',
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
