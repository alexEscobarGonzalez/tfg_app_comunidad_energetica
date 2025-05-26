// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resultado_simulacion_activo_generacion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResultadoSimulacionActivoGeneracion
_$ResultadoSimulacionActivoGeneracionFromJson(Map<String, dynamic> json) =>
    ResultadoSimulacionActivoGeneracion(
      idResultadoActivoGen: (json['idResultadoActivoGen'] as num?)?.toInt(),
      energiaTotalGenerada_kWh:
          (json['energiaTotalGenerada_kWh'] as num?)?.toDouble(),
      factorCapacidad_pct: (json['factorCapacidad_pct'] as num?)?.toDouble(),
      performanceRatio_pct: (json['performanceRatio_pct'] as num?)?.toDouble(),
      horasOperacionEquivalentes:
          (json['horasOperacionEquivalentes'] as num?)?.toDouble(),
      idResultadoSimulacion: (json['idResultadoSimulacion'] as num?)?.toInt(),
      idActivoGeneracion: (json['idActivoGeneracion'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ResultadoSimulacionActivoGeneracionToJson(
  ResultadoSimulacionActivoGeneracion instance,
) => <String, dynamic>{
  'idResultadoActivoGen': instance.idResultadoActivoGen,
  'energiaTotalGenerada_kWh': instance.energiaTotalGenerada_kWh,
  'factorCapacidad_pct': instance.factorCapacidad_pct,
  'performanceRatio_pct': instance.performanceRatio_pct,
  'horasOperacionEquivalentes': instance.horasOperacionEquivalentes,
  'idResultadoSimulacion': instance.idResultadoSimulacion,
  'idActivoGeneracion': instance.idActivoGeneracion,
};
