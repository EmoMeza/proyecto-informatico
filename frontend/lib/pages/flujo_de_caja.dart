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

  DataPoint(this.value, this.description, this.date);

  Map<String, dynamic> toMap() {
    return {
      'value': value,
      'description': description,
      'date': date,
    };
  }

  factory DataPoint.fromMap(Map<String, dynamic> map) {
    return DataPoint(map['value'], map['description'], map['date']);
  }
}

class _DashboardState extends State<Dashboard> {
  List<DataPoint> cashFlowData = []; // Declaración de la lista
  int total = 0;
  bool isloading = true;
  @override
  void initState() {
    super.initState();
    _LoadIncomeOrExpense(); // Cargar los datos de ingresos y egresos
  }

  // funcion para añadir ingreso o egreso a la base de datos
  void _addIncomeOrExpense(
      bool isIncome, int amount, String description) async {
    final monto = amount;
    final descripcion = description;
    const id = '6530ac564fc4cee2752b73ae'; // Replace with the actual CAA ID

    if (isIncome) {
      ApiResponse response = await ApiService.postIngresoCaa(id, {
        'ingresos': [monto, descripcion]
      });
      if (response.success) {
        //en caso de funcionar se actualiza la lista cashFlowData
        _LoadIncomeOrExpense();
      } else {
        // Handle error
        // ignore: avoid_print
        print('Error adding income: ${response.message}');
      }
    } else {
      ApiResponse response = await ApiService.postEgresoCaa(id, {
        'egresos': [monto, descripcion]
      });
      if (response.success) {
        _LoadIncomeOrExpense();
      } else {
        // Handle error
        // ignore: avoid_print
        print('Error adding expense: ${response.message}');
      }
    }
    setState(() {});
  }

  // ignore: non_constant_identifier_names
  void _LoadIncomeOrExpense() async {
    const id = '6530ac564fc4cee2752b73ae'; // Reemplaza con el ID real de CAA
    // ignore: non_constant_identifier_names
    var Response = await ApiService.getCaa(id);

    if (Response.success) {
      final income = Response.data['ingresos'];
      final expense = Response.data['egresos'];

      //ahora usando un iterador se recorre la lista de ingresos y egresos y se van agregando a la lista cashFlowData
      List<DataPoint> incomeData = (income is List)
          ? (income)
              .where((item) => item != null) // Filtrar elementos nulos
              .map((item) => DataPoint(item[0], item[1], item[2]))
              .toList()
          : [];

      List<DataPoint> expenseData = (expense is List)
          ? (expense)
              .where((item) => item != null) // Filtrar elementos nulos
              .map((item) => DataPoint(-item[0], item[1], item[2]))
              .toList()
          : [];

      cashFlowData = [...incomeData, ...expenseData];
      // ordenamos cashflowdata por fecha de mas nuevo a mas viejo
      cashFlowData.sort((a, b) => b.date.compareTo(a.date));

      ApiResponse getTotal = await ApiService.getTotalCaa(id);
      setState(() {
        //convierte getTotal.data a double
        total = getTotal.data;
        isloading = false;
      });
    } else {
      // ignore: avoid_print
      print('Error al obtener los datos: ${Response.message}');
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
                // Guardar los datos en la lista cashFlowData
                final monto = int.parse(amountController.text);
                final descripcion = descriptionController.text;
                // Llamar a la función para añadir ingreso o egreso
                _addIncomeOrExpense(isIncome, monto, descripcion);
                Navigator.of(context).pop();
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Icono del botón de devolución
          onPressed: () {
            // Agrega la lógica para manejar la acción de devolución
            Navigator.of(context).pop();
          },
          color: Colors.black, // Cambia el color del icono
        ),
        title: const Text(
          'Flujo de caja',
          style: TextStyle(
            color: Colors.black, // Cambia el color del texto a blanco
          ),
        ),
      ),
      body: DefaultTextStyle(
        style: const TextStyle(
          color: Colors.black, // Color de texto predeterminado
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              width: double.infinity,
              height: 40.0,
              decoration: const BoxDecoration(
                color: Colors.deepPurple,
              ),
              child: Center(
                child: Container(
                  child: Text(
                    'Total: \$${total.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                ),
              ),
            ),
            if (isloading)
              Center(
                child: Container(
                  width: 75,
                  height: 75,
                  child: const CircularProgressIndicator(
                    strokeWidth: 7,
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: cashFlowData.length,
                  itemBuilder: (context, index) {
                    final dataPoint = cashFlowData[index];
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 2.0,
                          color: Colors.white,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: ListTile(
                        tileColor: dataPoint.value > 0
                            ? const Color(0xFF07CB9A)
                            : const Color(0xFFFA4B68),
                        title: Text(
                          dataPoint.description,
                          style: const TextStyle(
                            fontSize: 18.0,
                          ),
                        ),
                        subtitle: Text(
                          '\$${dataPoint.value.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        trailing: Text(
                          DateFormat('yyyy-MM-dd HH:mm')
                              .format(DateTime.parse(dataPoint.date)),
                          style: const TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(2),
                      ),
                    );
                  },
                ),
              ),
            Container(
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                    child: ElevatedButton(
                      onPressed: () {
                        _openEntryDialog(true);
                      },
                      style: ButtonStyle(
                        fixedSize:
                            MaterialStateProperty.all(const Size(150, 50)),
                      ),
                      child: const Text(
                        'Añadir Ingreso',
                        style: TextStyle(
                          color: Colors
                              .black, // Cambia el color del texto a blanco
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
                        fixedSize:
                            MaterialStateProperty.all(const Size(150, 50)),
                      ),
                      child: const Text(
                        'Añadir Egreso',
                        style: TextStyle(
                          color: Colors
                              .black, // Cambia el color del texto a blanco
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
