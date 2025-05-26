// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resultado_simulacion_activo_almacenamiento.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResultadoSimulacionActivoAlmacenamiento
_$ResultadoSimulacionActivoAlmacenamientoFromJson(Map<String, dynamic> json) =>
    ResultadoSimulacionActivoAlmacenamiento(
      idResultadoActivoAlm: (json['idResultadoActivoAlm'] as num?)?.toInt(),
      energiaTotalCargada_kWh:
          (json['energiaTotalCargada_kWh'] as num?)?.toDouble(),
      energiaTotalDescargada_kWh:
          (json['energiaTotalDescargada_kWh'] as num?)?.toDouble(),
      ciclosEquivalentes: (json['ciclosEquivalentes'] as num?)?.toDouble(),
      perdidasEficiencia_kWh:
          (json['perdidasEficiencia_kWh'] as num?)?.toDouble(),
      socMedio_pct: (json['socMedio_pct'] as num?)?.toDouble(),
      socMin_pct: (json['socMin_pct'] as num?)?.toDouble(),
      socMax_pct: (json['socMax_pct'] as num?)?.toDouble(),
      degradacionEstimada_pct:
          (json['degradacionEstimada_pct'] as num?)?.toDouble(),
      throughputTotal_kWh: (json['throughputTotal_kWh'] as num?)?.toDouble(),
      idResultadoSimulacion: (json['idResultadoSimulacion'] as num?)?.toInt(),
      idActivoAlmacenamiento: (json['idActivoAlmacenamiento'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ResultadoSimulacionActivoAlmacenamientoToJson(
  ResultadoSimulacionActivoAlmacenamiento instance,
) => <String, dynamic>{
  'idResultadoActivoAlm': instance.idResultadoActivoAlm,
  'energiaTotalCargada_kWh': instance.energiaTotalCargada_kWh,
  'energiaTotalDescargada_kWh': instance.energiaTotalDescargada_kWh,
  'ciclosEquivalentes': instance.ciclosEquivalentes,
  'perdidasEficiencia_kWh': instance.perdidasEficiencia_kWh,
  'socMedio_pct': instance.socMedio_pct,
  'socMin_pct': instance.socMin_pct,
  'socMax_pct': instance.socMax_pct,
  'degradacionEstimada_pct': instance.degradacionEstimada_pct,
  'throughputTotal_kWh': instance.throughputTotal_kWh,
  'idResultadoSimulacion': instance.idResultadoSimulacion,
  'idActivoAlmacenamiento': instance.idActivoAlmacenamiento,
};
