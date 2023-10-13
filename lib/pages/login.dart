import 'package:flutter/material.dart';
import 'package:proyecto_informatico/pages/registro.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'menuAlumnos.dart';
import 'menuCAA.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController usuarioController = TextEditingController();
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

  Future<Map<String, String?>> obtenerCredenciales() async {
    final prefs = await SharedPreferences.getInstance();
    final login = prefs.getString('login');
    final contrasena = prefs.getString('contrasena');
    return {'login': login, 'contrasena': contrasena};
  }

  Future<void> verificarCredenciales() async {
    final nombreUsuario = usuarioController.text;
    final contrasena = contrasenaController.text;

    final credencialesGuardadas = await obtenerCredenciales();
    final loginGuardado = credencialesGuardadas['login'];
    final contrasenaGuardada = credencialesGuardadas['contrasena'];

    if (loginGuardado == nombreUsuario && contrasenaGuardada == contrasena) {
      final prefs = await SharedPreferences.getInstance();
      final tipoCuenta = prefs.getString('tipoCuenta');

      if (tipoCuenta == 'Estudiante') {
        // Redirige a la página de estudiantes
        Navigator.push(context, MaterialPageRoute(builder: (context) => menuAlumnos()));
      } else if (tipoCuenta == 'Centro de Alumnos') {
        // Redirige a la página de centro de alumnos
        Navigator.push(context, MaterialPageRoute(builder: (context) => menuCAA()));
      } else {
        // Tipo de cuenta desconocido, maneja el caso como desees
        debugPrint('Tipo de cuenta desconocido');
      }
    } else {
      // Credenciales incorrectas
      debugPrint('Credenciales incorrectas');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[100],
        title: const Text("Todo listas"),
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
                const Text("Nombre de usuario: "),
                Container(
                  width: 200,
                  height: 40,
                  child: TextField(
                    controller: usuarioController,
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
