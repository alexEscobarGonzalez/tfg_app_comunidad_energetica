import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/models/simulacion.dart';
import 'package:frontend/models/resultado_simulacion.dart';
import 'package:frontend/models/resultado_simulacion_participante.dart';
import 'package:frontend/models/resultado_simulacion_activo_generacion.dart';
import 'package:frontend/models/resultado_simulacion_activo_almacenamiento.dart';

class SimulacionApiService {
  static const String baseUrl = 'http://localhost:8000';

  // Crear una nueva simulación
  static Future<Simulacion?> crearSimulacion(Simulacion simulacion) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/simulaciones'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(simulacion.toJson()),
      );

      if (response.statusCode == 200) {
        return Simulacion.fromJson(json.decode(response.body));
      }
      return null;
    } catch (e) {
      print('Error creando simulación: $e');
      return null;
    }
  }

  // Obtener todas las simulaciones de una comunidad
  static Future<List<Simulacion>> obtenerSimulacionesComunidad(int idComunidad) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/simulaciones/comunidad/$idComunidad'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Simulacion.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Error obteniendo simulaciones: $e');
      return [];
    }
  }

  // Obtener una simulación por ID
  static Future<Simulacion?> obtenerSimulacion(int idSimulacion) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/simulaciones/$idSimulacion'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return Simulacion.fromJson(json.decode(response.body));
      }
      return null;
    } catch (e) {
      print('Error obteniendo simulación: $e');
      return null;
    }
  }

  // Ejecutar una simulación
  static Future<bool> ejecutarSimulacion(int idSimulacion) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/simulaciones/$idSimulacion/ejecutar'),
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 202;
    } catch (e) {
      print('Error ejecutando simulación: $e');
      return false;
    }
  }

  // Cancelar una simulación
  static Future<bool> cancelarSimulacion(int idSimulacion) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/simulaciones/$idSimulacion/cancelar'),
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error cancelando simulación: $e');
      return false;
    }
  }

  // Obtener resultado general de simulación
  static Future<ResultadoSimulacion?> obtenerResultadoSimulacion(int idSimulacion) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/resultados-simulacion/simulacion/$idSimulacion'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return ResultadoSimulacion.fromJson(json.decode(response.body));
      }
      return null;
    } catch (e) {
      print('Error obteniendo resultado de simulación: $e');
      return null;
    }
  }

  // Obtener resultados por participante
  static Future<List<ResultadoSimulacionParticipante>> obtenerResultadosParticipantes(int idSimulacion) async {
    try {
      // Primero obtenemos el resultado general para conseguir su ID
      final resultadoGeneral = await obtenerResultadoSimulacion(idSimulacion);
      if (resultadoGeneral?.idResultado == null) {
        return [];
      }

      final response = await http.get(
        Uri.parse('$baseUrl/resultados-simulacion-participante/resultado/${resultadoGeneral!.idResultado}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => ResultadoSimulacionParticipante.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Error obteniendo resultados de participantes: $e');
      return [];
    }
  }

  // Obtener resultados de activos de generación
  static Future<List<ResultadoSimulacionActivoGeneracion>> obtenerResultadosActivosGeneracion(int idSimulacion) async {
    try {
      // Primero obtenemos el resultado general para conseguir su ID
      final resultadoGeneral = await obtenerResultadoSimulacion(idSimulacion);
      if (resultadoGeneral?.idResultado == null) {
        return [];
      }

      final response = await http.get(
        Uri.parse('$baseUrl/resultados-simulacion-activo-generacion/simulacion/${resultadoGeneral!.idResultado}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => ResultadoSimulacionActivoGeneracion.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Error obteniendo resultados de activos de generación: $e');
      return [];
    }
  }

  // Obtener resultados de activos de almacenamiento
  static Future<List<ResultadoSimulacionActivoAlmacenamiento>> obtenerResultadosActivosAlmacenamiento(int idSimulacion) async {
    try {
      // Primero obtenemos el resultado general para conseguir su ID
      final resultadoGeneral = await obtenerResultadoSimulacion(idSimulacion);
      if (resultadoGeneral?.idResultado == null) {
        return [];
      }

      final response = await http.get(
        Uri.parse('$baseUrl/resultados-activos-almacenamiento/resultado-simulacion/${resultadoGeneral!.idResultado}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => ResultadoSimulacionActivoAlmacenamiento.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Error obteniendo resultados de activos de almacenamiento: $e');
      return [];
    }
  }

  // Actualizar una simulación
  static Future<Simulacion?> actualizarSimulacion(Simulacion simulacion) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/simulaciones/${simulacion.idSimulacion}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(simulacion.toJson()),
      );

      if (response.statusCode == 200) {
        return Simulacion.fromJson(json.decode(response.body));
      }
      return null;
    } catch (e) {
      print('Error actualizando simulación: $e');
      return null;
    }
  }

  // Eliminar una simulación
  static Future<bool> eliminarSimulacion(int idSimulacion) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/simulaciones/$idSimulacion'),
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error eliminando simulación: $e');
      return false;
    }
  }

  // Obtener progreso de simulación (para monitoreo en tiempo real)
  static Future<Map<String, dynamic>?> obtenerProgresoSimulacion(int idSimulacion) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/simulaciones/$idSimulacion/progreso'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Error obteniendo progreso de simulación: $e');
      return null;
    }
  }
} 