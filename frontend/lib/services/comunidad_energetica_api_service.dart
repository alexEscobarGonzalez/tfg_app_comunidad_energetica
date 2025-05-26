import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/models/comunidad_energetica.dart';
import 'package:frontend/models/enums/tipo_estrategia_excedentes.dart';

class ComunidadEnergeticaApiService {
  final ApiService _apiService;

  ComunidadEnergeticaApiService(this._apiService);
  
  Future<ComunidadEnergetica> createComunidadEnergetica(ComunidadEnergetica comunidad) async {
    final body = comunidad.toJson();

    debugPrint('Creando comunidad: $body');

    final response = await _apiService.post('comunidades', body);
    if (response.statusCode == 200) {
      final comunidadData = json.decode(response.body);
      return ComunidadEnergetica.fromJson(comunidadData);
    } else {
      throw Exception('Failed to create comunidad energética');
    }
  }
  
  Future<List<ComunidadEnergetica>> getComunidadesUsuario(int idUsuario) async {
    try {
      final response = await _apiService.get('usuarios/$idUsuario/comunidades');
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => ComunidadEnergetica.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener comunidades: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al obtener comunidades: $e');
    }
  }
  
  Future<ComunidadEnergetica> getComunidadById(int idComunidad) async {
    try {
      final response = await _apiService.get('comunidades/$idComunidad');
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return ComunidadEnergetica.fromJson(jsonData);
      } else {
        throw Exception('Error al obtener la comunidad: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al obtener la comunidad: $e');
    }
  }
  
  Future<ComunidadEnergetica> updateComunidad(int idComunidad, ComunidadEnergetica comunidad) async {
    final body = {
      'nombre': comunidad.nombre,
      'latitud': comunidad.latitud,
      'longitud': comunidad.longitud,
      'tipoEstrategiaExcedentes': comunidad.tipoEstrategiaExcedentes.toBackendString(),
    };

    final response = await _apiService.put('comunidades/$idComunidad', body);
    if (response.statusCode == 200) {
      final comunidadData = json.decode(response.body);
      return ComunidadEnergetica.fromJson(comunidadData);
    } else {
      throw Exception('Error al actualizar la comunidad energética');
    }
  }
  
  Future<void> deleteComunidad(int idComunidad) async {
    final response = await _apiService.delete('comunidades/$idComunidad');
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Error al eliminar la comunidad energética');
    }
  }
}

