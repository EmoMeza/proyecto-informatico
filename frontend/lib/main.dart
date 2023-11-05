import 'package:flutter/material.dart';
import 'package:proyecto_informatico/pages/login.dart';
import 'package:proyecto_informatico/pages/menuCAA.dart';
import 'package:proyecto_informatico/pages/menuAlumnos.dart';
import 'package:proyecto_informatico/pages/agregarEvento.dart';

void main() {
  runApp(const MyApp());
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
          primarySwatch: Colors.deepPurple, // Set the primary swatch color
        ).copyWith(secondary: Colors.deepPurple), // Set the secondary color
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const Login(),
        '/menuCAA': (context) => menuCAA(),
        '/menuAlumnos': (context) => menuAlumnos(),
        '/agregarEvento': (context) => AgregarEvento(),
      },
    );
  }
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
