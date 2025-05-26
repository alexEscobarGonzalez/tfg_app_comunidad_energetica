// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activo_generacion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActivoGeneracion _$ActivoGeneracionFromJson(Map<String, dynamic> json) =>
    ActivoGeneracion(
      idActivoGeneracion: (json['idActivoGeneracion'] as num).toInt(),
      nombreDescriptivo: json['nombreDescriptivo'] as String,
      fechaInstalacion: DateTime.parse(json['fechaInstalacion'] as String),
      costeInstalacion_eur: (json['costeInstalacion_eur'] as num).toDouble(),
      vidaUtil_anios: (json['vidaUtil_anios'] as num).toInt(),
      latitud: (json['latitud'] as num).toDouble(),
      longitud: (json['longitud'] as num).toDouble(),
      potenciaNominal_kWp: (json['potenciaNominal_kWp'] as num).toDouble(),
      idComunidadEnergetica: (json['idComunidadEnergetica'] as num).toInt(),
      tipo_activo: $enumDecode(
        _$TipoActivoGeneracionEnumMap,
        json['tipo_activo'],
      ),
      inclinacionGrados: json['inclinacionGrados'] as String?,
      azimutGrados: json['azimutGrados'] as String?,
      tecnologiaPanel: json['tecnologiaPanel'] as String?,
      perdidaSistema: json['perdidaSistema'] as String?,
      posicionMontaje: json['posicionMontaje'] as String?,
      curvaPotencia: json['curvaPotencia'] as String?,
    );

Map<String, dynamic> _$ActivoGeneracionToJson(ActivoGeneracion instance) =>
    <String, dynamic>{
      'idActivoGeneracion': instance.idActivoGeneracion,
      'nombreDescriptivo': instance.nombreDescriptivo,
      'fechaInstalacion': instance.fechaInstalacion.toIso8601String(),
      'costeInstalacion_eur': instance.costeInstalacion_eur,
      'vidaUtil_anios': instance.vidaUtil_anios,
      'latitud': instance.latitud,
      'longitud': instance.longitud,
      'potenciaNominal_kWp': instance.potenciaNominal_kWp,
      'idComunidadEnergetica': instance.idComunidadEnergetica,
      'tipo_activo': _$TipoActivoGeneracionEnumMap[instance.tipo_activo]!,
      'inclinacionGrados': instance.inclinacionGrados,
      'azimutGrados': instance.azimutGrados,
      'tecnologiaPanel': instance.tecnologiaPanel,
      'perdidaSistema': instance.perdidaSistema,
      'posicionMontaje': instance.posicionMontaje,
      'curvaPotencia': instance.curvaPotencia,
    };

const _$TipoActivoGeneracionEnumMap = {
  TipoActivoGeneracion.INSTALACION_FOTOVOLTAICA: 'INSTALACION_FOTOVOLTAICA',
  TipoActivoGeneracion.AEROGENERADOR: 'AEROGENERADOR',
};
