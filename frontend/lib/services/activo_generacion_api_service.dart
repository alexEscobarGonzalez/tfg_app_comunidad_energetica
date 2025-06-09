import 'dart:convert';
import '../models/activo_generacion.dart';
import '../models/enums/tipo_activo_generacion.dart';
import 'api_service.dart';

class ActivoGeneracionApiService {
  static final ApiService _apiService = ApiService();

  // Convertir enum a valor esperado por backend
  static String _tipoActivoToBackendValue(TipoActivoGeneracion tipo) {
    switch (tipo) {
      case TipoActivoGeneracion.INSTALACION_FOTOVOLTAICA:
        return 'Instalación Fotovoltaica';
      case TipoActivoGeneracion.AEROGENERADOR:
        return 'Aerogenerador';
    }
  }

  // Obtener activos de generación por comunidad
  static Future<List<ActivoGeneracion>> getActivosGeneracionByComunidad(int idComunidad) async {
    try {
      final response = await _apiService.get('activos-generacion/comunidad/$idComunidad');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ActivoGeneracion.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener activos de generación: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener activo de generación específico
  static Future<ActivoGeneracion?> getActivoGeneracion(int idActivo) async {
    try {
      final response = await _apiService.get('activos-generacion/$idActivo');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ActivoGeneracion.fromJson(data);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Error al obtener activo de generación: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Crear nuevo activo de generación
  static Future<ActivoGeneracion> createActivoGeneracion({
    required String nombreDescriptivo,
    required DateTime fechaInstalacion,
    required double costeInstalacion_eur,
    required int vidaUtil_anios,
    required double latitud,
    required double longitud,
    required double potenciaNominal_kWp,
    required int idComunidadEnergetica,
    required TipoActivoGeneracion tipo_activo,
    String? inclinacionGrados,
    String? azimutGrados,
    String? tecnologiaPanel,
    String? perdidaSistema,
    String? posicionMontaje,
    Map<String, dynamic>? curvaPotencia,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'nombreDescriptivo': nombreDescriptivo,
        'fechaInstalacion': fechaInstalacion.toIso8601String().split('T')[0],
        'costeInstalacion_eur': costeInstalacion_eur,
        'vidaUtil_anios': vidaUtil_anios,
        'latitud': latitud,
        'longitud': longitud,
        'potenciaNominal_kWp': potenciaNominal_kWp,
        'idComunidadEnergetica': idComunidadEnergetica,
        'tipo_activo': _tipoActivoToBackendValue(tipo_activo),
        // Campos requeridos por el backend con valores por defecto
        'inclinacionGrados': inclinacionGrados ?? '30',
        'azimutGrados': azimutGrados ?? '180',
        'tecnologiaPanel': tecnologiaPanel ?? 'crystSi',
        'perdidaSistema': perdidaSistema ?? '14',
        'posicionMontaje': posicionMontaje ?? 'fijo',
        if (curvaPotencia != null) 'curvaPotencia': curvaPotencia,
      };

      // Usar endpoint específico según el tipo de activo
      String endpoint;
      if (tipo_activo == TipoActivoGeneracion.INSTALACION_FOTOVOLTAICA) {
        endpoint = 'activos-generacion/instalacion-fotovoltaica';
      } else {
        endpoint = 'activos-generacion/aerogenerador';
      }

      final response = await _apiService.post(endpoint, data);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return ActivoGeneracion.fromJson(responseData);
      } else {
        throw Exception('Error al crear activo de generación: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Actualizar activo de generación
  static Future<ActivoGeneracion> updateActivoGeneracion({
    required int idActivoGeneracion,
    required String nombreDescriptivo,
    required DateTime fechaInstalacion,
    required double costeInstalacion_eur,
    required int vidaUtil_anios,
    required double latitud,
    required double longitud,
    required double potenciaNominal_kWp,
    required TipoActivoGeneracion tipo_activo,
    String? inclinacionGrados,
    String? azimutGrados,
    String? tecnologiaPanel,
    String? perdidaSistema,
    String? posicionMontaje,
    Map<String, dynamic>? curvaPotencia,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'nombreDescriptivo': nombreDescriptivo,
        'fechaInstalacion': fechaInstalacion.toIso8601String().split('T')[0],
        'costeInstalacion_eur': costeInstalacion_eur,
        'vidaUtil_anios': vidaUtil_anios,
        'latitud': latitud,
        'longitud': longitud,
        'potenciaNominal_kWp': potenciaNominal_kWp,
        'tipo_activo': _tipoActivoToBackendValue(tipo_activo),
        // Campos requeridos por el backend con valores por defecto
        'inclinacionGrados': inclinacionGrados ?? '30',
        'azimutGrados': azimutGrados ?? '180',
        'tecnologiaPanel': tecnologiaPanel ?? 'crystSi',
        'perdidaSistema': perdidaSistema ?? '14',
        'posicionMontaje': posicionMontaje ?? 'fijo',
        if (curvaPotencia != null) 'curvaPotencia': curvaPotencia,
      };

      // Usar endpoint específico según el tipo de activo
      String endpoint;
      if (tipo_activo == TipoActivoGeneracion.INSTALACION_FOTOVOLTAICA) {
        endpoint = 'activos-generacion/instalacion-fotovoltaica/$idActivoGeneracion';
      } else {
        endpoint = 'activos-generacion/aerogenerador/$idActivoGeneracion';
      }

      final response = await _apiService.put(endpoint, data);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return ActivoGeneracion.fromJson(responseData);
      } else {
        throw Exception('Error al actualizar activo de generación: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Eliminar activo de generación
  static Future<bool> deleteActivoGeneracion(int idActivo) async {
    try {
      final response = await _apiService.delete('activos-generacion/$idActivo');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        throw Exception('Error al eliminar activo de generación: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener estadísticas del activo de generación
  static Future<Map<String, dynamic>?> getEstadisticasActivoGeneracion(int idActivo) async {
    try {
      final response = await _apiService.get('activos-generacion/$idActivo/estadisticas');

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

  // Obtener activos fotovoltaicos por comunidad
  static Future<List<ActivoGeneracion>> getActivosFotovoltaicosByComunidad(int idComunidad) async {
    try {
      final response = await _apiService.get('activos-generacion/comunidad/$idComunidad/fotovoltaicas');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ActivoGeneracion.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener activos fotovoltaicos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener aerogeneradores por comunidad
  static Future<List<ActivoGeneracion>> getAerogeneradoresByComunidad(int idComunidad) async {
    try {
      final response = await _apiService.get('activos-generacion/comunidad/$idComunidad/aerogeneradores');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ActivoGeneracion.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener aerogeneradores: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Generar datos PVGIS para instalaciones fotovoltaicas
  static Future<Map<String, dynamic>?> generarDatosPVGIS({
    required double latitud,
    required double longitud,
    required double potenciaNominal_kWp,
    double? inclinacion,
    double? azimut,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'latitud': latitud,
        'longitud': longitud,
        'potenciaNominal_kWp': potenciaNominal_kWp,
        if (inclinacion != null) 'inclinacion': inclinacion,
        if (azimut != null) 'azimut': azimut,
      };

      final response = await _apiService.post('activos-generacion/pvgis', data);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Error al generar datos PVGIS: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
} 