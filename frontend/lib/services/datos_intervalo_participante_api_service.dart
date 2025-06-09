import 'dart:convert';
import 'api_service.dart';

class DatosIntervaloParticipanteApiService {
  static final ApiService _apiService = ApiService();

  // Obtener datos de intervalo específicos por ID
  static Future<Map<String, dynamic>> getDatosIntervalo(int datosIntervaloId) async {
    try {
      final response = await _apiService.get('datos-intervalo-participante/$datosIntervaloId');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al obtener datos de intervalo de participante: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener datos por resultado de participante
  static Future<List<dynamic>> getDatosByResultadoParticipante(int resultadoParticipanteId, {DateTime? startTime, DateTime? endTime}) async {
    try {
      String url = 'datos-intervalo-participante/resultado-participante/$resultadoParticipanteId';
      if (startTime != null && endTime != null) {
        url += '?start_time=${startTime.toIso8601String()}&end_time=${endTime.toIso8601String()}';
      }
      
      final response = await _apiService.get(url);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al obtener datos por resultado de participante: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Crear datos de intervalo de participante en lote (formato correcto según backend)
  static Future<List<dynamic>> bulkCreateDatos(List<Map<String, dynamic>> datosIntervalo) async {
    try {
      final Map<String, dynamic> requestData = {
        'datos': datosIntervalo,
      };
      
      final response = await _apiService.post('datos-intervalo-participante/bulk', requestData);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al crear datos de intervalo de participante en lote: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
} 