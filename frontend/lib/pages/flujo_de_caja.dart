import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Dashboard(),
    );
  }
}

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class DataPoint {
  final double value;
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
  double total = 0.0;

  @override
  void initState() {
    super.initState();
    loadListFromSharedPreferences().then((loadedData) {
      setState(() {
        cashFlowData = loadedData;
        total = cashFlowData.fold(
            0, (previousValue, element) => previousValue + element.value);
      });
    });
  }

  Future<void> saveListToSharedPreferences(List<DataPoint> dataList) async {
    final prefs = await SharedPreferences.getInstance();
    final listMap = dataList.map((data) => data.toMap()).toList();
    await prefs.setStringList(
        'dataPointList', listMap.map((map) => jsonEncode(map)).toList());
  }

  Future<List<DataPoint>> loadListFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final listMap = prefs.getStringList('dataPointList') ?? [];
    return listMap.map((json) => DataPoint.fromMap(jsonDecode(json))).toList();
  }

  void _updateCashFlowAndSave(
      bool isIncome, double amount, String description) {
    if (isIncome) {
      cashFlowData.add(DataPoint(amount, description));
    } else {
      cashFlowData.add(DataPoint(-amount, description));
    }
    total = cashFlowData.fold(
        0, (previousValue, element) => previousValue + element.value);
    setState(() {});
    saveListToSharedPreferences(cashFlowData); // Guardar en SharedPreferences
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
                decoration: InputDecoration(labelText: 'Monto'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Descripción'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                // Guardar los datos en la lista cashFlowData
                final monto = double.parse(amountController.text);
                final descripcion = descriptionController.text;
                _updateCashFlowAndSave(isIncome, monto, descripcion);
                Navigator.of(context).pop();
              },
              child: Text('Guardar'),
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
        title: Text('Dashboard'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            children: <Widget>[
              Text('Flujo de Caja'),
              Text('Total: \$${total.toStringAsFixed(2)}'),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: cashFlowData.length,
              itemBuilder: (context, index) {
                final dataPoint = cashFlowData[index];
                return ListTile(
                  title: Text(dataPoint.description),
                  subtitle: Text('\$${dataPoint.value.toStringAsFixed(2)}'),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(bottom: 10.0),
                child: ElevatedButton(
                  onPressed: () {
                    _openEntryDialog(true); // true para ingreso
                  },
                  child: Text('Añadir Ingreso'),
                  style: ButtonStyle(
                    fixedSize: MaterialStateProperty.all(
                        Size(150, 50)), // Ajusta el ancho y alto del botón
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 10.0),
                child: ElevatedButton(
                  onPressed: () {
                    _openEntryDialog(false); // false para egreso
                  },
                  child: Text('Añadir Egreso'),
                  style: ButtonStyle(
                    fixedSize: MaterialStateProperty.all(
                        Size(150, 50)), // Ajusta el ancho y alto del botón
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
