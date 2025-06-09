import 'dart:convert';
import '../models/participante.dart';
import 'api_service.dart';

class ParticipanteApiService {
  static final ApiService _apiService = ApiService();

  // Obtener todos los participantes de una comunidad
  static Future<List<Participante>> getParticipantesByComunidad(int idComunidad) async {
    try {
      final response = await _apiService.get('participantes/comunidad/$idComunidad');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Participante.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener participantes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener un participante específico
  static Future<Participante> getParticipante(int idParticipante) async {
    try {
      final response = await _apiService.get('participantes/$idParticipante');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Participante.fromJson(data);
      } else {
        throw Exception('Error al obtener participante: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Crear un nuevo participante
  static Future<Participante> createParticipante({
    required String nombre,
    required int idComunidadEnergetica,
    String? email,
    String? telefono,
    String? direccion,
    String? rol,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'nombre': nombre,
        'idComunidadEnergetica': idComunidadEnergetica,
        if (email != null) 'email': email,
        if (telefono != null) 'telefono': telefono,
        if (direccion != null) 'direccion': direccion,
        if (rol != null) 'rol': rol,
      };

      final response = await _apiService.post('participantes', data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return Participante.fromJson(responseData);
      } else {
        throw Exception('Error al crear participante: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Actualizar un participante
  static Future<Participante> updateParticipante({
    required int idParticipante,
    required String nombre,
    String? email,
    String? telefono,
    String? direccion,
    String? rol,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'nombre': nombre,
        if (email != null) 'email': email,
        if (telefono != null) 'telefono': telefono,
        if (direccion != null) 'direccion': direccion,
        if (rol != null) 'rol': rol,
      };

      final response = await _apiService.put('participantes/$idParticipante', data);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return Participante.fromJson(responseData);
      } else {
        throw Exception('Error al actualizar participante: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Eliminar un participante
  static Future<bool> deleteParticipante(int idParticipante) async {
    try {
      final response = await _apiService.delete('participantes/$idParticipante');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        throw Exception('Error al eliminar participante: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener estadísticas de un participante
  static Future<Map<String, dynamic>> getEstadisticasParticipante(int idParticipante) async {
    try {
      final response = await _apiService.get('participantes/$idParticipante/estadisticas');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al obtener estadísticas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
} 