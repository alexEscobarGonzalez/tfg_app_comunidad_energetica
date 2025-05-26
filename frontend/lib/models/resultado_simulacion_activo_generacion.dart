import 'package:json_annotation/json_annotation.dart';

part 'resultado_simulacion_activo_generacion.g.dart';

@JsonSerializable()
class ResultadoSimulacionActivoGeneracion {
  final int? idResultadoActivoGen;
  final double? energiaTotalGenerada_kWh;
  final double? factorCapacidad_pct;
  final double? performanceRatio_pct;
  final double? horasOperacionEquivalentes;
  final int? idResultadoSimulacion;
  final int? idActivoGeneracion;

  ResultadoSimulacionActivoGeneracion({
    this.idResultadoActivoGen,
    this.energiaTotalGenerada_kWh,
    this.factorCapacidad_pct,
    this.performanceRatio_pct,
    this.horasOperacionEquivalentes,
    this.idResultadoSimulacion,
    this.idActivoGeneracion,
  });

  factory ResultadoSimulacionActivoGeneracion.fromJson(Map<String, dynamic> json) => _$ResultadoSimulacionActivoGeneracionFromJson(json);
  Map<String, dynamic> toJson() => _$ResultadoSimulacionActivoGeneracionToJson(this);
}
