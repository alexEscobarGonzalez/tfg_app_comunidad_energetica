import 'dart:convert';
import '../models/contrato_autoconsumo.dart';
import '../models/enums/tipo_contrato.dart';
import 'api_service.dart';

class ContratoAutoconsumoApiService {
  static final ApiService _apiService = ApiService();

  // Helper para convertir enum a string
  static String _getTipoContratoString(TipoContrato tipo) {
    switch (tipo) {
      case TipoContrato.PVPC:
        return 'PVPC';
      case TipoContrato.MERCADO_LIBRE:
        return 'Precio Fijo';
    }
  }

  // Obtener contrato por participante
  static Future<ContratoAutoconsumo?> getContratoByParticipante(int idParticipante) async {
    try {
      final response = await _apiService.get('contratos/participante/$idParticipante');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ContratoAutoconsumo.fromJson(data);
      } else if (response.statusCode == 404) {
        return null; // No tiene contrato
      } else {
        throw Exception('Error al obtener contrato: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Crear nuevo contrato energético
  static Future<ContratoAutoconsumo> createContrato({
    required int idParticipante,
    required TipoContrato tipoContrato,
    required double precioEnergiaImportacion_eur_kWh,
    required double precioCompensacionExcedentes_eur_kWh,
    required double potenciaContratada_kW,
    required double precioPotenciaContratado_eur_kWh,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'idParticipante': idParticipante,
        'tipoContrato': _getTipoContratoString(tipoContrato),
        'precioEnergiaImportacion_eur_kWh': precioEnergiaImportacion_eur_kWh,
        'precioCompensacionExcedentes_eur_kWh': precioCompensacionExcedentes_eur_kWh,
        'potenciaContratada_kW': potenciaContratada_kW,
        'precioPotenciaContratado_eur_kWh': precioPotenciaContratado_eur_kWh,
      };

      final response = await _apiService.post('contratos/', data);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return ContratoAutoconsumo.fromJson(responseData);
      } else {
        throw Exception('Error al crear contrato: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Actualizar contrato existente
  static Future<ContratoAutoconsumo> updateContrato({
    required int idContrato,
    required TipoContrato tipoContrato,
    required double precioEnergiaImportacion_eur_kWh,
    required double precioCompensacionExcedentes_eur_kWh,
    required double potenciaContratada_kW,
    required double precioPotenciaContratado_eur_kWh,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'tipoContrato': _getTipoContratoString(tipoContrato),
        'precioEnergiaImportacion_eur_kWh': precioEnergiaImportacion_eur_kWh,
        'precioCompensacionExcedentes_eur_kWh': precioCompensacionExcedentes_eur_kWh,
        'potenciaContratada_kW': potenciaContratada_kW,
        'precioPotenciaContratado_eur_kWh': precioPotenciaContratado_eur_kWh,
      };

      final response = await _apiService.put('contratos/$idContrato', data);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return ContratoAutoconsumo.fromJson(responseData);
      } else {
        throw Exception('Error al actualizar contrato: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Eliminar contrato
  static Future<bool> deleteContrato(int idContrato) async {
    try {
      final response = await _apiService.delete('contratos/$idContrato');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        throw Exception('Error al eliminar contrato: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener todos los contratos de una comunidad
  static Future<List<ContratoAutoconsumo>> getContratosByComunidad(int idComunidad) async {
    try {
      final response = await _apiService.get('contratos/');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ContratoAutoconsumo.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener contratos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
} 