import 'package:flutter/material.dart';
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

  DataPoint(this.value, this.description);

  Map<String, dynamic> toMap() {
    return {
      'value': value,
      'description': description,
    };
  }

  factory DataPoint.fromMap(Map<String, dynamic> map) {
    return DataPoint(map['value'], map['description']);
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

  void _updateCashFlowAndSave(bool isIncome, int amount, String description) {
    if (isIncome) {
      cashFlowData.add(DataPoint(amount, description));
    } else {
      cashFlowData.add(DataPoint(-amount, description));
    }
    setState(() {});
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
        _updateCashFlowAndSave(isIncome, monto, descripcion);
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
        _updateCashFlowAndSave(isIncome, monto, descripcion);
      } else {
        // Handle error
        // ignore: avoid_print
        print('Error adding expense: ${response.message}');
      }
    }
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
              .map((item) => DataPoint(item[0], item[1]))
              .toList()
          : [];

      List<DataPoint> expenseData = (expense is List)
          ? (expense)
              .where((item) => item != null) // Filtrar elementos nulos
              .map((item) => DataPoint(-item[0], item[1]))
              .toList()
          : [];

      cashFlowData = [...incomeData, ...expenseData];
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
        title: const Text('Flujo de caja'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            children: <Widget>[
              const Text('Flujo de Caja'),
              Text('Total: \$${total.toStringAsFixed(0)}'),
            ],
          ),
          if (isloading)
            Center(
              child: Container(
                width: 75, // Ancho deseado
                height: 75, // Alto deseado
                child: const CircularProgressIndicator(
                  strokeWidth: 7, // Ancho del indicador de progreso
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: cashFlowData.length,
                itemBuilder: (context, index) {
                  final dataPoint = cashFlowData[index];
                  return ListTile(
                    title: Text(dataPoint.description),
                    subtitle: Text('\$${dataPoint.value.toStringAsFixed(0)}'),
                  );
                },
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(bottom: 10.0),
                child: ElevatedButton(
                  onPressed: () {
                    _openEntryDialog(true); // true para ingreso
                  },
                  style: ButtonStyle(
                    fixedSize: MaterialStateProperty.all(const Size(
                        150, 50)), // Ajusta el ancho y alto del botón
                  ),
                  child: const Text('Añadir Ingreso'),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 10.0),
                child: ElevatedButton(
                  onPressed: () {
                    _openEntryDialog(false); // false para egreso
                  },
                  style: ButtonStyle(
                    fixedSize: MaterialStateProperty.all(const Size(
                        150, 50)), // Ajusta el ancho y alto del botón
                  ),
                  child: const Text('Añadir Egreso'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
