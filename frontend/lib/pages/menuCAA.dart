// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:proyecto_informatico/api_services.dart';
import 'package:proyecto_informatico/pages/calendarioCA.dart';
import 'agregarEvento.dart';
import 'flujo_de_caja.dart';
import 'notificaciones.dart';

class menuCAA extends StatelessWidget {
  final List<String> images = [
    'https://via.placeholder.com/200',
    'https://via.placeholder.com/200',
    'https://via.placeholder.com/200',
    // Placeholders de 200x200
  ];

  final String id_caa;

  menuCAA({Key? key, required this.id_caa}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ApiResponse>(
      future: ApiService.getCaa(id_caa),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          ApiResponse apiResponse = snapshot.data!;
          var data_caa = apiResponse.data;
          return Scaffold(
            appBar: AppBar(
              title: Text('CAA: ${data_caa['nombre']}',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary)),
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
                  CarouselSlider(
                    items: images.map((url) {
                      return Image.network(url, fit: BoxFit.cover);
                    }).toList(),
                    options: CarouselOptions(
                      height: 200.0,
                      enableInfiniteScroll: true,
                      autoPlay: true,
                    ),
                  ),
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
                    child: const Text(
                      'Menú CAA',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.add),
                    title: const Text('Agregar Evento'),
                    onTap: () {
                      // Navegar a la página 1
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                AgregarEvento(id_caa: id_caa)),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.calendar_month_outlined),
                    title: const Text('Ver calendario'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CalendarioCA()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.attach_money),
                    title: const Text('Ver flujo de caja'),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => const Dashboard()),
                      );
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
                  // Agrega más opciones de menú según sea necesario
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
