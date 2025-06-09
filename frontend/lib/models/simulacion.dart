import 'package:frontend/models/enums/estado_simulacion.dart';
import 'package:frontend/models/enums/tipo_estrategia_excedentes.dart';

class Simulacion {
  final int idSimulacion;
  final String nombreSimulacion;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final int tiempo_medicion; // Intervalo de tiempo para las mediciones (en minutos)
  final EstadoSimulacion estado;
  final TipoEstrategiaExcedentes tipoEstrategiaExcedentes;
  final int idUsuario_creador;
  final int idComunidadEnergetica;

  Simulacion({
    required this.idSimulacion,
    required this.nombreSimulacion,
    required this.fechaInicio,
    required this.fechaFin,
    required this.tiempo_medicion,
    this.estado = EstadoSimulacion.PENDIENTE,
    required this.tipoEstrategiaExcedentes,
    required this.idUsuario_creador,
    required this.idComunidadEnergetica,
  });

  factory Simulacion.fromJson(Map<String, dynamic> json) {
    return Simulacion(
      idSimulacion: json['idSimulacion'] ?? 0,
      nombreSimulacion: json['nombreSimulacion'] ?? '',
      fechaInicio: DateTime.parse(json['fechaInicio']),
      fechaFin: DateTime.parse(json['fechaFin']),
      tiempo_medicion: json['tiempo_medicion'] ?? 60,
      estado: estadoSimulacionFromString(json['estado'] ?? 'PENDIENTE'),
      tipoEstrategiaExcedentes: tipoEstrategiaExcedentesFromString(json['tipoEstrategiaExcedentes']),
      idUsuario_creador: json['idUsuario_creador'] ?? 0,
      idComunidadEnergetica: json['idComunidadEnergetica'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idSimulacion': idSimulacion,
      'nombreSimulacion': nombreSimulacion,
      'fechaInicio': fechaInicio.toIso8601String(),
      'fechaFin': fechaFin.toIso8601String(),
      'tiempo_medicion': tiempo_medicion,
      'estado': estado.name,
      'tipoEstrategiaExcedentes': tipoEstrategiaExcedentes.toBackendString(),
      'idUsuario_creador': idUsuario_creador,
      'idComunidadEnergetica': idComunidadEnergetica,
    };
  }
}