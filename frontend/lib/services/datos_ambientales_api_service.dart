import 'dart:convert';
import 'api_service.dart';

class DatosAmbientalesApiService {
  static final ApiService _apiService = ApiService();

  // Crear datos ambientales (único endpoint disponible en el backend)
  static Future<Map<String, dynamic>> createDatosAmbientales(Map<String, dynamic> datosData) async {
    try {
      final response = await _apiService.post('datos-ambientales', datosData);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al crear datos ambientales: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // NOTA: Los siguientes endpoints NO EXISTEN en el backend actual
  // Se incluyen como placeholders para futuras implementaciones
  
  /*
  // Obtener datos ambientales específicos por ID (NO IMPLEMENTADO)
  static Future<Map<String, dynamic>> getDatosAmbientales(int idDato) async {
    throw UnimplementedError('Endpoint no implementado en el backend');
  }

  // Obtener datos ambientales por simulación (NO IMPLEMENTADO)
  static Future<List<dynamic>> getDatosBySimulacion(int idSimulacion) async {
    throw UnimplementedError('Endpoint no implementado en el backend');
  }

  // Importar datos ambientales en lote (NO IMPLEMENTADO)
  static Future<Map<String, dynamic>> bulkImportDatos(List<Map<String, dynamic>> datosAmbientales) async {
    throw UnimplementedError('Endpoint no implementado en el backend');
  }
  */
} 