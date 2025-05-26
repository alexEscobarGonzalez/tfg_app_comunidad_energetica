import 'package:json_annotation/json_annotation.dart';

part 'resultado_simulacion.g.dart';

@JsonSerializable()
class ResultadoSimulacion {
  final int? idResultado;
  final DateTime? fechaCreacion;
  final double? costeTotalEnergia_eur;
  final double? ahorroTotal_eur;
  final double? ingresoTotalExportacion_eur;
  final double? paybackPeriod_anios;
  final double? roi_pct;
  final double? tasaAutoconsumoSCR_pct;
  final double? tasaAutosuficienciaSSR_pct;
  final double? energiaTotalImportada_kWh;
  final double? energiaTotalExportada_kWh;
  final double? reduccionCO2_kg;
  final int? idSimulacion;

  ResultadoSimulacion({
    this.idResultado,
    this.fechaCreacion,
    this.costeTotalEnergia_eur,
    this.ahorroTotal_eur,
    this.ingresoTotalExportacion_eur,
    this.paybackPeriod_anios,
    this.roi_pct,
    this.tasaAutoconsumoSCR_pct,
    this.tasaAutosuficienciaSSR_pct,
    this.energiaTotalImportada_kWh,
    this.energiaTotalExportada_kWh,
    this.reduccionCO2_kg,
    this.idSimulacion,
  });

  factory ResultadoSimulacion.fromJson(Map<String, dynamic> json) => _$ResultadoSimulacionFromJson(json);
  Map<String, dynamic> toJson() => _$ResultadoSimulacionToJson(this);
}
