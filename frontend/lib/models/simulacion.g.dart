// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'simulacion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Simulacion _$SimulacionFromJson(Map<String, dynamic> json) => Simulacion(
  idSimulacion: (json['idSimulacion'] as num).toInt(),
  nombreSimulacion: json['nombreSimulacion'] as String,
  fechaInicio: DateTime.parse(json['fechaInicio'] as String),
  fechaFin: DateTime.parse(json['fechaFin'] as String),
  tiempo_medicion: (json['tiempo_medicion'] as num).toInt(),
  estado:
      $enumDecodeNullable(_$EstadoSimulacionEnumMap, json['estado']) ??
      EstadoSimulacion.PENDIENTE,
  tipoEstrategiaExcedentes: $enumDecode(
    _$TipoEstrategiaExcedentesEnumMap,
    json['tipoEstrategiaExcedentes'],
  ),
  idUsuario_creador: (json['idUsuario_creador'] as num).toInt(),
  idComunidadEnergetica: (json['idComunidadEnergetica'] as num).toInt(),
);

Map<String, dynamic> _$SimulacionToJson(Simulacion instance) =>
    <String, dynamic>{
      'idSimulacion': instance.idSimulacion,
      'nombreSimulacion': instance.nombreSimulacion,
      'fechaInicio': instance.fechaInicio.toIso8601String(),
      'fechaFin': instance.fechaFin.toIso8601String(),
      'tiempo_medicion': instance.tiempo_medicion,
      'estado': _$EstadoSimulacionEnumMap[instance.estado]!,
      'tipoEstrategiaExcedentes':
          _$TipoEstrategiaExcedentesEnumMap[instance.tipoEstrategiaExcedentes]!,
      'idUsuario_creador': instance.idUsuario_creador,
      'idComunidadEnergetica': instance.idComunidadEnergetica,
    };

const _$EstadoSimulacionEnumMap = {
  EstadoSimulacion.PENDIENTE: 'PENDIENTE',
  EstadoSimulacion.EJECUTANDO: 'EJECUTANDO',
  EstadoSimulacion.COMPLETADA: 'COMPLETADA',
  EstadoSimulacion.FALLIDA: 'FALLIDA',
};

const _$TipoEstrategiaExcedentesEnumMap = {
  TipoEstrategiaExcedentes.INDIVIDUAL_SIN_EXCEDENTES:
      'INDIVIDUAL_SIN_EXCEDENTES',
  TipoEstrategiaExcedentes.COLECTIVO_SIN_EXCEDENTES: 'COLECTIVO_SIN_EXCEDENTES',
  TipoEstrategiaExcedentes.INDIVIDUAL_EXCEDENTES_COMPENSACION:
      'INDIVIDUAL_EXCEDENTES_COMPENSACION',
  TipoEstrategiaExcedentes.COLECTIVO_EXCEDENTES_COMPENSACION_RED_EXTERNA:
      'COLECTIVO_EXCEDENTES_COMPENSACION_RED_EXTERNA',
};
