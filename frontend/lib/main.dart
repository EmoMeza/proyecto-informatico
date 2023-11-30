import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:proyecto_informatico/pages/calendarioAlumos.dart';
import 'package:proyecto_informatico/pages/calendarioCA.dart';
import 'package:proyecto_informatico/pages/login.dart';
import 'package:proyecto_informatico/pages/menuCAA.dart';
import 'package:proyecto_informatico/pages/agregarEvento.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  initializeDateFormatting().then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EventiCAA',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.deepPurple,
        ).copyWith(
          secondary: const Color(0xFF119DA4),
          background: Colors.white, // Cambia el color de fondo
          surface: Colors.deepPurple, // Cambia el color de superficie
          onBackground: Colors.black, // Cambia el color del texto en el fondo
          // onSurface cambia de color dependiendo del brillo del tema
          onPrimary:
              Colors.white, // Cambia el color del texto en el color principal
          onSecondary:
              Colors.black, // Cambia el color del texto en el color secundario
          brightness: Brightness.light, // Cambia el brillo del tema
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const Login(),
        '/agregarEvento': (context) => const AgregarEvento(id_caa: ''),
        '/calendarioCA': (context) => CalendarioCA(id_caa: ''),
        '/calendarioAlumos': (context) =>
            CalendarioAlumos(matricula: 0, id_caa: ''),
      },
      localizationsDelegates: const [
        // para habilitar widgets en español
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es'), // Español
      ],
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
