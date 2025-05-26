// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coeficiente_reparto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CoeficienteReparto _$CoeficienteRepartoFromJson(Map<String, dynamic> json) =>
    CoeficienteReparto(
      idCoeficienteReparto: (json['idCoeficienteReparto'] as num).toInt(),
      tipoReparto: $enumDecode(_$TipoRepartoEnumMap, json['tipoReparto']),
      parametros: json['parametros'] as Map<String, dynamic>,
      idParticipante: (json['idParticipante'] as num).toInt(),
      participante:
          json['participante'] == null
              ? null
              : Participante.fromJson(
                json['participante'] as Map<String, dynamic>,
              ),
    );

Map<String, dynamic> _$CoeficienteRepartoToJson(CoeficienteReparto instance) =>
    <String, dynamic>{
      'idCoeficienteReparto': instance.idCoeficienteReparto,
      'tipoReparto': _$TipoRepartoEnumMap[instance.tipoReparto]!,
      'parametros': instance.parametros,
      'idParticipante': instance.idParticipante,
      'participante': instance.participante?.toJson(),
    };

const _$TipoRepartoEnumMap = {
  TipoReparto.REPARTO_FIJO: 'REPARTO_FIJO',
  TipoReparto.REPARTO_PROGRAMADO: 'REPARTO_PROGRAMADO',
};
