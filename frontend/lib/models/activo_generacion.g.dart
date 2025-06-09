// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activo_generacion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActivoGeneracion _$ActivoGeneracionFromJson(Map<String, dynamic> json) =>
    ActivoGeneracion(
      idActivoGeneracion: (json['idActivoGeneracion'] as num).toInt(),
      nombreDescriptivo: json['nombreDescriptivo'] as String,
      fechaInstalacion: _dateFromJson(json['fechaInstalacion'] as String),
      costeInstalacion_eur: (json['costeInstalacion_eur'] as num).toDouble(),
      vidaUtil_anios: (json['vidaUtil_anios'] as num).toInt(),
      latitud: (json['latitud'] as num).toDouble(),
      longitud: (json['longitud'] as num).toDouble(),
      potenciaNominal_kWp: (json['potenciaNominal_kWp'] as num).toDouble(),
      idComunidadEnergetica: (json['idComunidadEnergetica'] as num).toInt(),
      tipo_activo: _tipoActivoFromJson(json['tipo_activo'] as String),
      inclinacionGrados: _numberToString(json['inclinacionGrados']),
      azimutGrados: _numberToString(json['azimutGrados']),
      tecnologiaPanel: json['tecnologiaPanel'] as String?,
      perdidaSistema: _numberToString(json['perdidaSistema']),
      posicionMontaje: json['posicionMontaje'] as String?,
      curvaPotencia: json['curvaPotencia'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ActivoGeneracionToJson(ActivoGeneracion instance) =>
    <String, dynamic>{
      'idActivoGeneracion': instance.idActivoGeneracion,
      'nombreDescriptivo': instance.nombreDescriptivo,
      'fechaInstalacion': _dateToJson(instance.fechaInstalacion),
      'costeInstalacion_eur': instance.costeInstalacion_eur,
      'vidaUtil_anios': instance.vidaUtil_anios,
      'latitud': instance.latitud,
      'longitud': instance.longitud,
      'potenciaNominal_kWp': instance.potenciaNominal_kWp,
      'idComunidadEnergetica': instance.idComunidadEnergetica,
      'tipo_activo': _tipoActivoToJson(instance.tipo_activo),
      'inclinacionGrados': _stringToNumber(instance.inclinacionGrados),
      'azimutGrados': _stringToNumber(instance.azimutGrados),
      'tecnologiaPanel': instance.tecnologiaPanel,
      'perdidaSistema': _stringToNumber(instance.perdidaSistema),
      'posicionMontaje': instance.posicionMontaje,
      'curvaPotencia': instance.curvaPotencia,
    };
