// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resultado_simulacion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResultadoSimulacion _$ResultadoSimulacionFromJson(
  Map<String, dynamic> json,
) => ResultadoSimulacion(
  idResultado: (json['idResultado'] as num?)?.toInt(),
  fechaCreacion:
      json['fechaCreacion'] == null
          ? null
          : DateTime.parse(json['fechaCreacion'] as String),
  costeTotalEnergia_eur: (json['costeTotalEnergia_eur'] as num?)?.toDouble(),
  ahorroTotal_eur: (json['ahorroTotal_eur'] as num?)?.toDouble(),
  ingresoTotalExportacion_eur:
      (json['ingresoTotalExportacion_eur'] as num?)?.toDouble(),
  paybackPeriod_anios: (json['paybackPeriod_anios'] as num?)?.toDouble(),
  roi_pct: (json['roi_pct'] as num?)?.toDouble(),
  tasaAutoconsumoSCR_pct: (json['tasaAutoconsumoSCR_pct'] as num?)?.toDouble(),
  tasaAutosuficienciaSSR_pct:
      (json['tasaAutosuficienciaSSR_pct'] as num?)?.toDouble(),
  energiaTotalImportada_kWh:
      (json['energiaTotalImportada_kWh'] as num?)?.toDouble(),
  energiaTotalExportada_kWh:
      (json['energiaTotalExportada_kWh'] as num?)?.toDouble(),
  reduccionCO2_kg: (json['reduccionCO2_kg'] as num?)?.toDouble(),
  idSimulacion: (json['idSimulacion'] as num?)?.toInt(),
);

Map<String, dynamic> _$ResultadoSimulacionToJson(
  ResultadoSimulacion instance,
) => <String, dynamic>{
  'idResultado': instance.idResultado,
  'fechaCreacion': instance.fechaCreacion?.toIso8601String(),
  'costeTotalEnergia_eur': instance.costeTotalEnergia_eur,
  'ahorroTotal_eur': instance.ahorroTotal_eur,
  'ingresoTotalExportacion_eur': instance.ingresoTotalExportacion_eur,
  'paybackPeriod_anios': instance.paybackPeriod_anios,
  'roi_pct': instance.roi_pct,
  'tasaAutoconsumoSCR_pct': instance.tasaAutoconsumoSCR_pct,
  'tasaAutosuficienciaSSR_pct': instance.tasaAutosuficienciaSSR_pct,
  'energiaTotalImportada_kWh': instance.energiaTotalImportada_kWh,
  'energiaTotalExportada_kWh': instance.energiaTotalExportada_kWh,
  'reduccionCO2_kg': instance.reduccionCO2_kg,
  'idSimulacion': instance.idSimulacion,
};
