import 'dart:convert';
import 'api_service.dart';

class ResultadoActivoAlmacenamientoApiService {
  static final ApiService _apiService = ApiService();

  // Crear resultado de activo de almacenamiento
  static Future<Map<String, dynamic>> createResultado(Map<String, dynamic> resultadoData) async {
    try {
      final response = await _apiService.post('resultados-activos-almacenamiento', resultadoData);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al crear resultado de activo de almacenamiento: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener resultado específico por ID
  static Future<Map<String, dynamic>> getResultado(int idResultado) async {
    try {
      final response = await _apiService.get('resultados-activos-almacenamiento/$idResultado');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al obtener resultado de almacenamiento: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener resultados por simulación (endpoint correcto)
  static Future<List<dynamic>> getResultadosBySimulacion(int idResultadoSimulacion) async {
    try {
      final response = await _apiService.get('resultados-activos-almacenamiento/resultado-simulacion/$idResultadoSimulacion');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al obtener resultados por simulación: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener resultado específico por simulación y activo
  static Future<Map<String, dynamic>> getResultadoBySimulacionYActivo(int idResultadoSimulacion, int idActivo) async {
    try {
      final response = await _apiService.get('resultados-activos-almacenamiento/resultado-simulacion/$idResultadoSimulacion/activo-almacenamiento/$idActivo');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al obtener resultado por simulación y activo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Listar todos los resultados de almacenamiento
  static Future<List<dynamic>> listAllResultados({int skip = 0, int limit = 100}) async {
    try {
      final response = await _apiService.get('resultados-activos-almacenamiento?skip=$skip&limit=$limit');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al listar resultados de almacenamiento: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Actualizar resultado
  static Future<Map<String, dynamic>> updateResultado(int idResultado, Map<String, dynamic> resultadoData) async {
    try {
      final response = await _apiService.put('resultados-activos-almacenamiento/$idResultado', resultadoData);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al actualizar resultado: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Eliminar resultado
  static Future<bool> deleteResultado(int idResultado) async {
    try {
      final response = await _apiService.delete('resultados-activos-almacenamiento/$idResultado');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        throw Exception('Error al eliminar resultado: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
} 