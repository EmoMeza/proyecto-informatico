import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../api_services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Dashboard(),
    );
  }
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _DashboardState createState() => _DashboardState();
}

class DataPoint {
  final int value;
  final String description;
  // guardamos un tipo de dato ISOS de fecha
  final String date;
  String evento = "";

  DataPoint(this.value, this.description, this.date, this.evento);

  Map<String, dynamic> toMap() {
    return {
      'value': value,
      'description': description,
      'date': date,
      'evento': evento,
    };
  }

  factory DataPoint.fromMap(Map<String, dynamic> map) {
    return DataPoint(
        map['value'], map['description'], map['date'], map['evento']);
  }
}

class _DashboardState extends State<Dashboard> {
  List<DataPoint> cashFlowData = []; // Declaración de la lista
  int total = 0;
  bool isloading = true;
  List<String> eventos = [];
  List<String> eventosId = [];
  String? dialogEvent = "General";
  String? dropdownValue = "General";
  List<DataPoint> filteredCashFlowData = [];

  @override
  void initState() {
    super.initState();
    _LoadCashFlow(); // Cargar los datos de ingresos y egresos
  }

  // funcion que retorna un string id de la base de datos
  String getIdCaa() {
    //ApiResponse response = ApiService.getCaa(alumno);
    return '6552d3d4ec6e222a40b76125';
  }

  // funcion para añadir ingreso o egreso a la base de datos
  // ignore: non_constant_identifier_names
  void _AddCashFlow(bool isIncome, int amount, String description) async {
    final monto = amount;
    final descripcion = description;
    final id = getIdCaa(); // Replace with the actual CAA ID
    // guardamos dentro de una lista el id de los eventos que se encuentran en el cashflowdata[3]

    if (isIncome) {
      if (dialogEvent == "General") {
        ApiResponse response = await ApiService.postIngresoCaa(id, {
          'ingresos': [monto, descripcion]
        });
        if (response.success) {
          //en caso de funcionar se actualiza la lista cashFlowData
          _LoadCashFlow();
        } else {
          // Handle error
          // ignore: avoid_print
          print('Error adding income: ${response.message}');
        }
      } else {
        // usando dialogevent se obtiene el id del evento
        // ignore: unused_local_variable
        var idEvento = eventosId[eventos.indexOf(dialogEvent!)];
        ApiResponse response = await ApiService.postIngresoEvento(idEvento, {
          'ingresos': [monto, descripcion]
        });
        if (response.success) {
          _LoadCashFlow();
        } else {
          // ignore: avoid_print
          print('Error adding income: ${response.message}');
        }
      }
    } else {
      if (dialogEvent == "General") {
        ApiResponse response = await ApiService.postEgresoCaa(id, {
          'egresos': [monto, descripcion]
        });
        if (response.success) {
          //en caso de funcionar se actualiza la lista cashFlowData
          _LoadCashFlow();
        } else {
          // ignore: avoid_print
          print('Error adding income: ${response.message}');
        }
      } else {
        // usando dialogevent se obtiene el id del evento
        // ignore: unused_local_variable
        var idEvento = eventosId[eventos.indexOf(dialogEvent!)];

        ApiResponse response = await ApiService.postEgresoEvento(idEvento, {
          'egresos': [monto, descripcion]
        });
        if (response.success) {
          _LoadCashFlow();
        } else {
          // ignore: avoid_print
          print('Error adding income: ${response.message}');
        }
      }
    }
    setState(() {});
  }

  // ignore: non_constant_identifier_names
  void _LoadCashFlow() async {
    final id = getIdCaa(); // Reemplaza con el ID real de CAA
    // ignore: non_constant_identifier_names
    var Response = await ApiService.getCaa(id);

    if (Response.success) {
      final income = Response.data['ingresos'];
      final expense = Response.data['egresos'];

      //ahora usando un iterador se recorre la lista de ingresos y egresos y se van agregando a la lista cashFlowData
      List<DataPoint> incomeData = (income is List)
          ? (income)
              .where((item) => item != null) // Filtrar elementos nulos
              .map((item) => DataPoint(
                    item[0],
                    item[1],
                    item[2],
                    item.length > 3 ? item[3] : "General",
                  ))
              .toList()
          : [];

      List<DataPoint> expenseData = (expense is List)
          ? (expense)
              .where((item) => item != null) // Filtrar elementos nulos
              .map((item) => DataPoint(
                    -item[0],
                    item[1],
                    item[2],
                    item.length > 3 ? item[3] : "General",
                  ))
              .toList()
          : [];

      cashFlowData = [...incomeData, ...expenseData];
      // ordenamos cashflowdata por fecha de mas nuevo a mas viejo
      cashFlowData.sort((a, b) => b.date.compareTo(a.date));
      // ordenamos los eventos
      await _loadEventos();
      ApiResponse getTotal = await ApiService.getTotalCaa(id);
      total = getTotal.data;
      setState(() {
        _filterCashFlowData();
        isloading = false;
      });
    } else {
      // ignore: avoid_print
      print('Error al obtener los datos: ${Response.message}');
    }
  }

  Future<void> _loadEventos() async {
    if (eventos.isEmpty) eventos.add("General");
    if (eventosId.isEmpty) eventosId.add("General");
    Map<String, dynamic> filtrarEventos = {
      "id_creador": getIdCaa(),
    };
    ApiResponse response = await ApiService.getEventosFiltrados(filtrarEventos);
    if (response.success) {
      //ingresamos los datos _id y nombre de los eventos en un mapa
      for (var i = 0; i < response.data.length; i++) {
        if (!eventosId.contains(response.data[i]['_id'])) {
          eventos.add(response.data[i]['nombre']);
          eventosId.add(response.data[i]['_id']);
        }
      }
    } else {
      // ignore: avoid_print
      print('Error al obtener los datos: ${response.message}');
    }
  }

  void _filterCashFlowData() {
    if (dropdownValue == "General") {
      filteredCashFlowData = List.from(cashFlowData);
    } else {
      filteredCashFlowData = cashFlowData
          .where((dataPoint) => dataPoint.evento == dropdownValue)
          .toList();
    }
  }

  void _openEntryDialog(bool isIncome) async {
    TextEditingController amountController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isIncome ? 'Añadir Ingreso' : 'Añadir Egreso'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Monto'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),
              SafeArea(
                  child: Container(
                margin: const EdgeInsets.only(top: 5),
                child: DropdownButton(
                  value: dialogEvent,
                  onChanged: (String? newValue) {
                    setState(() {
                      dialogEvent = newValue;
                      Navigator.of(context).pop();
                      _openEntryDialog(isIncome);
                    });
                  },
                  items: eventos.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: SizedBox(
                        width: 225.0,
                        child: Text(value),
                      ),
                    );
                  }).toList(),
                ),
              )),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                final monto = int.tryParse(amountController.text);

                if (monto != null && monto > 0 && monto < 10000000) {
                  final descripcion = descriptionController.text;

                  if (descripcion.length <= 250) {
                    // La descripción tiene 250 caracteres o menos.
                    _AddCashFlow(isIncome, monto, descripcion);
                    Navigator.of(context).pop();
                  } else {
                    // Mostrar un mensaje de error si la descripción supera los 250 caracteres.
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Error'),
                          content: const Text(
                              'La descripción debe tener 250 caracteres o menos.'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context)
                                    .pop(); // Cerrar el mensaje de error.
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                } else {
                  // Mostrar un mensaje de error si el monto no es válido.
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Error'),
                        content:
                            const Text('El monto debe ser menor a 10,000,000.'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context)
                                  .pop(); // Cerrar el mensaje de error.
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: const Text('Guardar'),
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
        title: Text('Flujo de caja',
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: IconThemeData(
          color: Theme.of(context)
              .colorScheme
              .onPrimary, // Cambia el color según tu necesidad
        ),
      ),
      body: DefaultTextStyle(
        style: TextStyle(
          color: Theme.of(context).colorScheme.brightness != Brightness.light
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context)
                  .colorScheme
                  .onSecondary, // Color de texto predeterminado
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 40.0,
                  child: Center(
                    child: Text(
                      'Total: \$${total.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                ),
                DropdownButton<String>(
                  value: dropdownValue,
                  onChanged: (String? newValue) {
                    setState(() {
                      dropdownValue = newValue;
                      _filterCashFlowData(); // Filtrar datos cuando cambia el valor del dropdown
                    });
                  },
                  items: eventos.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: SizedBox(
                        width: 300.0, // Establecer el ancho deseado
                        child: Text(value),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            if (isloading) // Muestra la barra de carga y el texto de carga mientras isLoading es true
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SizedBox(
                      width: 65,
                      height: 65,
                      child: CircularProgressIndicator(
                        strokeWidth: 5,
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Text('Cargando Flujos...'), // Texto de carga
                  ],
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: filteredCashFlowData.length,
                  itemBuilder: (context, index) {
                    final dataPoint = filteredCashFlowData[index];
                    return Card(
                      elevation: 4.0,
                      margin: const EdgeInsets.all(8.0),
                      child: ExpansionTile(
                        tilePadding:
                            const EdgeInsets.symmetric(horizontal: 16.0),
                        title: Text(
                          dataPoint.description.length <=
                                  20 // Establece el límite de caracteres, por ejemplo, 20.
                              ? dataPoint
                                  .description // Si es menor o igual al límite, muestra el texto completo.
                              : '${dataPoint.description.substring(0, 30)}...', // Si es mayor que el límite, muestra los primeros 20 caracteres seguidos de "...". Puedes ajustar el número 20 según tus necesidades.
                          style: const TextStyle(
                            fontSize: 18.0,
                          ),
                        ),
                        subtitle: Text(
                          '\$${dataPoint.value.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 18.0,
                            color: dataPoint.value > 0
                                ? const Color(0xFF00B295)
                                : const Color(0xFFF18F01),
                          ),
                        ),
                        children: <Widget>[
                          ListTile(
                            title: Text(
                              dataPoint.description,
                              style: const TextStyle(
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                          ListTile(
                            title: Text(
                              'Fecha: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(dataPoint.date))}',
                              style: const TextStyle(
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                  child: ElevatedButton(
                    onPressed: () {
                      _openEntryDialog(true);
                    },
                    style: ButtonStyle(
                      fixedSize: MaterialStateProperty.all(const Size(150, 50)),
                    ),
                    child: const Text(
                      'Añadir Ingreso',
                      style: TextStyle(
                        color:
                            Colors.white, // Cambia el color del texto a blanco
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                  child: ElevatedButton(
                    onPressed: () {
                      _openEntryDialog(false);
                    },
                    style: ButtonStyle(
                      fixedSize: MaterialStateProperty.all(const Size(150, 50)),
                    ),
                    child: const Text(
                      'Añadir Egreso',
                      style: TextStyle(
                        color:
                            Colors.white, // Cambia el color del texto a blanco
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
