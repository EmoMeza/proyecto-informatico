import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_services.dart';

class AgregarEvento extends StatefulWidget {
  const AgregarEvento({Key? key}) : super(key: key);

  @override
  _AgregarEventoState createState() => _AgregarEventoState();
}

class _AgregarEventoState extends State<AgregarEvento> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? dropdownValue = 'Evaluación';
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
      });
    }
  }

  String formatDateTime(DateTime date, TimeOfDay time) {
    //formato de fecha y hora para enviar a la API
    final DateTime combined =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);
    final String formattedDate =
        DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(combined);
    return formattedDate;
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
        _timeController.text = selectedTime.format(context);
      });
    }
  }

  String? _validateFecha(DateTime? date) {
    if (date == null) {
      return 'Please select a date';
    }
    return null;
  }

  String? _validateHora(TimeOfDay? time) {
    if (time == null) {
      return 'Please select a time';
    }
    return null;
  }

  String? _validateField(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Porfavor ingresar $fieldName';
    }
    return null;
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      print(formatDateTime(selectedDate, selectedTime));
      Map<String, dynamic> postData = {
        'nombre': _nombreController.text,
        'categoria': dropdownValue,
        'descripcion': _descripcionController.text,
        'fecha_inicio': formatDateTime(selectedDate, selectedTime),
        'fecha_final': formatDateTime(
            selectedDate, selectedTime), // Assuming the same start and end time
        'ingresos': [],
        'egresos': [],
        'total': 0,
        'id_caa': "652976834af6fedf26f3493d", //idk how to get this
        'visible': false,
        'asistencia': []
      };

      ApiResponse response = await ApiService.postEvento(postData);
      if (response.success) {
        print('Form submitted!');
        print(response.message);
        showDialog(
          //alerta de que se envio el formulario
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Form Submitted"),
              content: Text(
                  response.message), // Display the message from the response
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    // Navigate to another page
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else {
        print('Error in the request: ${response.message}');
      }
    }
  }

  ElevatedButton buildSubmitButton() {
    return ElevatedButton(
      onPressed: _submitForm,
      child: const Text('Agregar Evento'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Evento'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                DropdownButton<String>(
                  value: dropdownValue,
                  onChanged: (String? newValue) {
                    setState(() {
                      dropdownValue = newValue;
                    });
                  },
                  items:
                      <String>['Evaluación', 'Actividad'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Fecha',
                    suffixIcon: IconButton(
                      onPressed: () => _selectDate(context),
                      icon: const Icon(Icons.calendar_today),
                    ),
                  ),
                  validator: (value) => _validateFecha(selectedDate),
                  onTap: () {
                    _selectDate(context);
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _timeController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Hora',
                    suffixIcon: IconButton(
                      onPressed: () => _selectTime(context),
                      icon: const Icon(Icons.access_time),
                    ),
                  ),
                  validator: (value) => _validateHora(selectedTime),
                  onTap: () {
                    _selectTime(context);
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre ramo/actividad',
                  ),
                  validator: (value) =>
                      _validateField(value, 'Nombre ramo/actividad'),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  maxLines:
                      4, // Adjust the number of lines for the description field
                  controller: _descripcionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                  ),
                  validator: (value) => _validateField(value, 'Descripción'),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Entidad Encargada',
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Sala/lugar',
                  ),
                ),
                const SizedBox(height: 20),
                buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
