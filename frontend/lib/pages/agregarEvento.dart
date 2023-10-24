import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../api_services.dart';

class AgregarEvento extends StatefulWidget {
  const AgregarEvento({Key? key}) : super(key: key);

  @override
  _AgregarEventoState createState() => _AgregarEventoState();
}

class _AgregarEventoState extends State<AgregarEvento> {
  String? dropdownValue = 'Evaluación';
  DateTime selectedDate = DateTime.now();
  final TextEditingController _dateController = TextEditingController();
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

  TimeOfDay selectedTime = TimeOfDay.now();
  final TextEditingController _timeController = TextEditingController();
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

  void _submitForm() async{
    String idCaa = '652b4e270f9658f04ee3adba';
    String fakeid = '652b4e270f9658f04ee3adb8';

    // Mapa del Caa con el nombre y total
    Map<String, dynamic> centroapi = {
      'nombre': 'Centro prueba api 2',
      'total': '0',
    };


    // ApiResponse response = await ApiService.getCaa(idCaa);

    // //Imprimo el resultado de la consulta
    // if(response.success){
    //   Map<String, dynamic> CAAInfo = response.data;
    //   print(CAAInfo);

    // }else{
    //   print(response.message);
    // }

    // ApiResponse response = await ApiService.postCaa(centroapi);

    // //Imprimo el resultado de la consulta
    // if(response.success){
    //   print(response.message);
    // }else{
    //   print(response.message);
    // }

    // Map<String, dynamic> ingreso = {
    //   'ingresos': [5000, 'prueba api']
    // };

    // ApiResponse responseI = await ApiService.postIngresoCaa( idCaa,  ingreso);

    // if (responseI.success) {
    //   print(responseI.message);
    // } else {
    //   print(responseI.message);
    // }


    // ApiResponse response = await ApiService.getIngresosCaa( idCaa );

    // if (response.success) {
    //   print(response.data);
    // } else {
    //   print(response.message);
    // }

    Map<String, dynamic> evento = {
      'categoria': 'certamen'
    };
    ApiResponse response = await ApiService.getEventosFiltrados( evento);

    if (response.success) {
      print(response.data);
    } else {
      print(response.message);
    }
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
                items: <String>['Evaluación', 'Actividad'].map((String value) {
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
                onTap: () {
                  _selectTime(context);
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Nombre ramo/actividad',
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                maxLines:
                    4, // Adjust the number of lines for the description field
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                ),
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
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Enviar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
