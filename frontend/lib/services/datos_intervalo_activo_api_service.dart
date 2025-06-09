import 'dart:convert';
import 'api_service.dart';

class DatosIntervaloActivoApiService {
  static final ApiService _apiService = ApiService();

  // Obtener datos de intervalo específicos por ID
  static Future<Map<String, dynamic>> getDatosIntervalo(int datosIntervaloId) async {
    try {
      final response = await _apiService.get('datos-intervalo-activo/$datosIntervaloId');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al obtener datos de intervalo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener datos por activo de generación
  static Future<List<dynamic>> getDatosByActivoGeneracion(int resultadoActivoGenId, {DateTime? startTime, DateTime? endTime}) async {
    try {
      String url = 'datos-intervalo-activo/activo-generacion/$resultadoActivoGenId';
      if (startTime != null && endTime != null) {
        url += '?start_time=${startTime.toIso8601String()}&end_time=${endTime.toIso8601String()}';
      }
      
      final response = await _apiService.get(url);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al obtener datos por activo de generación: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener datos por activo de almacenamiento
  static Future<List<dynamic>> getDatosByActivoAlmacenamiento(int resultadoActivoAlmId, {DateTime? startTime, DateTime? endTime}) async {
    try {
      String url = 'datos-intervalo-activo/activo-almacenamiento/$resultadoActivoAlmId';
      if (startTime != null && endTime != null) {
        url += '?start_time=${startTime.toIso8601String()}&end_time=${endTime.toIso8601String()}';
      }
      
      final response = await _apiService.get(url);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al obtener datos por activo de almacenamiento: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Listar todos los datos de intervalo con paginación
  static Future<List<dynamic>> listAllDatos({int skip = 0, int limit = 100}) async {
    try {
      final response = await _apiService.get('datos-intervalo-activo/?skip=$skip&limit=$limit');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al listar datos de intervalo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Crear datos de intervalo en lote (formato correcto según backend)
  static Future<List<dynamic>> bulkCreateDatos(List<Map<String, dynamic>> datosIntervalo) async {
    try {
      final Map<String, dynamic> requestData = {
        'datos': datosIntervalo,
      };
      
      final response = await _apiService.post('datos-intervalo-activo/bulk', requestData);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al crear datos de intervalo en lote: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
} 