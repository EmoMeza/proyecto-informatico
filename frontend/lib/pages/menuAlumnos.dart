// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'package:proyecto_informatico/pages/menuCAA.dart';
import 'calendarioAlumos.dart';

class menuAlumnos extends StatelessWidget {

  final Map<String, dynamic> alumnoData;
  const menuAlumnos({Key? key, required this.alumnoData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alumno: ${alumnoData['nombre']} ${alumnoData['apellido']}',
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: IconThemeData(
          color: Theme.of(context)
              .colorScheme
              .onPrimary, // Cambia el color según tu necesidad
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text('Alumno data: ${alumnoData['nombre']} ${alumnoData['apellido']}, es caa: ${alumnoData['es_caa']}'),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage('https://via.placeholder.com/200'),
                  ),
                  const SizedBox(height: 10),
                  Expanded(child: Text(
                    '${alumnoData['nombre']} ${alumnoData['apellido']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Agregar Evento'),
              onTap: () {
                // Navegar a la página 1
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month_outlined),
              title: const Text('Ver calendario'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => CalendarioAlumos()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text('Ver flujo de caja'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            // Cursed code
            if (alumnoData['es_caa'] == 'true')
              const Divider(),
            if (alumnoData['es_caa'] == 'true')
              ListTile(
                leading: const Icon(Icons.now_widgets_outlined),
                title: const Text('Menú CAA'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => menuCAA(id_caa: alumnoData['id_caa'])));
                          },
              ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar sesión'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
