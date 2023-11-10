import 'package:flutter/material.dart';
import 'package:proyecto_informatico/pages/calendario.dart';
import 'package:proyecto_informatico/pages/login.dart';
import 'package:proyecto_informatico/pages/menuCAA.dart';
import 'package:proyecto_informatico/pages/agregarEvento.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  initializeDateFormatting().then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EventiCAA',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: generateMaterialColor(const Color(0xFF09184d)),
        ).copyWith(
          secondary: const Color(0xFF7B5BF2),
          background: Colors.white, // Cambia el color de fondo
          surface: Colors.grey, // Cambia el color de superficie
          onPrimary:
              Colors.white, // Cambia el color del texto en el color principal
          onSecondary:
              Colors.grey, // Cambia el color del texto en el color secundario
          brightness: Brightness.light, // Cambia el brillo del tema
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const Login(),
        '/menuCAA': (context) => menuCAA(),
        '/agregarEvento': (context) => AgregarEvento(),
        '/calendario': (context) => Calendario(),
      },
    );
  }
}

MaterialColor generateMaterialColor(Color color) {
  List strengths = <double>[.05, .1, .2, .3, .4, .5, .6, .7, .8, .9];
  Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 0; i < 10; i++) {
    swatch[(strengths[i] * 1000).round()] = Color.fromRGBO(
      r,
      g,
      b,
      strengths[i],
    );
  }

  return MaterialColor(color.value, swatch);
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
