// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contrato_autoconsumo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContratoAutoconsumo _$ContratoAutoconsumoFromJson(Map<String, dynamic> json) =>
    ContratoAutoconsumo(
      idContrato: (json['idContrato'] as num).toInt(),
      tipoContrato: $enumDecode(_$TipoContratoEnumMap, json['tipoContrato']),
      precioEnergiaImportacion_eur_kWh:
          (json['precioEnergiaImportacion_eur_kWh'] as num).toDouble(),
      precioCompensacionExcedentes_eur_kWh:
          (json['precioCompensacionExcedentes_eur_kWh'] as num).toDouble(),
      potenciaContratada_kW: (json['potenciaContratada_kW'] as num).toDouble(),
      precioPotenciaContratado_eur_kWh:
          (json['precioPotenciaContratado_eur_kWh'] as num).toDouble(),
      idParticipante: (json['idParticipante'] as num).toInt(),
    );

Map<String, dynamic> _$ContratoAutoconsumoToJson(
  ContratoAutoconsumo instance,
) => <String, dynamic>{
  'idContrato': instance.idContrato,
  'tipoContrato': _$TipoContratoEnumMap[instance.tipoContrato]!,
  'precioEnergiaImportacion_eur_kWh': instance.precioEnergiaImportacion_eur_kWh,
  'precioCompensacionExcedentes_eur_kWh':
      instance.precioCompensacionExcedentes_eur_kWh,
  'potenciaContratada_kW': instance.potenciaContratada_kW,
  'precioPotenciaContratado_eur_kWh': instance.precioPotenciaContratado_eur_kWh,
  'idParticipante': instance.idParticipante,
};

const _$TipoContratoEnumMap = {
  TipoContrato.PVPC: 'PVPC',
  TipoContrato.MERCADO_LIBRE: 'MERCADO_LIBRE',
};
