// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'datos_intervalo_activo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DatosIntervaloActivo _$DatosIntervaloActivoFromJson(
  Map<String, dynamic> json,
) => DatosIntervaloActivo(
  idDatosIntervaloActivo: (json['idDatosIntervaloActivo'] as num?)?.toInt(),
  timestamp:
      json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
  energiaGenerada_kWh: (json['energiaGenerada_kWh'] as num?)?.toDouble(),
  energiaCargada_kWh: (json['energiaCargada_kWh'] as num?)?.toDouble(),
  energiaDescargada_kWh: (json['energiaDescargada_kWh'] as num?)?.toDouble(),
  soC_kWh: (json['soC_kWh'] as num?)?.toDouble(),
  idResultadoActivoGen: (json['idResultadoActivoGen'] as num?)?.toInt(),
  idResultadoActivoAlm: (json['idResultadoActivoAlm'] as num?)?.toInt(),
);

Map<String, dynamic> _$DatosIntervaloActivoToJson(
  DatosIntervaloActivo instance,
) => <String, dynamic>{
  'idDatosIntervaloActivo': instance.idDatosIntervaloActivo,
  'timestamp': instance.timestamp?.toIso8601String(),
  'energiaGenerada_kWh': instance.energiaGenerada_kWh,
  'energiaCargada_kWh': instance.energiaCargada_kWh,
  'energiaDescargada_kWh': instance.energiaDescargada_kWh,
  'soC_kWh': instance.soC_kWh,
  'idResultadoActivoGen': instance.idResultadoActivoGen,
  'idResultadoActivoAlm': instance.idResultadoActivoAlm,
};
