import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../api_services.dart';

class AgregarEvento extends StatefulWidget {
  const AgregarEvento({Key? key}) : super(key: key);

  @override
  _AgregarEventoState createState() => _AgregarEventoState();
}

class _AgregarEventoState extends State<AgregarEvento> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? dropdownValue = 'Evaluación';
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  DateTime selectedEndDate = DateTime.now();
  TimeOfDay selectedEndTime = TimeOfDay.now();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  Future<void> _selectDate(BuildContext context) async {
    //seleccionar fecha inicial
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

  Future<void> _selectTime(BuildContext context) async {
    //seleccionar hora inicio
    final TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
        _timeController.text = selectedTime.format(context);
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    //seleccionar fecha final
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedEndDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedEndDate) {
      setState(() {
        selectedEndDate = picked;
        _endDateController.text =
            DateFormat('yyyy-MM-dd').format(selectedEndDate);
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    //Seleccionar hora fin
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedEndTime,
    );
    if (picked != null && picked != selectedEndTime) {
      setState(() {
        selectedEndTime = picked;
        _endTimeController.text = selectedEndTime.format(context);
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

  String? _validateFecha(DateTime? date) {
    //validar seleccion de fecha
    if (date == null) {
      return 'Seleccione una fecha inicial';
    }
    return null;
  }

  String? _validateHora(TimeOfDay? time) {
    //validar hora inicial
    if (time == null) {
      return 'Seleccione una hora inicial';
    }
    return null;
  }

  String? _validateEndDate(DateTime? date) {
    //validar fecha final
    if (date == null) {
      return 'Seleccione una fecha final';
    }
    if (date.isBefore(selectedDate)) {
      return 'Fecha final no puede ser antes de la fecha inicial';
    }
    return null;
  }

  String? _validateEndTime(TimeOfDay? time) {
    //validar hora final
    if (time == null) {
      return 'Seleccione una hora final';
    }

    final DateTime selectedDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute);
    final DateTime selectedEndDateTime = DateTime(
        selectedEndDate.year,
        selectedEndDate.month,
        selectedEndDate.day,
        selectedEndTime.hour,
        selectedEndTime.minute);

    if (selectedDateTime.isAfter(selectedEndDateTime) &&
        selectedDate == selectedEndDate) {
      return 'Hora final no puede ser antes de la hora inicial';
    }
    return null;
  }

  String? _validateField(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Porfavor ingresar $fieldName';
    }
    return null;
  }

  void showResponseDialog(BuildContext context, String message, bool success) {
    //Popup de error/exito al enviar evento
    String title = success ? "Evento agregado" : "Error:";
    showDialog(
      // Alerta de respuesta de la API
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(message), // Mensage de la respuesta
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                // Cierra el dialogo
                Navigator.of(dialogContext).pop();
                if (success) {
                  //Cierra la pagina si se envio el formulario
                  Navigator.of(dialogContext).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _submitForm(BuildContext context) async {
    //controlador para enviar datos a la API
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> postData = {
        'nombre': _nombreController.text,
        'categoria': dropdownValue,
        'descripcion': _descripcionController.text,
        'fecha_inicio': formatDateTime(selectedDate, selectedTime),
        'fecha_final': formatDateTime(selectedEndDate, selectedEndTime),
        'ingresos': [],
        'egresos': [],
        'total': 0,
        'id_caa': "652976834af6fedf26f3493d", //idk how to get this
        'visible': false,
        'asistencia': []
      };

      ApiResponse response = await ApiService.postEvento(postData);
      if (response.success) {
        showResponseDialog(context, response.message, response.success);
      } else {
        showResponseDialog(context, response.message, response.success);
      }
    }
  }

  ElevatedButton buildSubmitButton() {
    // boton de enviar
    return ElevatedButton(
      onPressed: () {
        _submitForm(context);
      },
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
                if (dropdownValue == 'Actividad')
                  Column(
                    children: [
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _endDateController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Fecha Final',
                          suffixIcon: IconButton(
                            onPressed: () => _selectEndDate(context),
                            icon: const Icon(Icons.calendar_today),
                          ),
                        ),
                        validator: (value) => _validateEndDate(selectedEndDate),
                        onTap: () {
                          _selectEndDate(context);
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _endTimeController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Hora Final',
                          suffixIcon: IconButton(
                            onPressed: () => _selectEndTime(context),
                            icon: const Icon(Icons.access_time),
                          ),
                        ),
                        validator: (value) => _validateEndTime(selectedEndTime),
                        onTap: () {
                          _selectEndTime(context);
                        },
                      ),
                    ],
                  ),
                const SizedBox(height: 20),
                if (dropdownValue == 'Evaluación')
                  TextFormField(
                    controller: _endTimeController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Hora Final',
                      suffixIcon: IconButton(
                        onPressed: () => _selectEndTime(context),
                        icon: const Icon(Icons.access_time),
                      ),
                    ),
                    validator: (value) => _validateEndTime(selectedEndTime),
                    onTap: () {
                      _selectEndTime(context);
                    },
                  ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre ramo/actividad',
                  ),
                  maxLength: 50, // Limite de 50 caracteres
                  validator: (value) =>
                      _validateField(value, 'Nombre ramo/actividad'),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  maxLines: 6, // Numero de lineas para la descripcion
                  controller: _descripcionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                  ),
                  validator: (value) => _validateField(value, 'Descripción'),
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
