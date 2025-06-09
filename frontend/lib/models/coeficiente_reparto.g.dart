// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coeficiente_reparto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CoeficienteReparto _$CoeficienteRepartoFromJson(Map<String, dynamic> json) =>
    CoeficienteReparto(
      idCoeficienteReparto: (json['idCoeficienteReparto'] as num).toInt(),
      tipoReparto: _tipoRepartoFromJson(json['tipoReparto'] as String),
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
      'tipoReparto': _tipoRepartoToJson(instance.tipoReparto),
      'parametros': instance.parametros,
      'idParticipante': instance.idParticipante,
      'participante': instance.participante?.toJson(),
    };
