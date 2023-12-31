// import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

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
  static Future<ApiResponse> getCaa(String id) async {
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

    if (response.statusCode == 200) {
      //final jsonData = json.decode(response.body);
      final responseBody = response.body;
      // Si el servidor retorna un mensaje no retorna data
      if (responseBody.startsWith('El id')) {
        return ApiResponse(false, {}, responseBody);
      } else {
        // Si el servidor encuentra el id retorna data
        final jsonData = json.decode(response.body);
        return ApiResponse(true, jsonData, '');
      }
    } else {
      // Si esta respuesta no fue OK, lanza un error.
      return ApiResponse(false, {}, 'Error en la peticion');
    }
  }

  // Funcion para agregar CAA
  // Parametros: nombre caa, total dinero
  // Retorna: success, data, message
  static Future<ApiResponse> postCaa(Map<String, dynamic> postData) async {
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

    if (response.statusCode == 200) {
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
  static Future<ApiResponse> updateCaa(
      String id, Map<String, dynamic> updateData) async {
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

    if (response.statusCode == 200) {
      final responseBody = response.body;
      // Si el servidor retorna un mensaje no retorna data
      if (responseBody.startsWith('El id')) {
        return ApiResponse(false, {}, responseBody);
      } else {
        // Si el servidor encuentra el id retorna el mensaje
        return ApiResponse(true, {}, responseBody);
      }
    } else {
      // Si esta respuesta no fue OK, lanza un error.
      return ApiResponse(false, {}, 'Error en la peticion');
    }
  }

  // Funcion para eliminar CAA
  // Parametros: id del CAA
  // Retorna: success, data, message
  static Future<ApiResponse> deleteCaa(String id) async {
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

    if (response.statusCode == 200) {
      final responseBody = response.body;
      // Si el servidor retorna un mensaje no retorna data
      if (responseBody.startsWith('El id')) {
        return ApiResponse(false, {}, responseBody);
      } else {
        // Si el servidor encuentra el id retorna el mensaje
        return ApiResponse(true, {}, responseBody);
      }
    } else {
      // Si esta respuesta no fue OK, lanza un error.
      return ApiResponse(false, {}, 'Error en la peticion');
    }
  }

  // Funcion para obtener todos los CAA
  // Parametros: -
  // Retorna: success, data, message
  static Future<ApiResponse> getAllCaa() async {
    var url = Uri.parse('$_baseUrl/get/all/caas');

    //Realiza la peticion
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      // Si el servidor encuentra el id retorna data
      final List<dynamic> jsonData = json.decode(response.body);
      return ApiResponse(true, jsonData, '');
    } else {
      // Si esta respuesta no fue OK, lanza un error.
      return ApiResponse(false, {}, 'Error en la peticion');
    }
  }

  // Funcion para obtener ingresos de un CAA
  // Parametros: id del CAA
  // Retorna: success, data, message
  static Future<ApiResponse> getIngresosCaa(String id) async {
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

    if (response.statusCode == 200 || response.statusCode == 404) {
      final responseBody = response.body;
      // Si el servidor retorna un mensaje no retorna data
      if (responseBody.startsWith('El id')) {
        return ApiResponse(false, {}, responseBody);
      } else {
        // Si el servidor encuentra el id retorna los datos
        final jsonData = json.decode(response.body);
        return ApiResponse(true, jsonData, '');
      }
    } else {
      // Si esta respuesta no fue OK, lanza un error.
      return ApiResponse(false, {}, 'Error en la peticion');
    }
  }

  // Funcion para agregar ingreso a un CAA
  // Parametros: id del CAA, Mapa ([ingreso, descripcion])
  // Retorna: success, data, message
  static Future<ApiResponse> postIngresoCaa(
      String id, Map<String, dynamic> postData) async {
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

    if (response.statusCode == 200) {
      final responseBody = response.body;
      // Si el servidor retorna un mensaje no retorna data
      if (responseBody.startsWith('El id')) {
        return ApiResponse(false, {}, responseBody);
      } else {
        // Si el servidor encuentra el id retorna el mensaje
        return ApiResponse(true, {}, responseBody);
      }
    } else {
      // Si esta respuesta no fue OK, lanza un error.
      return ApiResponse(false, {}, 'Error en la peticion');
    }
  }

  // Funcion para obtener los egresos de un CAA
  // Parametros: id
  // Retorna: success, data, message
  static Future<ApiResponse> getEgresosCaa(String id) async {
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

    if (response.statusCode == 200) {
      final responseBody = response.body;
      // Si el servidor retorna un mensaje no retorna data
      if (responseBody.startsWith('El id')) {
        return ApiResponse(false, {}, responseBody);
      } else {
        // Si el servidor encuentra el id retorna los datos
        final jsonData = json.decode(response.body);
        return ApiResponse(true, jsonData, '');
      }
    } else {
      // Si esta respuesta no fue OK, lanza un error.
      return ApiResponse(false, {}, 'Error en la peticion');
    }
  }

  // Funcion para agregar egreso a un CAA
  // Parametros: id del CAA, Mapa ([egreso, descripcion])
  // Retorna: success, data, message
  static Future<ApiResponse> postEgresoCaa(
      String id, Map<String, dynamic> postData) async {
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

    if (response.statusCode == 200) {
      final responseBody = response.body;
      // Si el servidor retorna un mensaje no retorna data
      if (responseBody.startsWith('El id')) {
        return ApiResponse(false, {}, responseBody);
      } else {
        // Si el servidor encuentra el id retorna el mensaje
        return ApiResponse(true, {}, responseBody);
      }
    } else {
      // Si esta respuesta no fue OK, lanza un error.
      return ApiResponse(false, {}, 'Error en la peticion');
    }
  }

  // Funcion para obtener el total del calculo entre
  // ingresos y egresos de un CAA
  // Parametros: id
  // Retorna: success, data, message
  static Future<ApiResponse> getTotalCaa(String id) async {
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

    if (response.statusCode == 200) {
      final responseBody = response.body;
      // Si el servidor retorna un mensaje no retorna data
      if (responseBody.startsWith('El id')) {
        return ApiResponse(false, {}, responseBody);
      } else {
        // Si el servidor encuentra el id retorna el valor
        final jsonData = json.decode(response.body);
        return ApiResponse(true, jsonData, '');
      }
    } else {
      // Si esta respuesta no fue OK, lanza un error.
      return ApiResponse(false, {}, 'Error en la peticion');
    }
  }

  // -----------------Eventos-----------------------

  // Funcion para obtener un evento
  // Parametros: id
  // Retorna: success, data, message
  static Future<ApiResponse> getEvento(String id) async {
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

    if (response.statusCode == 200) {
      final responseBody = response.body;
      // Si el servidor retorna un mensaje no retorna data
      if (responseBody.startsWith('El id')) {
        return ApiResponse(false, {}, responseBody);
      } else {
        // Si el servidor encuentra el id retorna el valor
        final jsonData = json.decode(response.body);
        return ApiResponse(true, jsonData, '');
      }
    } else {
      // Si esta respuesta no fue OK, lanza un error.
      return ApiResponse(false, {}, 'Error en la peticion');
    }
  }

  // Funcion para agregar un evento
  // Parametros: Map<String, dynamic> postData
  // Retorna: success, data, message
  static Future<ApiResponse> postEvento(
      String idCreador, Map<String, dynamic> postData) async {
    final baseUrl = Uri.parse('$_baseUrl/add/evento');

    // Agrega los parametros a la url
    final url = baseUrl.replace(queryParameters: {
      'id_creador': idCreador,
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

    if (response.statusCode == 200) {
      final responseBody = response.body;
      return ApiResponse(true, {}, responseBody);
    } else {
      // Si esta respuesta no fue OK, lanza un error.
      return ApiResponse(false, {}, 'Error en la peticion');
    }
  }

  // Funcion para actualizar un evento
  // Parametros: id, Map<String, dynamic> updateData
  // Retorna: success, data, message
  static Future<ApiResponse> updateEvento(
      String id, Map<String, dynamic> updateData) async {
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

    if (response.statusCode == 200) {
      final responseBody = response.body;
      // Si el servidor retorna un mensaje no retorna data
      if (responseBody.startsWith('El id')) {
        return ApiResponse(false, {}, responseBody);
      } else {
        // Si el servidor encuentra el id retorna el mensaje
        return ApiResponse(true, {}, responseBody);
      }
    } else {
      // Si esta respuesta no fue OK, lanza un error.
      return ApiResponse(false, {}, 'Error en la peticion');
    }
  }

  // Funcion para eliminar un evento
  // Parametros: id
  // Retorna: success, data, message
  static Future<ApiResponse> deleteEvento(String id) async {
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

    if (response.statusCode == 200) {
      final responseBody = response.body;
      // Si el servidor retorna un mensaje no retorna data
      if (responseBody.startsWith('El id')) {
        return ApiResponse(false, {}, responseBody);
      } else {
        // Si el servidor encuentra el id retorna el mensaje
        return ApiResponse(true, {}, responseBody);
      }
    } else {
      // Si esta respuesta no fue OK, lanza un error.
      return ApiResponse(false, {}, 'Error en la peticion');
    }
  }

  // Funcion para obtener todos los eventos
  // Parametros: -
  // Retorna: success, data, message
  static Future<ApiResponse> getAllEventos() async {
    var url = Uri.parse('$_baseUrl/get/all/eventos');

    //Realiza la peticion
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final responseBody = response.body;
      // Si el servidor retorna un mensaje no retorna data
      if (responseBody.startsWith('No hay eventos')) {
        return ApiResponse(false, {}, responseBody);
      } else {
        // Si el servidor encuentra el id retorna los datos
        final List<dynamic> jsonData = json.decode(response.body);
        return ApiResponse(true, jsonData, '');
      }
    } else {
      // Si esta respuesta no fue OK, lanza un error.
      return ApiResponse(false, {}, 'Error en la peticion');
    }
  }

  // Funcion para obtener los eventos segun un filtro
  // Parametros: Map<String, dynamic> filterData
  // Retorna: success, data, message
  static Future<ApiResponse> getEventosFiltrados(
      Map<String, dynamic> filterData) async {
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

    if (response.statusCode == 200) {
      final responseBody = response.body;
      // Si el servidor retorna un mensaje no retorna data
      if (responseBody.startsWith('No se encontraron')) {
        return ApiResponse(false, {}, responseBody);
      } else {
        // Si el servidor encuentra el id retorna los datos
        final List<dynamic> jsonData = json.decode(response.body);
        return ApiResponse(true, jsonData, '');
      }
    } else {
      // Si esta respuesta no fue OK, lanza un error.
      return ApiResponse(false, {}, 'Error en la peticion');
    }
  }

  // -----------------Alumnos-----------------------

  // Función para añadir un alumno
  // Parametros: nombre, matricula, Map<String, dynamic> data
  // Retorna: success, data, message
  static Future<ApiResponse> postAlumno(String nombre, String apellido, int matricula, bool esCaa, String idCaa, Map<String, dynamic> postData) async {   
    final url = Uri.parse('$_baseUrl/add/alumno').replace(queryParameters: {
      'nombre': nombre,
      'apellido': apellido,
      'matricula': matricula.toString(),
      'es_caa': esCaa.toString(),
      'id_caa': idCaa,
    });

    final jsonBody = json.encode(postData);

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonBody,
    );

    if(response.statusCode == 200) {
      if (response.body == 'El alumno $matricula ya existe en la base de datos') {
        return ApiResponse(false, {}, 'El alumno $matricula ya existe en la base de datos');
      } else if (response.body == 'La matricula $matricula no tiene el minimo de 4 digitos') {
        return ApiResponse(false, {}, 'La matricula no tiene el minimo de 4 digitos');
      }
      return ApiResponse(true, {}, response.body);
    } else {
      return ApiResponse(false, {}, 'Error en la peticion');
    }
  }

  // Funcion para obtener un alumno
  // Parametros: matricula
  // Retorna: success, data, message
  static Future<ApiResponse> getAlumno(String matricula) async {
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

    if (response.statusCode == 200) {
      final responseBody = response.body;
      // Si el servidor retorna un mensaje no retorna data
      if (responseBody.startsWith('El alumno')) {
        return ApiResponse(false, {}, responseBody);
      } else {
        // Si el servidor encuentra el id retorna el mensaje
        final jsonData = json.decode(response.body);
        return ApiResponse(true, jsonData, '');
      }
    } else {
      // Si esta respuesta no fue OK, lanza un error.
      return ApiResponse(false, {}, 'Error en la peticion');
    }
  }

  //funcion para filtrar alumnos 
  static Future<ApiResponse> getAlumnosFiltrados(Map<String, dynamic> filterData) async {
    var url = Uri.parse('$_baseUrl/get/filter/alumnos');

    // Add parameters to the URL
    url = url.replace(queryParameters: filterData);

    try {
      // Make the request
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final responseBody = response.body;
        // If the server returns a message without data
        if (responseBody.startsWith('No se encontraron')) {
          return ApiResponse(false, {}, responseBody);
        } else {
          // If the server finds students, return the data
          final List<dynamic> jsonData = json.decode(response.body);
          return ApiResponse(true, jsonData, '');
        }
      } else {
        // If the response is not OK, throw an error.
        return ApiResponse(false, {}, 'Error en la peticion');
      }
    } catch (error) {
      // Handle errors
      return ApiResponse(false, {}, 'Error en el servidor');
    }
}
  // Funcion para actualizar un alumno
  // Parametros: matricula, Map<String, dynamic> updateData
  // Retorna: success, data, message
  static Future<ApiResponse> updateAlumno(
      String matricula, Map<String, dynamic> updateData) async {
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

    if (response.statusCode == 200) {
      final responseBody = response.body;
      // Si el servidor retorna un mensaje no retorna data
      if (responseBody.startsWith('El alumno')) {
        return ApiResponse(false, {}, responseBody);
      } else {
        // Si el servidor encuentra el id retorna el mensaje
        return ApiResponse(true, {}, responseBody);
      }
    } else {
      // Si esta respuesta no fue OK, lanza un error.
      return ApiResponse(false, {}, 'Error en la peticion');
    }
  }

  // Funcion para eliminar un alumno
  // Parametros: matricula
  // Retorna: success, data, message
  static Future<ApiResponse> deleteAlumno(String matricula) async {
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

    if (response.statusCode == 200) {
      final responseBody = response.body;
      // Si el servidor retorna un mensaje no retorna data
      if (responseBody.startsWith('El alumno')) {
        return ApiResponse(false, {}, responseBody);
      } else {
        // Si el servidor encuentra el id retorna el mensaje
        return ApiResponse(true, {}, responseBody);
      }
    } else {
      // Si esta respuesta no fue OK, lanza un error.
      return ApiResponse(false, {}, 'Error en la peticion');
    }
  }

  // -----------------Mas Eventos-----------------------

  // Funcion para obtener la suma de ingresos totales
  // de un evento
  // Parametros: id evento
  // Retorna: success, data, message
  static Future<ApiResponse> getIngresosEvento(String id) async {
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

    if (response.statusCode == 200) {
      final responseBody = response.body;
      // Si el servidor retorna un mensaje no retorna data
      if (responseBody.startsWith('El evento')) {
        return ApiResponse(false, {}, responseBody);
      } else {
        // Si el servidor encuentra el id retorna el mensaje
        final jsonData = json.decode(response.body);
        return ApiResponse(true, jsonData, '');
      }
    } else {
      // Si esta respuesta no fue OK, lanza un error.
      return ApiResponse(false, {}, 'Error en la peticion');
    }
  }

  // Funcion para añadir un ingreso a un evento
  // Parametros: id evento, Map<String, dynamic> postData
  // Retorna: success, data, message
  static Future<ApiResponse> postIngresoEvento(
      String id, Map<String, dynamic> postData) async {
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

    if (response.statusCode == 200) {
      final responseBody = response.body;
      // Si el servidor retorna un mensaje no retorna data
      if (responseBody.startsWith('El id')) {
        return ApiResponse(false, {}, responseBody);
      } else {
        // Si el servidor encuentra el id retorna el mensaje
        return ApiResponse(true, {}, responseBody);
      }
    } else {
      // Si esta respuesta no fue OK, lanza un error.
      return ApiResponse(false, {}, 'Error en la peticion');
    }
  }

  // Funcion para obtener la suma de egresos totales
  // de un evento
  // Parametros: id evento
  // Retorna: success, data, message
  static Future<ApiResponse> getEgresosEvento(String id) async {
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

    if (response.statusCode == 200) {
      final responseBody = response.body;
      // Si el servidor retorna un mensaje no retorna data
      if (responseBody.startsWith('El evento')) {
        return ApiResponse(false, {}, responseBody);
      } else {
        // Si el servidor encuentra el id retorna el mensaje
        final jsonData = json.decode(response.body);
        return ApiResponse(true, jsonData, '');
      }
    } else {
      // Si esta respuesta no fue OK, lanza un error.
      return ApiResponse(false, {}, 'Error en la peticion');
    }
  }

  // Funcion para añadir un egreso a un evento
  // Parametros: id, Map<String, dynamic> postData
  // Retorna: success, data, message
  static Future<ApiResponse> postEgresoEvento(
      String id, Map<String, dynamic> postData) async {
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

    if (response.statusCode == 200) {
      final responseBody = response.body;
      // Si el servidor retorna un mensaje no retorna data
      if (responseBody.startsWith('El id')) {
        return ApiResponse(false, {}, responseBody);
      } else {
        // Si el servidor encuentra el id retorna el mensaje
        return ApiResponse(true, {}, responseBody);
      }
    } else {
      // Si esta respuesta no fue OK, lanza un error.
      return ApiResponse(false, {}, 'Error en la peticion');
    }
  }

  // Funcion para obtener el total del calculo entre
  // ingresos y egresos de un evento
  // Parametros: id evento
  // Retorna: success, data, message
  static Future<ApiResponse> getTotalEvento(String id) async {
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

    if (response.statusCode == 200) {
      final responseBody = response.body;
      // Si el servidor retorna un mensaje no retorna data
      if (responseBody.startsWith('El evento')) {
        return ApiResponse(false, {}, responseBody);
      } else {
        // Si el servidor encuentra el id retorna el mensaje
        final jsonData = json.decode(response.body);
        return ApiResponse(true, jsonData, '');
      }
    } else {
      // Si esta respuesta no fue OK, lanza un error.
      return ApiResponse(false, {}, 'Error en la peticion');
    }
  }

  // Funcion para obtener todas las asistencias de un evento
  // Parametros: id evento
  // Retorna: success, data, message
  static Future<ApiResponse> getAsistenciasEvento(String id) async {
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

    if (response.statusCode == 200) {
      final responseBody = response.body;
      // Si el servidor retorna un mensaje no retorna data
      if (responseBody.startsWith('El id')) {
        return ApiResponse(false, {}, responseBody);
      } else {
        // Si el servidor encuentra el id retorna el mensaje
        final jsonData = json.decode(response.body);
        return ApiResponse(true, jsonData, '');
      }
    } else {
      // Si esta respuesta no fue OK, lanza un error.
      return ApiResponse(false, {}, 'Error en la peticion');
    }
  }

  // Funcion para agregar una asistencia a un evento
  // Parametros: id, matricula
  // Retorna: success, data, message
  static Future<ApiResponse> postAsistenciaEvento(
      String id, String matricula) async {
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

    if (response.statusCode == 200) {
      final responseBody = response.body;
      // Si el servidor retorna un mensaje no retorna data
      if (responseBody.startsWith('El id') ||
          responseBody.startsWith('El alumno')) {
        return ApiResponse(false, {}, responseBody);
      } else {
        // Si el servidor encuentra el id retorna el mensaje
        return ApiResponse(true, {}, responseBody);
      }
    } else {
      // Si esta respuesta no fue OK, lanza un error.
      return ApiResponse(false, {}, 'Error en la peticion');
    }
  }

  // Función para realizar el inicio de sesión
  // Parametros: username, password
  // Retorna: success
  static Future<ApiResponse> login(String matricula, String password) async {
    final url = Uri.parse(
        '$_baseUrl/users/login?matricula=$matricula&password=$password');

    // Crear un mapa con las credenciales del usuario
    final credentials = {
      'matricula': matricula,
      'password': password,
    };

    final jsonBody = json.encode(credentials);

    // Realiza la solicitud POST para autenticar al usuario
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonBody,
    );

    if (response.statusCode == 200) {
      final responseBody = response.body;

      if (responseBody.startsWith('Suc')) {
        return ApiResponse(true, {}, 'Inicio de sesión exitoso');
      } else {
        return ApiResponse(false, {}, 'Credenciales incorrectas');
      }
    } else {
      return ApiResponse(false, {}, 'Error en la petición de inicio de sesión');
    }
  }
}
