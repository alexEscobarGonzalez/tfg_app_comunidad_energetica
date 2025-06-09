import 'dart:convert';
import 'api_service.dart';

class ResultadoActivoGeneracionApiService {
  static final ApiService _apiService = ApiService();

  // Crear resultado de activo de generación
  static Future<Map<String, dynamic>> createResultado(Map<String, dynamic> resultadoData) async {
    try {
      final response = await _apiService.post('resultados-simulacion-activo-generacion/', resultadoData);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al crear resultado de activo de generación: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener resultado específico por ID
  static Future<Map<String, dynamic>> getResultado(int resultadoActivoId) async {
    try {
      final response = await _apiService.get('resultados-simulacion-activo-generacion/$resultadoActivoId');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al obtener resultado de activo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener resultados por simulación
  static Future<List<dynamic>> getResultadosBySimulacion(int resultadoSimulacionId) async {
    try {
      final response = await _apiService.get('resultados-simulacion-activo-generacion/simulacion/$resultadoSimulacionId');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al obtener resultados por simulación: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener resultados por activo de generación
  static Future<List<dynamic>> getResultadosByActivo(int activoGeneracionId) async {
    try {
      final response = await _apiService.get('resultados-simulacion-activo-generacion/activo-generacion/$activoGeneracionId');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al obtener resultados por activo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Listar todos los resultados con paginación
  static Future<List<dynamic>> listAllResultados({int skip = 0, int limit = 100}) async {
    try {
      final response = await _apiService.get('resultados-simulacion-activo-generacion/?skip=$skip&limit=$limit');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al listar resultados: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Actualizar resultado
  static Future<Map<String, dynamic>> updateResultado(int resultadoActivoId, Map<String, dynamic> resultadoData) async {
    try {
      final response = await _apiService.put('resultados-simulacion-activo-generacion/$resultadoActivoId', resultadoData);

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
  static Future<bool> deleteResultado(int resultadoActivoId) async {
    try {
      final response = await _apiService.delete('resultados-simulacion-activo-generacion/$resultadoActivoId');

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