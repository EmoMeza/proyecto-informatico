// import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Se importa de la siguiente manera:
// import '../api_services.dart';

class ApiService {

  // Esto se puede cambiar segun la ip del servidor o el puerto
  static const String _baseUrl = 'http://127.0.0.1:4040';

  // -----------------Centro de Alumnos-----------------------

  // Funcion para obtener un CAA
  // Parametros: id
  // Retorna: Map<String, dynamic>
  static Future<Map<String, dynamic>> getCaa(String id) async{
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
      // Si el servidor devuelve una repuesta OK, parsea el JSON
      return json.decode(response.body);
    }else{
      // Si esta respuesta no fue OK, lanza un error.
      return {};
    }
  }

  // Funcion para agregar CAA
  // Parametros: Map<String, dynamic> postData
  // Retorna: Map<String, dynamic>
  static Future<Map<String, dynamic>> postCaa(Map<String, dynamic> postData) async{
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
      // Si el servidor devuelve una repuesta OK, parsea el JSON
      return json.decode(response.body);
    }else{
      // Si esta respuesta no fue OK, lanza un error.
      return {};
    }
  }

  // Funcion para actualizar CAA
  // Parametros: id, Map<String, dynamic> updateData
  // Retorna: Map<String, dynamic>
  static Future<Map<String, dynamic>> updateCaa(String id, Map<String, dynamic> updateData) async{
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
      // Si el servidor devuelve una repuesta OK, parsea el JSON
      return json.decode(response.body);
    }else{
      // Si esta respuesta no fue OK, lanza un error.
      return {};
    }
  }

  // Funcion para eliminar CAA
  // Parametros: id
  // Retorna: Map<String, dynamic>
  static Future<Map<String, dynamic>> deleteCaa(String id) async{
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
      // Si el servidor devuelve una repuesta OK, parsea el JSON
      return json.decode(response.body);
    }else{
      // Si esta respuesta no fue OK, lanza un error.
      return {};
    }
  }

  // Funcion para obtener todos los CAA
  // Parametros: -
  // Retorna: List<Map<String, dynamic>>
  static Future<List<Map<String, dynamic>>> getAllCaa() async{
    var url = Uri.parse('$_baseUrl/get/all/caas');

    //Realiza la peticion
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
      },
    );

    if(response.statusCode == 200){
      // Si el servidor devuelve una repuesta OK, parsea el JSON
      return json.decode(response.body);
    }else{
      // Si esta respuesta no fue OK, lanza un error.
      return [];
    }
  }

  // Funcion para obtener los ingresos de un CAA
  // Parametros: id
  // Retorna: List<Map<String, dynamic>>
  static Future<List<Map<String, dynamic>>> getIngresosCaa(String id) async{
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

    if(response.statusCode == 200){
      // Si el servidor devuelve una repuesta OK, parsea el JSON
      return json.decode(response.body);
    }else{
      // Si esta respuesta no fue OK, lanza un error.
      return [];
    }
  }

  // Funcion para agregar ingreso a un CAA
  // Parametros: id, Map<String, dynamic> postData
  // Retorna: Map<String, dynamic>
  static Future<Map<String, dynamic>> postIngresoCaa(String id, Map<String, dynamic> postData) async{
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
      // Si el servidor devuelve una repuesta OK, parsea el JSON
      return json.decode(response.body);
    }else{
      // Si esta respuesta no fue OK, lanza un error.
      return {};
    }
  }

  // Funcion para obtener los egresos de un CAA
  // Parametros: id
  // Retorna: List<Map<String, dynamic>>
  static Future<List<Map<String, dynamic>>> getEgresosCaa(String id) async{
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
      // Si el servidor devuelve una repuesta OK, parsea el JSON
      return json.decode(response.body);
    }else{
      // Si esta respuesta no fue OK, lanza un error.
      return [];
    }
  }

  // Funcion para agregar egreso a un CAA
  // Parametros: id, Map<String, dynamic> postData
  // Retorna: Map<String, dynamic>
  static Future<Map<String, dynamic>> postEgresoCaa(String id, Map<String, dynamic> postData) async{
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
      // Si el servidor devuelve una repuesta OK, parsea el JSON
      return json.decode(response.body);
    }else{
      // Si esta respuesta no fue OK, lanza un error.
      return {};
    }
  }

  // Funcion para obtener el total del calculo entre 
  // ingresos y egresos de un CAA
  // Parametros: id
  // Retorna: Map<String, dynamic>
  static Future<Map<String, dynamic>> getTotalCaa(String id) async{
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
      // Si el servidor devuelve una repuesta OK, parsea el JSON
      return json.decode(response.body);
    }else{
      // Si esta respuesta no fue OK, lanza un error.
      return {};
    }
  }

  // -----------------Eventos-----------------------

  // Funcion para obtener un evento
  // Parametros: id
  // Retorna: Map<String, dynamic>
  static Future<Map<String, dynamic>> getEvento(String id) async{
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
      // Si el servidor devuelve una repuesta OK, parsea el JSON
      return json.decode(response.body)[0];
    }else{
      // Si esta respuesta no fue OK, lanza un error.
      return {};
    }
  }

  // Funcion para agregar un evento
  // Parametros: Map<String, dynamic> postData
  // Retorna: Map<String, dynamic>
  static Future<Map<String, dynamic>> postEvento(Map<String, dynamic> postData) async{
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
      // Si el servidor devuelve una repuesta OK, parsea el JSON
      return json.decode(response.body);
    }else{
      // Si esta respuesta no fue OK, lanza un error.
      return {};
    }
  }

  // Funcion para actualizar un evento
  // Parametros: id, Map<String, dynamic> updateData
  // Retorna: Map<String, dynamic>
  static Future<Map<String, dynamic>> updateEvento(String id, Map<String, dynamic> updateData) async{
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
      // Si el servidor devuelve una repuesta OK, parsea el JSON
      return json.decode(response.body);
    }else{
      // Si esta respuesta no fue OK, lanza un error.
      return {};
    }
  }

  // Funcion para eliminar un evento
  // Parametros: id
  // Retorna: Map<String, dynamic>
  static Future<Map<String, dynamic>> deleteEvento(String id) async{
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
      // Si el servidor devuelve una repuesta OK, parsea el JSON
      return json.decode(response.body);
    }else{
      // Si esta respuesta no fue OK, lanza un error.
      return {};
    }
  }

  // Funcion para obtener todos los eventos
  // Parametros: -
  // Retorna: List<Map<String, dynamic>>
  static Future<List<Map<String, dynamic>>> getAllEventos() async{
    var url = Uri.parse('$_baseUrl/get/all/eventos');

    //Realiza la peticion
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
      },
    );

    if(response.statusCode == 200){
      // Si el servidor devuelve una repuesta OK, parsea el JSON
      List<Map<String, dynamic>> eventos = json.decode(response.body);
      return eventos;
    }else{
      // Si esta respuesta no fue OK, lanza un error.
      return [];
    }
  }

  // Funcion para obtener los eventos segun un filtro
  // Parametros: Map<String, dynamic> filterData
  // Retorna: List<Map<String, dynamic>>
  static Future<List<Map<String, dynamic>>> getEventosFiltrados(Map<String, dynamic> filterData) async{
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
      // Si el servidor devuelve una repuesta OK, parsea el JSON
      List<Map<String, dynamic>> eventos = json.decode(response.body);
      return eventos;
    }else{
      // Si esta respuesta no fue OK, lanza un error.
      return [];
    }
  }

  // -----------------Alumnos-----------------------

  // Funcion para obtener un alumno
  // Parametros: matricula
  // Retorna: Map<String, dynamic>
  static Future<Map<String, dynamic>> getAlumno(String matricula) async{
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
      // Si el servidor devuelve una repuesta OK, parsea el JSON
      Map<String, dynamic> alumno = json.decode(response.body);
      return alumno;
    }else{
      // Si esta respuesta no fue OK, lanza un error.
      return {};
    }
  }

  // Funcion para actualizar un alumno
  // Parametros: matricula, Map<String, dynamic> updateData
  // Retorna: Map<String, dynamic>
  static Future<Map<String, dynamic>> updateAlumno(String matricula, Map<String, dynamic> updateData) async{
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
      // Si el servidor devuelve una repuesta OK, parsea el JSON
      return json.decode(response.body);
    }else{
      // Si esta respuesta no fue OK, lanza un error.
      return {};
    }
  }

  // Funcion para eliminar un alumno
  // Parametros: matricula
  // Retorna: Map<String, dynamic>
  static Future<Map<String, dynamic>> deleteAlumno(String matricula) async{
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
      // Si el servidor devuelve una repuesta OK, parsea el JSON
      Map<String, dynamic> alumno = json.decode(response.body);
      return alumno;
    }else{
      // Si esta respuesta no fue OK, lanza un error.
      return {};
    }
  }

  // -----------------Mas Eventos-----------------------

  // Funcion para obtener la suma de ingresos totales 
  // de un evento
  // Parametros: id
  // Retorna: <Map<String, dynamic>
  static Future<Map<String, dynamic>> getIngresosEvento(String id) async{
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
      // Si el servidor devuelve una repuesta OK, parsea el JSON
      Map<String, dynamic> ingresos = json.decode(response.body);
      return ingresos;
    }else{
      // Si esta respuesta no fue OK, lanza un error.
      return {};
    }
  }

  // Funcion para añadir un ingreso a un evento
  // Parametros: id, Map<String, dynamic> postData
  // Retorna: Map<String, dynamic>
  static Future<Map<String, dynamic>> postIngresoEvento(String id, Map<String, dynamic> postData) async{
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
      // Si el servidor devuelve una repuesta OK, parsea el JSON
      Map<String, dynamic> ingreso = json.decode(response.body);
      return ingreso;
    }else{
      // Si esta respuesta no fue OK, lanza un error.
      return {};
    }
  }

  // Funcion para obtener la suma de egresos totales
  // de un evento
  // Parametros: id
  // Retorna: List<Map<String, dynamic>>
  static Future<Map<String, dynamic>> getEgresosEvento(String id) async{
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
      // Si el servidor devuelve una repuesta OK, parsea el JSON
      Map<String, dynamic> egresos = json.decode(response.body);
      return egresos;
    }else{
      // Si esta respuesta no fue OK, lanza un error.
      return {};
    }
  }

  // Funcion para añadir un egreso a un evento
  // Parametros: id, Map<String, dynamic> postData
  // Retorna: Map<String, dynamic>
  static Future<Map<String, dynamic>> postEgresoEvento(String id, Map<String, dynamic> postData) async{
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
      // Si el servidor devuelve una repuesta OK, parsea el JSON
      Map<String, dynamic> egreso = json.decode(response.body);
      return egreso;
    }else{
      // Si esta respuesta no fue OK, lanza un error.
      return {};
    }
  }

  // Funcion para obtener el total del calculo entre
  // ingresos y egresos de un evento
  // Parametros: id
  // Retorna: Map<String, dynamic>
  static Future<Map<String, dynamic>> getTotalEvento(String id) async{
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
      // Si el servidor devuelve una repuesta OK, parsea el JSON
      Map<String, dynamic> total = json.decode(response.body);
      return total;
    }else{
      // Si esta respuesta no fue OK, lanza un error.
      return {};
    }
  }

  // Funcion para obtener todas las asistencias de un evento
  // Parametros: id
  // Retorna: List<Map<String, dynamic>>
  static Future<List<Map<String, dynamic>>> getAsistenciasEvento(String id) async{
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
      // Si el servidor devuelve una repuesta OK, parsea el JSON
      List<Map<String, dynamic>> asistencias = json.decode(response.body);
      return asistencias;
    }else{
      // Si esta respuesta no fue OK, lanza un error.
      return [];
    }
  }

  // Funcion para agregar una asistencia a un evento
  // Parametros: id, matricula
  // Retorna: Map<String, dynamic>
  static Future<Map<String, dynamic>> postAsistenciaEvento(String id, String matricula) async{
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
      // Si el servidor devuelve una repuesta OK, parsea el JSON
      Map<String, dynamic> asistencia = json.decode(response.body);
      return asistencia;
    }else{
      // Si esta respuesta no fue OK, lanza un error.
      return {};
    }
  }

}