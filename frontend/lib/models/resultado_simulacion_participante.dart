import 'package:json_annotation/json_annotation.dart';

part 'resultado_simulacion_participante.g.dart';

@JsonSerializable()
class ResultadoSimulacionParticipante {
  final int? idResultadoParticipante;
  final double? costeNetoParticipante_eur;
  final double? ahorroParticipante_eur;
  final double? ahorroParticipante_pct;
  final double? energiaAutoconsumidaDirecta_kWh;
  final double? energiaRecibidaRepartoConsumida_kWh;
  final double? tasaAutoconsumoSCR_pct;
  final double? tasaAutosuficienciaSSR_pct;
  final double? consumo_kWh;
  final int? idResultadoSimulacion;
  final int? idParticipante;

  ResultadoSimulacionParticipante({
    this.idResultadoParticipante,
    this.costeNetoParticipante_eur,
    this.ahorroParticipante_eur,
    this.ahorroParticipante_pct,
    this.energiaAutoconsumidaDirecta_kWh,
    this.energiaRecibidaRepartoConsumida_kWh,
    this.tasaAutoconsumoSCR_pct,
    this.tasaAutosuficienciaSSR_pct,
    this.consumo_kWh,
    this.idResultadoSimulacion,
    this.idParticipante,
  });

  factory ResultadoSimulacionParticipante.fromJson(Map<String, dynamic> json) => _$ResultadoSimulacionParticipanteFromJson(json);
  Map<String, dynamic> toJson() => _$ResultadoSimulacionParticipanteToJson(this);
}
