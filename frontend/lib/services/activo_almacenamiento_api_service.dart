import 'dart:convert';
import '../models/activo_almacenamiento.dart';
import 'api_service.dart';

class ActivoAlmacenamientoApiService {
  static final ApiService _apiService = ApiService();

  // Obtener activos de almacenamiento por comunidad
  static Future<List<ActivoAlmacenamiento>> getActivosAlmacenamientoByComunidad(int idComunidad) async {
    try {
      final response = await _apiService.get('activos-almacenamiento/comunidad/$idComunidad');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ActivoAlmacenamiento.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener activos de almacenamiento: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener activo de almacenamiento específico
  static Future<ActivoAlmacenamiento?> getActivoAlmacenamiento(int idActivo) async {
    try {
      final response = await _apiService.get('activos-almacenamiento/$idActivo');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ActivoAlmacenamiento.fromJson(data);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Error al obtener activo de almacenamiento: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Crear nuevo activo de almacenamiento
  static Future<ActivoAlmacenamiento> createActivoAlmacenamiento({
    String? nombreDescriptivo,
    required double capacidadNominal_kWh,
    double? potenciaMaximaCarga_kW,
    double? potenciaMaximaDescarga_kW,
    double? eficienciaCicloCompleto_pct,
    double? profundidadDescargaMax_pct,
    required int idComunidadEnergetica,
  }) async {
    try {
      final Map<String, dynamic> data = {
        if (nombreDescriptivo != null) 'nombreDescriptivo': nombreDescriptivo,
        'capacidadNominal_kWh': capacidadNominal_kWh,
        if (potenciaMaximaCarga_kW != null) 'potenciaMaximaCarga_kW': potenciaMaximaCarga_kW,
        if (potenciaMaximaDescarga_kW != null) 'potenciaMaximaDescarga_kW': potenciaMaximaDescarga_kW,
        if (eficienciaCicloCompleto_pct != null) 'eficienciaCicloCompleto_pct': eficienciaCicloCompleto_pct,
        if (profundidadDescargaMax_pct != null) 'profundidadDescargaMax_pct': profundidadDescargaMax_pct,
        'idComunidadEnergetica': idComunidadEnergetica,
      };

      final response = await _apiService.post('activos-almacenamiento', data);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return ActivoAlmacenamiento.fromJson(responseData);
      } else {
        throw Exception('Error al crear activo de almacenamiento: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Actualizar activo de almacenamiento
  static Future<ActivoAlmacenamiento> updateActivoAlmacenamiento({
    required int idActivoAlmacenamiento,
    String? nombreDescriptivo,
    required double capacidadNominal_kWh,
    double? potenciaMaximaCarga_kW,
    double? potenciaMaximaDescarga_kW,
    double? eficienciaCicloCompleto_pct,
    double? profundidadDescargaMax_pct,
  }) async {
    try {
      final Map<String, dynamic> data = {
        if (nombreDescriptivo != null) 'nombreDescriptivo': nombreDescriptivo,
        'capacidadNominal_kWh': capacidadNominal_kWh,
        if (potenciaMaximaCarga_kW != null) 'potenciaMaximaCarga_kW': potenciaMaximaCarga_kW,
        if (potenciaMaximaDescarga_kW != null) 'potenciaMaximaDescarga_kW': potenciaMaximaDescarga_kW,
        if (eficienciaCicloCompleto_pct != null) 'eficienciaCicloCompleto_pct': eficienciaCicloCompleto_pct,
        if (profundidadDescargaMax_pct != null) 'profundidadDescargaMax_pct': profundidadDescargaMax_pct,
      };

      final response = await _apiService.put('activos-almacenamiento/$idActivoAlmacenamiento', data);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return ActivoAlmacenamiento.fromJson(responseData);
      } else {
        throw Exception('Error al actualizar activo de almacenamiento: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Eliminar activo de almacenamiento
  static Future<bool> deleteActivoAlmacenamiento(int idActivo) async {
    try {
      final response = await _apiService.delete('activos-almacenamiento/$idActivo');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        throw Exception('Error al eliminar activo de almacenamiento: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener estadísticas del activo de almacenamiento
  static Future<Map<String, dynamic>?> getEstadisticasActivoAlmacenamiento(int idActivo) async {
    try {
      final response = await _apiService.get('activos-almacenamiento/$idActivo/estadisticas');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Error al obtener estadísticas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
} 