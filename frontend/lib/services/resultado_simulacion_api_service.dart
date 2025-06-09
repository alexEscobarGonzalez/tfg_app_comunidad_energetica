import 'dart:convert';
import 'api_service.dart';

class ResultadoSimulacionApiService {
  static final ApiService _apiService = ApiService();

  // Crear resultado de simulación
  static Future<Map<String, dynamic>> createResultado(Map<String, dynamic> resultadoData) async {
    try {
      final response = await _apiService.post('resultados-simulacion', resultadoData);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al crear resultado de simulación: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener resultado específico por ID
  static Future<Map<String, dynamic>> getResultado(int idResultado) async {
    try {
      final response = await _apiService.get('resultados-simulacion/$idResultado');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al obtener resultado: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener resultados por simulación
  static Future<Map<String, dynamic>> getResultadosBySimulacion(int idSimulacion) async {
    try {
      final response = await _apiService.get('resultados-simulacion/simulacion/$idSimulacion');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al obtener resultados de simulación: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Listar todos los resultados
  static Future<List<dynamic>> listAllResultados() async {
    try {
      final response = await _apiService.get('resultados-simulacion');

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
  static Future<Map<String, dynamic>> updateResultado(int idResultado, Map<String, dynamic> resultadoData) async {
    try {
      final response = await _apiService.put('resultados-simulacion/$idResultado', resultadoData);

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
      final response = await _apiService.delete('resultados-simulacion/$idResultado');

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