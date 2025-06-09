import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/registro_consumo.dart';
import '../models/estadisticas_consumo.dart';
import 'api_service.dart';

class DatosConsumoApiService extends ApiService {
  static const String _endpoint = '/registros-consumo';

  // Obtener datos de consumo por participante
  Future<List<RegistroConsumo>> obtenerDatosConsumo(
    int idParticipante, {
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    try {
      // Usar el endpoint específico para obtener registros por participante
      final uri = Uri.parse('$baseUrl$_endpoint/participante/$idParticipante');

      final response = await http.get(uri, headers: getHeaders());

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => RegistroConsumo.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener datos de consumo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Crear registro manual de consumo
  Future<RegistroConsumo> crearRegistroConsumo(RegistroConsumo datos) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$_endpoint'),
        headers: getHeaders(),
        body: json.encode(datos.toJson()),
      );

      if (response.statusCode == 200) {
        return RegistroConsumo.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al crear registro: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Cargar datos desde archivo CSV usando endpoint de importación
  Future<ResultadoCargaDatos> cargarDatosCSV(
    File archivo,
    int idParticipante,
  ) async {
    try {
      final contenido = await archivo.readAsString();
      return await _enviarCSVAlBackend(contenido, idParticipante);
    } catch (e) {
      throw Exception('Error al procesar archivo CSV: $e');
    }
  }

  // Cargar datos desde bytes CSV (para web) usando endpoint de importación
  Future<ResultadoCargaDatos> cargarDatosCSVBytes(
    List<int> bytes,
    int idParticipante,
  ) async {
    try {
      final contenido = String.fromCharCodes(bytes);
      return await _enviarCSVAlBackend(contenido, idParticipante);
    } catch (e) {
      throw Exception('Error al procesar archivo CSV: $e');
    }
  }

  // Enviar archivo CSV al backend usando multipart form
  Future<ResultadoCargaDatos> _enviarCSVAlBackend(
    String contenidoCSV,
    int idParticipante,
  ) async {
    try {
      final uri = Uri.parse('$baseUrl$_endpoint/importar/$idParticipante');
      final request = http.MultipartRequest('POST', uri);
      
      // Añadir headers
      request.headers.addAll({
        'Accept': 'application/json',
      });

      // Añadir archivo CSV como parte del formulario
      request.files.add(
        http.MultipartFile.fromString(
          'archivo_csv', // nombre del campo esperado por el backend
          contenidoCSV,
          filename: 'datos_consumo.csv',
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        
        // Crear ResultadoCargaDatos a partir de la respuesta del backend
        return ResultadoCargaDatos(
          registrosProcesados: responseData['registrosProcesados'] ?? 0,
          registrosValidos: responseData['registrosValidos'] ?? 0,
          registrosInvalidos: responseData['registrosInvalidos'] ?? 0,
          errores: List<String>.from(responseData['errores'] ?? []),
          datosValidos: [], // El backend no necesita devolver los datos
        );
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Error del servidor: ${errorData['message'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al enviar archivo CSV: $e');
    }
  }







  // Calcular estadísticas localmente
  EstadisticasConsumo calcularEstadisticas(
    List<RegistroConsumo> datos,
    int idParticipante,
    DateTime fechaInicio,
    DateTime fechaFin,
  ) {
    if (datos.isEmpty) {
      return EstadisticasConsumo(
        idParticipante: idParticipante,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
        consumoTotal: 0.0,
        consumoPromedio: 0.0,
        consumoMaximo: 0.0,
        consumoMinimo: 0.0,
        totalRegistros: 0,
        registrosAnomalos: 0,
      );
    }

    final consumos = datos.map((d) => d.consumoEnergia).toList();
    final total = consumos.fold(0.0, (sum, consumo) => sum + consumo);
    final promedio = total / consumos.length;
    final maximo = consumos.reduce((a, b) => a > b ? a : b);
    final minimo = consumos.reduce((a, b) => a < b ? a : b);
    final anomalos = datos.where((d) => _esAnomalo(d)).length;

    return EstadisticasConsumo(
      idParticipante: idParticipante,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
      consumoTotal: total,
      consumoPromedio: promedio,
      consumoMaximo: maximo,
      consumoMinimo: minimo,
      totalRegistros: datos.length,
      registrosAnomalos: anomalos,
    );
  }

  // Función auxiliar para detectar anomalías
  bool _esAnomalo(RegistroConsumo registro) {
    return registro.consumoEnergia < 0 || registro.consumoEnergia > 50;
  }

  // Detectar anomalías localmente
  List<RegistroConsumo> detectarAnomalias(List<RegistroConsumo> datos) {
    return datos.where((registro) => _esAnomalo(registro)).toList();
  }

  // Actualizar registro de consumo
  Future<RegistroConsumo> actualizarRegistro(int id, RegistroConsumo registro) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$_endpoint/$id'),
        headers: getHeaders(),
        body: json.encode(registro.toJson()),
      );

      if (response.statusCode == 200) {
        return RegistroConsumo.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al actualizar registro: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Eliminar registro de consumo
  Future<void> eliminarRegistro(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$_endpoint/$id'),
        headers: getHeaders(),
      );

      if (response.statusCode != 200) {
        throw Exception('Error al eliminar registro: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Eliminar todos los registros de consumo de un participante
  Future<void> eliminarTodosRegistrosParticipante(int idParticipante) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$_endpoint/participante/$idParticipante'),
        headers: getHeaders(),
      );

      if (response.statusCode != 200) {
        throw Exception('Error al eliminar registros: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Método auxiliar para obtener headers
  Map<String, String> getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }
} 