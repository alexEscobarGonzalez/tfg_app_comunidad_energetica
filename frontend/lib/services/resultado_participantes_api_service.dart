import 'dart:convert';
import 'api_service.dart';

class ResultadoParticipantesApiService {
  static final ApiService _apiService = ApiService();

  // Crear resultado de participante
  static Future<Map<String, dynamic>> createResultado(Map<String, dynamic> resultadoData) async {
    try {
      final response = await _apiService.post('resultados-simulacion-participante', resultadoData);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al crear resultado de participante: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener resultado específico por ID
  static Future<Map<String, dynamic>> getResultado(int idResultado) async {
    try {
      final response = await _apiService.get('resultados-simulacion-participante/$idResultado');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al obtener resultado de participante: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener resultados por simulación
  static Future<List<dynamic>> getResultadosBySimulacion(int idResultadoSimulacion) async {
    try {
      final response = await _apiService.get('resultados-simulacion-participante/resultado/$idResultadoSimulacion');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al obtener resultados por simulación: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener resultados por participante
  static Future<List<dynamic>> getResultadosByParticipante(int idParticipante) async {
    try {
      final response = await _apiService.get('resultados-simulacion-participante/participante/$idParticipante');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al obtener resultados por participante: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Listar todos los resultados de participantes
  static Future<List<dynamic>> listAllResultados() async {
    try {
      final response = await _apiService.get('resultados-participantes');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al listar resultados de participantes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Actualizar resultado
  static Future<Map<String, dynamic>> updateResultado(int idResultado, Map<String, dynamic> resultadoData) async {
    try {
      final response = await _apiService.put('resultados-simulacion-participante/$idResultado', resultadoData);

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
      final response = await _apiService.delete('resultados-simulacion-participante/$idResultado');

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