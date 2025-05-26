// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'datos_ambientales.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DatosAmbientales _$DatosAmbientalesFromJson(Map<String, dynamic> json) =>
    DatosAmbientales(
      idRegistro: (json['idRegistro'] as num?)?.toInt(),
      timestamp:
          json['timestamp'] == null
              ? null
              : DateTime.parse(json['timestamp'] as String),
      fuenteDatos: json['fuenteDatos'] as String?,
      radiacionGlobalHoriz_Wh_m2:
          (json['radiacionGlobalHoriz_Wh_m2'] as num?)?.toDouble(),
      temperaturaAmbiente_C:
          (json['temperaturaAmbiente_C'] as num?)?.toDouble(),
      velocidadViento_m_s: (json['velocidadViento_m_s'] as num?)?.toDouble(),
      idSimulacion: (json['idSimulacion'] as num?)?.toInt(),
    );

Map<String, dynamic> _$DatosAmbientalesToJson(DatosAmbientales instance) =>
    <String, dynamic>{
      'idRegistro': instance.idRegistro,
      'timestamp': instance.timestamp?.toIso8601String(),
      'fuenteDatos': instance.fuenteDatos,
      'radiacionGlobalHoriz_Wh_m2': instance.radiacionGlobalHoriz_Wh_m2,
      'temperaturaAmbiente_C': instance.temperaturaAmbiente_C,
      'velocidadViento_m_s': instance.velocidadViento_m_s,
      'idSimulacion': instance.idSimulacion,
    };
