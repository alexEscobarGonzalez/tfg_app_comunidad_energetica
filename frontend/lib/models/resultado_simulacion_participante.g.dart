// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resultado_simulacion_participante.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResultadoSimulacionParticipante _$ResultadoSimulacionParticipanteFromJson(
  Map<String, dynamic> json,
) => ResultadoSimulacionParticipante(
  idResultadoParticipante: (json['idResultadoParticipante'] as num?)?.toInt(),
  costeNetoParticipante_eur:
      (json['costeNetoParticipante_eur'] as num?)?.toDouble(),
  ahorroParticipante_eur: (json['ahorroParticipante_eur'] as num?)?.toDouble(),
  ahorroParticipante_pct: (json['ahorroParticipante_pct'] as num?)?.toDouble(),
  energiaAutoconsumidaDirecta_kWh:
      (json['energiaAutoconsumidaDirecta_kWh'] as num?)?.toDouble(),
  energiaRecibidaRepartoConsumida_kWh:
      (json['energiaRecibidaRepartoConsumida_kWh'] as num?)?.toDouble(),
  tasaAutoconsumoSCR_pct: (json['tasaAutoconsumoSCR_pct'] as num?)?.toDouble(),
  tasaAutosuficienciaSSR_pct:
      (json['tasaAutosuficienciaSSR_pct'] as num?)?.toDouble(),
  consumo_kWh: (json['consumo_kWh'] as num?)?.toDouble(),
  idResultadoSimulacion: (json['idResultadoSimulacion'] as num?)?.toInt(),
  idParticipante: (json['idParticipante'] as num?)?.toInt(),
);

Map<String, dynamic> _$ResultadoSimulacionParticipanteToJson(
  ResultadoSimulacionParticipante instance,
) => <String, dynamic>{
  'idResultadoParticipante': instance.idResultadoParticipante,
  'costeNetoParticipante_eur': instance.costeNetoParticipante_eur,
  'ahorroParticipante_eur': instance.ahorroParticipante_eur,
  'ahorroParticipante_pct': instance.ahorroParticipante_pct,
  'energiaAutoconsumidaDirecta_kWh': instance.energiaAutoconsumidaDirecta_kWh,
  'energiaRecibidaRepartoConsumida_kWh':
      instance.energiaRecibidaRepartoConsumida_kWh,
  'tasaAutoconsumoSCR_pct': instance.tasaAutoconsumoSCR_pct,
  'tasaAutosuficienciaSSR_pct': instance.tasaAutosuficienciaSSR_pct,
  'consumo_kWh': instance.consumo_kWh,
  'idResultadoSimulacion': instance.idResultadoSimulacion,
  'idParticipante': instance.idParticipante,
};
