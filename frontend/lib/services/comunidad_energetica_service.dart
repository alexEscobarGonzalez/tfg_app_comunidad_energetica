import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:frontend/models/comunidad_energetica.dart';
import 'package:frontend/services/api_service.dart';
import 'package:flutter/foundation.dart';

// Importación condicional para web
import 'dart:html' as html show Blob, Url, document, AnchorElement;

class ComunidadEnergeticaService {
  static final ApiService _apiService = ApiService();

  static Future<List<ComunidadEnergetica>> getComunidades() async {
    try {
      final response = await _apiService.get('comunidades');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ComunidadEnergetica.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener comunidades: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en getComunidades: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  static Future<ComunidadEnergetica> getComunidadById(int id) async {
    try {
      final response = await _apiService.get('comunidades/$id');
      
      if (response.statusCode == 200) {
        return ComunidadEnergetica.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al obtener comunidad: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en getComunidadById: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  static Future<ComunidadEnergetica> createComunidad(ComunidadEnergetica comunidad) async {
    try {
      final response = await _apiService.post(
        'comunidades',
        comunidad.toJson(),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ComunidadEnergetica.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al crear comunidad: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en createComunidad: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  static Future<ComunidadEnergetica> updateComunidad(int id, ComunidadEnergetica comunidad) async {
    try {
      final response = await _apiService.put(
        'comunidades/$id',
        comunidad.toJson(),
      );
      
      if (response.statusCode == 200) {
        return ComunidadEnergetica.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al actualizar comunidad: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en updateComunidad: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  static Future<void> deleteComunidad(int id) async {
    try {
      final response = await _apiService.delete('comunidades/$id');
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Error al eliminar comunidad: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en deleteComunidad: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  /// Exporta toda la información de una comunidad en un archivo ZIP
  /// [comunidadId] ID de la comunidad a exportar
  /// [fechaInicio] Fecha inicio para filtrar datos (opcional)
  /// [fechaFin] Fecha fin para filtrar datos (opcional)
  /// Retorna los datos del archivo y el nombre sugerido
  static Future<Map<String, dynamic>> exportarComunidadCompleta({
    required int comunidadId,
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    try {
      print('🔄 Iniciando exportación para comunidad $comunidadId');
      
      // Construir query parameters
      String queryString = '';
      List<String> params = [];
      
      if (fechaInicio != null) {
        params.add('fecha_inicio=${fechaInicio.year}-${fechaInicio.month.toString().padLeft(2, '0')}-${fechaInicio.day.toString().padLeft(2, '0')}');
      }
      
      if (fechaFin != null) {
        params.add('fecha_fin=${fechaFin.year}-${fechaFin.month.toString().padLeft(2, '0')}-${fechaFin.day.toString().padLeft(2, '0')}');
      }

      if (params.isNotEmpty) {
        queryString = '?${params.join('&')}';
      }

      // Construir URL completa para la descarga
      final url = Uri.parse('${_apiService.baseUrl}/comunidades/$comunidadId/export-completo$queryString');
      print('📡 URL de exportación: $url');
      
      // Obtener headers con autenticación
      final token = await _apiService.getToken();
      final headers = <String, String>{};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      // Realizar descarga
      final request = http.Request('GET', url);
      request.headers.addAll(headers);

      print('🌐 Enviando petición HTTP...');
      final streamedResponse = await request.send();
      print('📊 Respuesta recibida con código: ${streamedResponse.statusCode}');

      if (streamedResponse.statusCode == 200) {
        // Obtener todos los bytes del archivo
        print('📥 Descargando bytes del archivo...');
        final bytes = await streamedResponse.stream.toBytes();
        print('✅ Descarga completada. Tamaño: ${bytes.length} bytes');
        
        // Generar nombre del archivo
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final nombreArchivo = 'comunidad_export_${comunidadId}_$timestamp.zip';
        
        if (kIsWeb) {
          // Para web, usar la API de descarga del navegador
          print('🌍 Iniciando descarga en navegador web...');
          _downloadFileWeb(bytes, nombreArchivo);
          
          final resultado = {
            'success': true,
            'message': 'Archivo descargado: $nombreArchivo',
            'filename': nombreArchivo,
          };
          print('🎉 Exportación completada exitosamente: $resultado');
          return resultado;
        } else {
          // Para móvil/desktop, retornar los bytes para manejo posterior
          final resultado = {
            'success': true,
            'bytes': bytes,
            'filename': nombreArchivo,
            'message': 'Datos preparados para descarga',
          };
          print('📱 Datos preparados para descarga móvil/desktop: $resultado');
          return resultado;
        }
      } else if (streamedResponse.statusCode == 404) {
        print('❌ Error 404: Comunidad no encontrada');
        throw Exception('Comunidad no encontrada');
      } else if (streamedResponse.statusCode == 400) {
        final responseBody = await streamedResponse.stream.bytesToString();
        final errorData = json.decode(responseBody);
        print('❌ Error 400: ${errorData['detail']}');
        throw Exception('Error en los parámetros de exportación: ${errorData['detail'] ?? 'Formato de fecha inválido'}');
      } else {
        print('❌ Error HTTP ${streamedResponse.statusCode}');
        throw Exception('Error al exportar comunidad: ${streamedResponse.statusCode}');
      }
      
    } catch (e) {
      print('💥 Error en exportarComunidadCompleta: $e');
      if (e is Exception) {
        rethrow;
      } else {
        throw Exception('Error inesperado: $e');
      }
    }
  }

  /// Función para descargar archivo en web usando la API del navegador
  static void _downloadFileWeb(Uint8List bytes, String filename) {
    if (kIsWeb) {
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.document.createElement('a') as html.AnchorElement
        ..href = url
        ..style.display = 'none'
        ..download = filename;
      html.document.body?.children.add(anchor);
      anchor.click();
      html.document.body?.children.remove(anchor);
      html.Url.revokeObjectUrl(url);
    }
  }

  /// Importa toda la información de una comunidad desde un archivo ZIP
  /// [archivoZip] Bytes del archivo ZIP a importar
  /// [nombreArchivo] Nombre del archivo ZIP
  /// [idUsuario] ID del usuario que realiza la importación
  /// Retorna información sobre el resultado de la importación
  static Future<Map<String, dynamic>> importarComunidadCompleta({
    required Uint8List archivoZip,
    required String nombreArchivo,
    required int idUsuario,
  }) async {
    try {
      print('🔄 Iniciando importación de comunidad');
      print('📁 Archivo: $nombreArchivo (${archivoZip.length} bytes)');
      print('👤 Usuario: $idUsuario');
      
      // Construir URL del endpoint
      final url = Uri.parse('${_apiService.baseUrl}/comunidades/import-completo?id_usuario=$idUsuario');
      print('📡 URL de importación: $url');
      
      // Obtener headers con autenticación
      final token = await _apiService.getToken();
      final headers = <String, String>{};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      // Crear request multipart
      var request = http.MultipartRequest('POST', url);
      request.headers.addAll(headers);
      
      // Agregar archivo ZIP
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          archivoZip,
          filename: nombreArchivo,
        ),
      );

      print('🌐 Enviando petición de importación...');
      final streamedResponse = await request.send();
      print('📊 Respuesta recibida con código: ${streamedResponse.statusCode}');

      if (streamedResponse.statusCode == 200) {
        // Obtener respuesta como string y parsear JSON
        final responseBody = await streamedResponse.stream.bytesToString();
        final responseData = json.decode(responseBody) as Map<String, dynamic>;
        
        print('✅ Importación completada exitosamente');
        print('📈 Estadísticas: ${responseData['estadisticas']}');
        
        return {
          'success': true,
          'message': responseData['message'] ?? 'Importación completada',
          'estadisticas': responseData['estadisticas'] ?? {},
        };
      } else if (streamedResponse.statusCode == 400) {
        final responseBody = await streamedResponse.stream.bytesToString();
        final errorData = json.decode(responseBody);
        print('❌ Error 400: ${errorData['detail']}');
        throw Exception('Error en el archivo: ${errorData['detail'] ?? 'Archivo inválido'}');
      } else if (streamedResponse.statusCode == 500) {
        final responseBody = await streamedResponse.stream.bytesToString();
        final errorData = json.decode(responseBody);
        print('❌ Error 500: ${errorData['detail']}');
        throw Exception('Error del servidor: ${errorData['detail'] ?? 'Error interno'}');
      } else {
        print('❌ Error HTTP ${streamedResponse.statusCode}');
        throw Exception('Error al importar comunidad: ${streamedResponse.statusCode}');
      }
      
    } catch (e) {
      print('💥 Error en importarComunidadCompleta: $e');
      if (e is Exception) {
        rethrow;
      } else {
        throw Exception('Error inesperado: $e');
      }
    }
  }
} 