import 'package:json_annotation/json_annotation.dart';
import 'registro_consumo.dart';

part 'estadisticas_consumo.g.dart';

@JsonSerializable()
class EstadisticasConsumo {
  final int idParticipante;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final double consumoTotal;
  final double consumoPromedio;
  final double consumoMaximo;
  final double consumoMinimo;
  final int totalRegistros;
  final int registrosAnomalos;

  EstadisticasConsumo({
    required this.idParticipante,
    required this.fechaInicio,
    required this.fechaFin,
    required this.consumoTotal,
    required this.consumoPromedio,
    required this.consumoMaximo,
    required this.consumoMinimo,
    required this.totalRegistros,
    required this.registrosAnomalos,
  });

  factory EstadisticasConsumo.fromJson(Map<String, dynamic> json) =>
      _$EstadisticasConsumoFromJson(json);

  Map<String, dynamic> toJson() => _$EstadisticasConsumoToJson(this);
}

@JsonSerializable()
class ResultadoCargaDatos {
  final int registrosProcesados;
  final int registrosValidos;
  final int registrosInvalidos;
  final List<String> errores;
  final List<RegistroConsumo> datosValidos;

  ResultadoCargaDatos({
    required this.registrosProcesados,
    required this.registrosValidos,
    required this.registrosInvalidos,
    required this.errores,
    required this.datosValidos,
  });

  factory ResultadoCargaDatos.fromJson(Map<String, dynamic> json) =>
      _$ResultadoCargaDatosFromJson(json);

  Map<String, dynamic> toJson() => _$ResultadoCargaDatosToJson(this);
} 