import 'dart:convert';
import '../models/coeficiente_reparto.dart';
import '../models/enums/tipo_reparto.dart';
import 'api_service.dart';

class CoeficienteRepartoApiService {
  static final ApiService _apiService = ApiService();

  // ==========================================
  // MÉTODOS PARA RELACIÓN 1:1 (NUEVOS)
  // ==========================================

  // Obtener coeficiente único de un participante
  static Future<CoeficienteReparto?> getCoeficienteByParticipante(int idParticipante) async {
    try {
      final response = await _apiService.get('coeficientes-reparto/participante/$idParticipante/single');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        // Si responseData es null (participante sin coeficiente), retornar null
        if (responseData == null) return null;
        return CoeficienteReparto.fromJson(responseData);
      } else if (response.statusCode == 404) {
        // Participante no encontrado o sin coeficiente
        return null;
      } else {
        throw Exception('Error al obtener coeficiente del participante: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Crear o actualizar coeficiente de un participante (relación 1:1)
  static Future<CoeficienteReparto> createOrUpdateCoeficienteByParticipante({
    required int idParticipante,
    required TipoReparto tipoReparto,
    required Map<String, dynamic> parametros,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'tipoReparto': tipoReparto.value,
        'parametros': parametros,
      };

      final response = await _apiService.put('coeficientes-reparto/participante/$idParticipante', data);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return CoeficienteReparto.fromJson(responseData);
      } else {
        throw Exception('Error al crear/actualizar coeficiente: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Crear o actualizar coeficiente fijo (versión 1:1)
  static Future<CoeficienteReparto> createOrUpdateCoeficienteFijo({
    required int idParticipante,
    required double valor,
  }) async {
    return createOrUpdateCoeficienteByParticipante(
      idParticipante: idParticipante,
      tipoReparto: TipoReparto.REPARTO_FIJO,
      parametros: {
        'valor': valor,
      },
    );
  }

  // Crear o actualizar coeficiente programado (versión 1:1)
  static Future<CoeficienteReparto> createOrUpdateCoeficienteProgramado({
    required int idParticipante,
    required Map<String, double> coeficientesProgramados,
  }) async {
    return createOrUpdateCoeficienteByParticipante(
      idParticipante: idParticipante,
      tipoReparto: TipoReparto.REPARTO_PROGRAMADO,
      parametros: {
        'coeficientesProgramados': coeficientesProgramados,
      },
    );
  }

  // Eliminar coeficiente de un participante
  static Future<bool> deleteCoeficienteByParticipante(int idParticipante) async {
    try {
      // Primero obtener el coeficiente para conseguir su ID
      final coeficiente = await getCoeficienteByParticipante(idParticipante);
      if (coeficiente == null) {
        return true; // Ya no existe
      }

      final response = await _apiService.delete('coeficientes-reparto/${coeficiente.idCoeficienteReparto}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        throw Exception('Error al eliminar coeficiente: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // ==========================================
  // MÉTODOS HEREDADOS (COMPATIBILIDAD)
  // ==========================================

  // Obtener coeficientes por activo de generación (filtrados por participantes de la comunidad)
  static Future<List<CoeficienteReparto>> getCoeficientesByActivo(int idActivoGeneracion) async {
    try {
      // Como no hay endpoint específico, obtenemos todos y filtramos por idActivoGeneracion en los parámetros
      final response = await _apiService.get('coeficientes-reparto');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final allCoeficientes = data.map((json) => CoeficienteReparto.fromJson(json)).toList();
        
        // Filtrar por idActivoGeneracion en los parámetros
        return allCoeficientes.where((coef) {
          final idActivoEnParametros = coef.parametros['idActivoGeneracion'];
          return idActivoEnParametros == idActivoGeneracion;
        }).toList();
      } else {
        throw Exception('Error al obtener coeficientes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Crear coeficiente fijo (OBSOLETO - usar createOrUpdateCoeficienteFijo)
  @deprecated
  static Future<CoeficienteReparto> createCoeficienteFijo({
    required int idActivoGeneracion,
    required int idParticipante,
    required double coeficienteFijo,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'idParticipante': idParticipante,
        'tipoReparto': TipoReparto.REPARTO_FIJO.value,
        'parametros': {
          'idActivoGeneracion': idActivoGeneracion,
          'valor': coeficienteFijo,
        },
      };

      final response = await _apiService.post('coeficientes-reparto', data);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return CoeficienteReparto.fromJson(responseData);
      } else {
        throw Exception('Error al crear coeficiente: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Crear coeficiente programado (OBSOLETO - usar createOrUpdateCoeficienteProgramado)
  @deprecated
  static Future<CoeficienteReparto> createCoeficienteProgramado({
    required int idActivoGeneracion,
    required int idParticipante,
    required Map<String, double> coeficientesProgramados,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'idParticipante': idParticipante,
        'tipoReparto': TipoReparto.REPARTO_PROGRAMADO.value,
        'parametros': {
          'idActivoGeneracion': idActivoGeneracion,
          'coeficientesProgramados': coeficientesProgramados,
        },
      };

      final response = await _apiService.post('coeficientes-reparto', data);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return CoeficienteReparto.fromJson(responseData);
      } else {
        throw Exception('Error al crear coeficiente: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Actualizar coeficiente
  static Future<CoeficienteReparto> updateCoeficiente({
    required int idCoeficiente,
    required TipoReparto tipoReparto,
    required Map<String, dynamic> parametros,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'tipoReparto': tipoReparto.value,
        'parametros': parametros,
      };

      final response = await _apiService.put('coeficientes-reparto/$idCoeficiente', data);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return CoeficienteReparto.fromJson(responseData);
      } else {
        throw Exception('Error al actualizar coeficiente: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Eliminar coeficiente
  static Future<bool> deleteCoeficiente(int idCoeficiente) async {
    try {
      final response = await _apiService.delete('coeficientes-reparto/$idCoeficiente');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        throw Exception('Error al eliminar coeficiente: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Validar coeficientes de reparto para un activo (validación local)
  static Future<Map<String, dynamic>> validarCoeficientes(int idActivoGeneracion) async {
    try {
      final coeficientes = await getCoeficientesByActivo(idActivoGeneracion);
      
      // Validación local de coeficientes
      bool esValido = true;
      List<String> errores = [];
      
      if (coeficientes.isEmpty) {
        esValido = false;
        errores.add('No hay coeficientes de reparto configurados para este activo');
      } else {
        // Validar que la suma de coeficientes fijos sea 100%
        final coeficientesFijos = coeficientes.where((c) => c.tipoReparto == TipoReparto.REPARTO_FIJO);
        if (coeficientesFijos.isNotEmpty) {
          double suma = 0.0;
          for (final coef in coeficientesFijos) {
            suma += (coef.parametros['coeficienteFijo'] as num?)?.toDouble() ?? 0.0;
          }
          if ((suma - 100.0).abs() > 0.1) {
            esValido = false;
            errores.add('La suma de coeficientes fijos debe ser exactamente 100% (actual: ${suma.toStringAsFixed(1)}%)');
          }
        }
      }
      
      return {
        'valido': esValido,
        'errores': errores,
        'totalCoeficientes': coeficientes.length,
      };
    } catch (e) {
      throw Exception('Error al validar coeficientes: $e');
    }
  }

  // Obtener resumen de distribución por comunidad (implementación local)
  static Future<List<Map<String, dynamic>>> getResumenDistribucion(int idComunidad) async {
    try {
      // Obtener todos los coeficientes
      final response = await _apiService.get('coeficientes-reparto');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final coeficientes = data.map((json) => CoeficienteReparto.fromJson(json)).toList();
        
        // Agrupar por activo de generación
        Map<int, List<CoeficienteReparto>> agrupados = {};
        for (final coef in coeficientes) {
          final idActivo = coef.parametros['idActivoGeneracion'] as int?;
          if (idActivo != null) {
            agrupados.putIfAbsent(idActivo, () => []).add(coef);
          }
        }
        
        // Crear resumen
        return agrupados.entries.map((entry) {
          final idActivo = entry.key;
          final coefs = entry.value;
          
          return {
            'idActivoGeneracion': idActivo,
            'totalParticipantes': coefs.length,
            'tiposReparto': coefs.map((c) => c.tipoReparto.value).toSet().toList(),
            'esCompleto': coefs.length > 0,
          };
        }).toList();
      } else {
        throw Exception('Error al obtener resumen: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener todos los coeficientes de reparto
  static Future<List<CoeficienteReparto>> getCoeficientes() async {
    try {
      final response = await _apiService.get('coeficientes-reparto');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => CoeficienteReparto.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener coeficientes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
} 