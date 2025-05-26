// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'participante.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Participante _$ParticipanteFromJson(Map<String, dynamic> json) => Participante(
  idParticipante: (json['idParticipante'] as num).toInt(),
  nombre: json['nombre'] as String,
  idComunidadEnergetica: (json['idComunidadEnergetica'] as num).toInt(),
);

Map<String, dynamic> _$ParticipanteToJson(Participante instance) =>
    <String, dynamic>{
      'idParticipante': instance.idParticipante,
      'nombre': instance.nombre,
      'idComunidadEnergetica': instance.idComunidadEnergetica,
    };
