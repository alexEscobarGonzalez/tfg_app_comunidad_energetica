import 'package:frontend/models/enums/estado_simulacion.dart';
import 'package:frontend/models/enums/tipo_estrategia_excedentes.dart';
import 'package:json_annotation/json_annotation.dart';

part 'simulacion.g.dart';



@JsonSerializable()
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

  factory Simulacion.fromJson(Map<String, dynamic> json) =>
      _$SimulacionFromJson(json);

  Map<String, dynamic> toJson() => _$SimulacionToJson(this);

}