import 'package:json_annotation/json_annotation.dart';

part 'resultado_simulacion_activo_almacenamiento.g.dart';

@JsonSerializable()
class ResultadoSimulacionActivoAlmacenamiento {
  final int? idResultadoActivoAlm;
  final double? energiaTotalCargada_kWh;
  final double? energiaTotalDescargada_kWh;
  final double? ciclosEquivalentes;
  final double? perdidasEficiencia_kWh;
  final double? socMedio_pct;
  final double? socMin_pct;
  final double? socMax_pct;
  final double? degradacionEstimada_pct;
  final double? throughputTotal_kWh;
  final int? idResultadoSimulacion;
  final int? idActivoAlmacenamiento;

  ResultadoSimulacionActivoAlmacenamiento({
    this.idResultadoActivoAlm,
    this.energiaTotalCargada_kWh,
    this.energiaTotalDescargada_kWh,
    this.ciclosEquivalentes,
    this.perdidasEficiencia_kWh,
    this.socMedio_pct,
    this.socMin_pct,
    this.socMax_pct,
    this.degradacionEstimada_pct,
    this.throughputTotal_kWh,
    this.idResultadoSimulacion,
    this.idActivoAlmacenamiento,
  });

  factory ResultadoSimulacionActivoAlmacenamiento.fromJson(Map<String, dynamic> json) => _$ResultadoSimulacionActivoAlmacenamientoFromJson(json);
  Map<String, dynamic> toJson() => _$ResultadoSimulacionActivoAlmacenamientoToJson(this);
}
