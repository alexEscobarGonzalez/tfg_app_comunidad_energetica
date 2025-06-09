// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activo_almacenamiento.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActivoAlmacenamiento _$ActivoAlmacenamientoFromJson(
  Map<String, dynamic> json,
) => ActivoAlmacenamiento(
  idActivoAlmacenamiento: (json['idActivoAlmacenamiento'] as num).toInt(),
  nombreDescriptivo: json['nombreDescriptivo'] as String?,
  capacidadNominal_kWh: (json['capacidadNominal_kWh'] as num).toDouble(),
  potenciaMaximaCarga_kW: (json['potenciaMaximaCarga_kW'] as num?)?.toDouble(),
  potenciaMaximaDescarga_kW:
      (json['potenciaMaximaDescarga_kW'] as num?)?.toDouble(),
  eficienciaCicloCompleto_pct:
      (json['eficienciaCicloCompleto_pct'] as num?)?.toDouble(),
  profundidadDescargaMax_pct:
      (json['profundidadDescargaMax_pct'] as num?)?.toDouble(),
  idComunidadEnergetica: (json['idComunidadEnergetica'] as num).toInt(),
);

Map<String, dynamic> _$ActivoAlmacenamientoToJson(
  ActivoAlmacenamiento instance,
) => <String, dynamic>{
  'idActivoAlmacenamiento': instance.idActivoAlmacenamiento,
  'nombreDescriptivo': instance.nombreDescriptivo,
  'capacidadNominal_kWh': instance.capacidadNominal_kWh,
  'potenciaMaximaCarga_kW': instance.potenciaMaximaCarga_kW,
  'potenciaMaximaDescarga_kW': instance.potenciaMaximaDescarga_kW,
  'eficienciaCicloCompleto_pct': instance.eficienciaCicloCompleto_pct,
  'profundidadDescargaMax_pct': instance.profundidadDescargaMax_pct,
  'idComunidadEnergetica': instance.idComunidadEnergetica,
};
