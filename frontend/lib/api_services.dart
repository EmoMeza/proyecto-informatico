// import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Se importa de la siguiente manera:
// import '../api_services.dart';

// ejemplo de uso:
    // Map<String, dynamic> ingreso = {
    //   'ingresos': [5000, 'prueba api']
    // };

    // ApiResponse responseP = await ApiService.postIngresoCaa( idCaa,  ingreso);

    // if (responseP.success) {
    //   print(responseP.message);
    // } else {
    //   print(responseP.message);
    // }


    // ApiResponse responseG = await ApiService.getIngresosCaa( idCaa );

    // if (responseG.success) {
    //   print(responseG.data);
    // } else {
    //   print(responseG.message);
    // }

class ApiResponse {
  final bool success;
  final dynamic data;
  final String message;

  ApiResponse(this.success, this.data, this.message);
}

class ApiService {

  // Esto se puede cambiar segun la ip del servidor o el puerto
  static const String _baseUrl = 'http://10.0.2.2:4040';

  // -----------------Centro de Alumnos-----------------------

  // Funcion para obtener un CAA
  // Parametros: id del CAA
  // Retorna: success, data, message
  static Future<ApiResponse> getCaa(String id) async{
    var url = Uri.parse('$_baseUrl/get/caa');

    // Agrega los parametros a la url
    url = url.replace(queryParameters: {
      'id': id,
    });

    //Realiza la peticion
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
      },
    );

    if(response.statusCode == 200){
      //final jsonData = json.decode(response.body);
      final responseBody = response.body;
      // Si el servidor retorna un mensaje no retorna data
      if(responseBody.startsWith('El id')){
        return ApiResponse(false, {}, responseBody);
      } else {
        // Si el servidor encuentra el id retorna data
        final jsonData = json.decode(response.body);
        return ApiResponse(true, jsonData, '');
      }
    }else{
      // Si esta respuesta no fue OK, lanza un error.
      return ApiResponse(false, {}, 'Error en la peticion');
    }
  }

  // Funcion para agregar CAA
  // Parametros: nombre caa, total dinero
  // Retorna: success, data, message
  static Future<ApiResponse> postCaa(Map<String, dynamic> postData) async{
    final url = Uri.parse('$_baseUrl/add/caa');
    final jsonBody = json.encode(postData);
    
    //Realiza la peticion
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonBody,
    );

    if(response.statusCode == 200){
      // Si el servidor devuelve una repuesta OK retorna el mensaje con success true
      final responseBody = response.body;
      return ApiResponse(true, {}, responseBody);
    } else {
      // Si esta respuesta no fue OK, lanza un error.
      return ApiResponse(false, {}, 'Error en la peticion');
    }
  }

  // Funcion para actualizar CAA
  // Parametros: id del CAA, Mapa (nombre, total)
  // Retorna: success, data, message
  static Future<ApiResponse> updateCaa(String id, Map<String, dynamic> updateData) async{
    var url = Uri.parse('$_baseUrl/update/caa');

    // Agrega los parametros a la url
    url = url.replace(queryParameters: {
      'id': id,
    });

    final jsonBody = json.encode(updateData);
    
    //Realiza la peticion
    final response = await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonBody,
    );

    if(response.statusCode == 200){
      final responseBody = response.body;
      // Si el servidor retorna un mensaje no retorna data
      if(responseBody.startsWith('El id')){
        return ApiResponse(false, {}, responseBody);
      } else {
        // Si el servidor encuentra el id retorna el mensaje
        return ApiResponse(true, {}, responseBody);
      }
    }else{
      // Si esta respuesta no fue OK, lanza un error.
      return ApiResponse(false, {}, 'Error en la peticion');
    }
  }

  // Funcion para eliminar CAA
  // Parametros: id del CAA
  // Retorna: success, data, message
  static Future<ApiResponse> deleteCaa(String id) async{
    var url = Uri.parse('$_baseUrl/delete/caa');

    // Agrega los parametros a la url
    url = url.replace(queryParameters: {
      'id': id,
    });
    
    //Realiza la peticion
    final response = await http.delete(
      url,
      headers: {
        "Content-Type": "application/json",
      },
    );

    if(response.statusCode == 200){
      final responseBody = response.body;
      // Si el servidor retorna un mensaje no retorna data
      if(responseBody.startsWith('El id')){
        return ApiResponse(false, {}, responseBody);
      } else {
        // Si el servidor encuentra el id retorna el mensaje
        return ApiResponse(true, {}, responseBody);
      }
    }else{
      // Si esta respuesta no fue OK, lanza un error.
      return ApiResponse(false, {}, 'Error en la peticion');
    }
  }

  // Funcion para obtener todos los CAA
  // Parametros: -
  // Retorna: success, data, message
  static Future<ApiResponse> getAllCaa() async{
    var url = Uri.parse('$_baseUrl/get/all/caas');

    //Realiza la peticion
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
      },
    );

    if(response.statusCode == 200){
      // Si el servidor encuentra el id retorna data
      final List<dynamic> jsonData = json.decode(response.body);
      return ApiResponse(true, jsonData, '');
    }else{
      // Si esta respuesta no fue OK, lanza un error.
      return ApiResponse(false, {}, 'Error en la peticion');
    }
  }

  // Funcion para obtener ingresos de un CAA
  // Parametros: id del CAA
  // Retorna: success, data, message
  static Future<ApiResponse> getIngresosCaa(String id) async{
    var url = Uri.parse('$_baseUrl/get/ingresos/caa');

    // Agrega los parametros a la url
    url = url.replace(queryParameters: {
      'id': id,
    });

    //Realiza la peticion
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
      },
    );

    if(response.statusCode == 200 || response.statusCode == 404){
      final responseBody = response.body;
      // Si el servidor retorna un mensaje no retorna data
      if(responseBody.startsWith('El id')){
        return ApiResponse(false, {}, responseBody);
      } else {
        // Si el servidor encuentra el id retorna los datos
        final jsonData = json.decode(response.body);
        return ApiResponse(true, jsonData, '');
      }
    }else{
      // Si esta respuesta no fue OK, lanza un error.
      return ApiResponse(false, {}, 'Error en la peticion');
    }
  }

  // Funcion para agregar ingreso a un CAA
  // Parametros: id del CAA, Mapa ([ingreso, descripcion])
  // Retorna: success, data, message
  static Future<ApiResponse> postIngresoCaa(String id, Map<String, dynamic> postData) async{
    var url = Uri.parse('$_baseUrl/add/ingreso/caa');

    // Agrega los parametros a la url
    url = url.replace(queryParameters: {
      'id': id,
    });

    final jsonBody = json.encode(postData);
    
    //Realiza la peticion
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonBody,
    );

    if(response.statusCode == 200){
      final responseBody = response.body;
      // Si el servidor retorna un mensaje no retorna data
      if(responseBody.startsWith('El id')){
        return ApiResponse(false, {}, responseBody);
      } else {
        // Si el servidor encuentra el id retorna el mensaje
        return ApiResponse(true, {}, responseBody);
      }
    }else{
      // Si esta respuesta no fue OK, lanza un error.
      return ApiResponse(false, {}, 'Error en la peticion');
    }
  }

  // Funcion para obtener los egresos de un CAA
  // Parametros: id
  // Retorna: success, data, message
  static Future<ApiResponse> getEgresosCaa(String id) async{
    var url = Uri.parse('$_baseUrl/get/egresos/caa');

    // Agrega los parametros a la url
    url = url.replace(queryParameters: {
      'id': id,
    });

    //Realiza la peticion
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
      },
    );

    if(response.statusCode == 200){
      final responseBody = response.body;
      // Si el servidor retorna un mensaje no retorna data
      if(responseBody.startsWith('El id')){
        return ApiResponse(false, {}, responseBody);
      } else {
        // Si el servidor encuentra el id retorna los datos
        final jsonData = json.decode(response.body);
        return ApiResponse(true, jsonData, '');
      }
    }else{
      // Si esta respuesta no fue OK, lanza un error.
      return ApiResponse(false, {}, 'Error en la peticion');
    }
  }

  // Funcion para agregar egreso a un CAA
  // Parametros: id del CAA, Mapa ([egreso, descripcion])
  // Retorna: success, data, message
  static Future<ApiResponse> postEgresoCaa(String id, Map<String, dynamic> postData) async{
    var url = Uri.parse('$_baseUrl/add/egreso/caa');

    // Agrega los parametros a la url
    url = url.replace(queryParameters: {
      'id': id,
    });

    final jsonBody = json.encode(postData);
    
    //Realiza la peticion
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonBody,
    );

    if(response.statusCode == 200){
      final responseBody = response.body;
      // Si el servidor retorna un mensaje no retorna data
      if(responseBody.startsWith('El id')){
        return ApiResponse(false, {}, responseBody);
      } else {
        // Si el servidor encuentra el id retorna el mensaje
        return ApiResponse(true, {}, responseBody);
      }
    }else{
      // Si esta respuesta no fue OK, lanza un error.
      return ApiResponse(false, {}, 'Error en la peticion');
    }
  }

  // Funcion para obtener el total del calculo entre 
  // ingresos y egresos de un CAA
  // Parametros: id
  // Retorna: success, data, message
  static Future<ApiResponse> getTotalCaa(String id) async{
    var url = Uri.parse('$_baseUrl/get/total/caa');

    // Agrega los parametros a la url
    url = url.replace(queryParameters: {
      'id': id,
    });

    //Realiza la peticion
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
      },
    );

    if(response.statusCode == 200){
      final responseBody = response.body;
      // Si el servidor retorna un mensaje no retorna data
      if(responseBody.startsWith('El id')){
        return ApiResponse(false, {}, responseBody);
      } else {
        // Si el servidor encuentra el id retorna el valor
        final jsonData = json.decode(response.body);
        return ApiResponse(true, jsonData, '');
      }
    }else{
      // Si esta respuesta no fue OK, lanza un error.
      return ApiResponse(false, {}, 'Error en la peticion');
    }
  }

  // -----------------Eventos-----------------------

  // Funcion para obtener un evento
  // Parametros: id
  // Retorna: success, data, message
  static Future<ApiResponse> getEvento(String id) async{
    var url = Uri.parse('$_baseUrl/get/evento');

    // Agrega los parametros a la url
    url = url.replace(queryParameters: {
      'id': id,
    });

    //Realiza la peticion
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
      },
    );

    if(response.statusCode == 200){
      final responseBody = response.body;
      // Si el servidor retorna un mensaje no retorna data
      if(responseBody.startsWith('El id')){
        return ApiResponse(false, {}, responseBody);
      } else {
        // Si el servidor encuentra el id retorna el valor
        final jsonData = json.decode(response.body);
        return ApiResponse(true, jsonData, '');
      }
    }else{
      // Si esta respuesta no fue OK, lanza un error.
      return ApiResponse(false, {}, 'Error en la peticion');
    }
  }

  // Funcion para agregar un evento
  // Parametros: Map<String, dynamic> postData
  // Retorna: success, data, message
  static Future<ApiResponse> postEvento(Map<String, dynamic> postData) async{
    final url = Uri.parse('$_baseUrl/add/evento');
    final jsonBody = json.encode(postData);
    
    //Realiza la peticion
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonBody,
    );

    if(response.statusCode == 200){
      final responseBody = response.body;
      return ApiResponse(true, {}, responseBody);
    }else{
      // Si esta respuesta no fue OK, lanza un error.
      return ApiResponse(false, {}, 'Error en la peticion');
    }
  }

  // Funcion para actualizar un evento
  // Parametros: id, Map<String, dynamic> updateData
  // Retorna: success, data, message 
  static Future<ApiResponse> updateEvento(String id, Map<String, dynamic> updateData) async{
    var url = Uri.parse('$_baseUrl/update/evento');

    // Agrega los parametros a la url
    url = url.replace(queryParameters: {
      'id': id,
    });

    final jsonBody = json.encode(updateData);
    
    //Realiza la peticion
    final response = await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonBody,
    );

    if(response.statusCode == 200){
      final responseBody = response.body;
      // Si el servidor retorna un mensaje no retorna data
      if(responseBody.startsWith('El id')){
        return ApiResponse(false, {}, responseBody);
      } else {
        // Si el servidor encuentra el id retorna el mensaje
        return ApiResponse(true, {}, responseBody);
      }
    }else{
      // Si esta respuesta no fue OK, lanza un error.
      return ApiResponse(false, {}, 'Error en la peticion');
    }
  }

  // Funcion para eliminar un evento
  // Parametros: id
  // Retorna: success, data, message 
  static Future<ApiResponse> deleteEvento(String id) async{
    var url = Uri.parse('$_baseUrl/delete/evento');

    // Agrega los parametros a la url
    url = url.replace(queryParameters: {
      'id': id,
    });
    
    //Realiza la peticion
    final response = await http.delete(
      url,
      headers: {
        "Content-Type": "application/json",
      },
    );

    if(response.statusCode == 200){
      final responseBody = response.body;
      // Si el servidor retorna un mensaje no retorna data
      if(responseBody.startsWith('El id')){
        return ApiResponse(false, {}, responseBody);
      } else {
        // Si el servidor encuentra el id retorna el mensaje
        return ApiResponse(true, {}, responseBody);
      }
    }else{
      // Si esta respuesta no fue OK, lanza un error.
      return ApiResponse(false, {}, 'Error en la peticion');
    }
  }

  // Funcion para obtener todos los eventos
  // Parametros: -
  // Retorna: success, data, message
  static Future<ApiResponse> getAllEventos() async{
    var url = Uri.parse('$_baseUrl/get/all/eventos');

    //Realiza la peticion
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
      },
    );

    if(response.statusCode == 200){
      final responseBody = response.body;
      // Si el servidor retorna un mensaje no retorna data
      if(responseBody.startsWith('No hay eventos')){
        return ApiResponse(false, {}, responseBody);
      } else {
        // Si el servidor encuentra el id retorna los datos
        final List<dynamic> jsonData = json.decode(response.body);
        return ApiResponse(true, jsonData, '');
      }
    }else{
      // Si esta respuesta no fue OK, lanza un error.
      return ApiResponse(false, {}, 'Error en la peticion');
    }
  }

  // Funcion para obtener los eventos segun un filtro
  // Parametros: Map<String, dynamic> filterData
  // Retorna: success, data, message
  static Future<ApiResponse> getEventosFiltrados(Map<String, dynamic> filterData) async{
    var url = Uri.parse('$_baseUrl/get/filter/eventos');

    // Agrega los parametros a la url
    url = url.replace(queryParameters: filterData);

    //Realiza la peticion
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
      },
    );
    
    if(response.statusCode == 200){
      final responseBody = response.body;
      // Si el servidor retorna un mensaje no retorna data
      if(responseBody.startsWith('No hay eventos')){
        return ApiResponse(false, {}, responseBody);
      } else {
        // Si el servidor encuentra el id retorna los datos
        final List<dynamic> jsonData = json.decode(response.body);
        return ApiResponse(true, jsonData, '');
      }
    }else{
      // Si esta respuesta no fue OK, lanza un error.
      return ApiResponse(false, {}, 'Error en la peticion'); 
    }
  }

  // -----------------Alumnos-----------------------

  // Función para añadir un alumno
  // Parametros: nombre, matricula, Map<String, dynamic> data
  // Retorna: success, data, message 
  static Future<ApiResponse> postAlumno(String nombre, String apellido, String matricula, Map<String, dynamic> data) async {
    // Unify the data into a single object
    data['nombre'] = nombre;
    data['apellido'] = apellido;
    data['matricula'] = matricula;

    // Check if the matricula has at least 4 digits
    if (matricula.length < 4) {
      return ApiResponse(false, {}, 'La matricula $matricula no tiene el mínimo de 4 dígitos');
    }

    // password = 4 primeros digitos de la matricula + 2 primeras letras del nombre + 2 primeras letras del apellido
    final password = matricula.substring(0, 4) + nombre.toLowerCase().substring(0,2) + apellido.toLowerCase().substring(0,2);
    data['contraseña'] = password;

    final url = Uri.parse('$_baseUrl/add/alumno?nombre=$nombre&matricula=$matricula&apellido=$apellido');
    final jsonBody = json.encode(data);

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonBody,
      );

      if (response.statusCode == 200) {
        final responseBody = response.body;
        // Ya existe el alumno en la bdd
        if (responseBody.startsWith('El alumno')) {
          return ApiResponse(false, {}, responseBody);
        } else {
          return ApiResponse(true, {}, 'Se ha insertado correctamente');
        }
      } else {
        return ApiResponse(false, {}, 'Error en el servidor');
      }
    } catch (error) {
      return ApiResponse(false, {}, 'Error en la petición: $error');
    }
  }

  // Funcion para obtener un alumno
  // Parametros: matricula
  // Retorna: success, data, message 
  static Future<ApiResponse> getAlumno(String matricula) async{
    var url = Uri.parse('$_baseUrl/get/alumno');

    // Agrega los parametros a la url
    url = url.replace(queryParameters: {
      'matricula': matricula,
    });

    //Realiza la peticion
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
      },
    );
    
    if(response.statusCode == 200){
      final responseBody = response.body;
      // Si el servidor retorna un mensaje no retorna data
      if(responseBody.startsWith('El alumno')){
        return ApiResponse(false, {}, responseBody);
      } else {
        // Si el servidor encuentra el id retorna el mensaje
        final jsonData = json.decode(response.body);
        return ApiResponse(true, jsonData, '');
      }
    }else{
      // Si esta respuesta no fue OK, lanza un error.
      return ApiResponse(false, {}, 'Error en la peticion');
    }
  }

  // Funcion para actualizar un alumno
  // Parametros: matricula, Map<String, dynamic> updateData
  // Retorna: success, data, message 
  static Future<ApiResponse> updateAlumno(String matricula, Map<String, dynamic> updateData) async{
    var url = Uri.parse('$_baseUrl/update/alumno');

    // Agrega los parametros a la url
    url = url.replace(queryParameters: {
      'matricula': matricula,
    });

    final jsonBody = json.encode(updateData);
    
    //Realiza la peticion
    final response = await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonBody,
    );
    
    if(response.statusCode == 200){
      final responseBody = response.body;
      // Si el servidor retorna un mensaje no retorna data
      if(responseBody.startsWith('El alumno')){
        return ApiResponse(false, {}, responseBody);
      } else {
        // Si el servidor encuentra el id retorna el mensaje
        return ApiResponse(true, {}, responseBody);
      }
    }else{
      // Si esta respuesta no fue OK, lanza un error.
      return ApiResponse(false, {}, 'Error en la peticion');
    }
  }

  // Funcion para eliminar un alumno
  // Parametros: matricula
  // Retorna: success, data, message 
  static Future<ApiResponse> deleteAlumno(String matricula) async{
    var url = Uri.parse('$_baseUrl/delete/alumno');

    // Agrega los parametros a la url
    url = url.replace(queryParameters: {
      'matricula': matricula,
    });
    
    //Realiza la peticion
    final response = await http.delete(
      url,
      headers: {
        "Content-Type": "application/json",
      },
    );
    
    if(response.statusCode == 200){
      final responseBody = response.body;
      // Si el servidor retorna un mensaje no retorna data
      if(responseBody.startsWith('El alumno')){
        return ApiResponse(false, {}, responseBody);
      } else {
        // Si el servidor encuentra el id retorna el mensaje
        return ApiResponse(true, {}, responseBody);
      }
    }else{
      // Si esta respuesta no fue OK, lanza un error.
      return ApiResponse(false, {}, 'Error en la peticion');
    }
  }

  // -----------------Mas Eventos-----------------------

  // Funcion para obtener la suma de ingresos totales 
  // de un evento
  // Parametros: id evento
  // Retorna: success, data, message
  static Future<ApiResponse> getIngresosEvento(String id) async{
    var url = Uri.parse('$_baseUrl/get/all/ingresos');

    // Agrega los parametros a la url
    url = url.replace(queryParameters: {
      'id': id,
    });

    //Realiza la peticion
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
      },
    );
    
    if(response.statusCode == 200){
      final responseBody = response.body;
      // Si el servidor retorna un mensaje no retorna data
      if(responseBody.startsWith('El evento')){
        return ApiResponse(false, {}, responseBody);
      } else {
        // Si el servidor encuentra el id retorna el mensaje
        final jsonData = json.decode(response.body);
        return ApiResponse(true, jsonData, '');
      }
    }else{
      // Si esta respuesta no fue OK, lanza un error.
      return ApiResponse(false, {}, 'Error en la peticion');
    }
  }

  // Funcion para añadir un ingreso a un evento
  // Parametros: id evento, Map<String, dynamic> postData
  // Retorna: success, data, message 
  static Future<ApiResponse> postIngresoEvento(String id, Map<String, dynamic> postData) async{
    var url = Uri.parse('$_baseUrl/add/ingreso');

    // Agrega los parametros a la url
    url = url.replace(queryParameters: {
      'id': id,
    });

    final jsonBody = json.encode(postData);
    
    //Realiza la peticion
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonBody,
    );
    
    if(response.statusCode == 200){
      final responseBody = response.body;
      // Si el servidor retorna un mensaje no retorna data
      if(responseBody.startsWith('El id')){
        return ApiResponse(false, {}, responseBody);
      } else {
        // Si el servidor encuentra el id retorna el mensaje
        return ApiResponse(true, {}, responseBody);
      }
    }else{
      // Si esta respuesta no fue OK, lanza un error.
      return ApiResponse(false, {}, 'Error en la peticion');
    }
  }

  // Funcion para obtener la suma de egresos totales
  // de un evento
  // Parametros: id evento
  // Retorna: success, data, message
  static Future<ApiResponse> getEgresosEvento(String id) async{
    var url = Uri.parse('$_baseUrl/get/all/egresos');

    // Agrega los parametros a la url
    url = url.replace(queryParameters: {
      'id': id,
    });

    //Realiza la peticion
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
      },
    );
    
    if(response.statusCode == 200){
      final responseBody = response.body;
      // Si el servidor retorna un mensaje no retorna data
      if(responseBody.startsWith('El evento')){
        return ApiResponse(false, {}, responseBody);
      } else {
        // Si el servidor encuentra el id retorna el mensaje
        final jsonData = json.decode(response.body);
        return ApiResponse(true, jsonData, '');
      }
    }else{
      // Si esta respuesta no fue OK, lanza un error.
      return ApiResponse(false, {}, 'Error en la peticion');
    }
  }

  // Funcion para añadir un egreso a un evento
  // Parametros: id, Map<String, dynamic> postData
  // Retorna: success, data, message 
  static Future<ApiResponse> postEgresoEvento(String id, Map<String, dynamic> postData) async{
    var url = Uri.parse('$_baseUrl/add/egreso');

    // Agrega los parametros a la url
    url = url.replace(queryParameters: {
      'id': id,
    });

    final jsonBody = json.encode(postData);
    
    //Realiza la peticion
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonBody,
    );
    
    if(response.statusCode == 200){
      final responseBody = response.body;
      // Si el servidor retorna un mensaje no retorna data
      if(responseBody.startsWith('El id')){
        return ApiResponse(false, {}, responseBody);
      } else {
        // Si el servidor encuentra el id retorna el mensaje
        return ApiResponse(true, {}, responseBody);
      }
    }else{
      // Si esta respuesta no fue OK, lanza un error.
      return ApiResponse(false, {}, 'Error en la peticion');
    }
  }

  // Funcion para obtener el total del calculo entre
  // ingresos y egresos de un evento
  // Parametros: id evento
  // Retorna: success, data, message
  static Future<ApiResponse> getTotalEvento(String id) async{
    var url = Uri.parse('$_baseUrl/get/total');

    // Agrega los parametros a la url
    url = url.replace(queryParameters: {
      'id': id,
    });

    //Realiza la peticion
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
      },
    );
    
    if(response.statusCode == 200){
      final responseBody = response.body;
      // Si el servidor retorna un mensaje no retorna data
      if(responseBody.startsWith('El evento')){
        return ApiResponse(false, {}, responseBody);
      } else {
        // Si el servidor encuentra el id retorna el mensaje
        final jsonData = json.decode(response.body);
        return ApiResponse(true, jsonData, '');
      }
    }else{
      // Si esta respuesta no fue OK, lanza un error.
      return ApiResponse(false, {}, 'Error en la peticion');
    }
  }

  // Funcion para obtener todas las asistencias de un evento
  // Parametros: id evento
  // Retorna: success, data, message
  static Future<ApiResponse> getAsistenciasEvento(String id) async{
    var url = Uri.parse('$_baseUrl/get/all/asistencias');

    // Agrega los parametros a la url
    url = url.replace(queryParameters: {
      'id': id,
    });

    //Realiza la peticion
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
      },
    );
    
    if(response.statusCode == 200){
      final responseBody = response.body;
      // Si el servidor retorna un mensaje no retorna data
      if(responseBody.startsWith('El id')){
        return ApiResponse(false, {}, responseBody);
      } else {
        // Si el servidor encuentra el id retorna el mensaje
        final jsonData = json.decode(response.body);
        return ApiResponse(true, jsonData, '');
      }
    }else{
      // Si esta respuesta no fue OK, lanza un error.
      return ApiResponse(false, {}, 'Error en la peticion');
    }
  }

  // Funcion para agregar una asistencia a un evento
  // Parametros: id, matricula
  // Retorna: success, data, message 
  static Future<ApiResponse> postAsistenciaEvento(String id, String matricula) async{
    var url = Uri.parse('$_baseUrl/add/asistencia');

    // Agrega los parametros a la url
    url = url.replace(queryParameters: {
      'id': id,
      'matricula': matricula,
    });

    //Realiza la peticion
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
    );
    
    if(response.statusCode == 200){
      final responseBody = response.body;
      // Si el servidor retorna un mensaje no retorna data
      if(responseBody.startsWith('El id') || responseBody.startsWith('El alumno')){
        return ApiResponse(false, {}, responseBody);
      } else {
        // Si el servidor encuentra el id retorna el mensaje
        return ApiResponse(true, {}, responseBody);
      }
    }else{
      // Si esta respuesta no fue OK, lanza un error.
      return ApiResponse(false, {}, 'Error en la peticion');
    }
  }
}