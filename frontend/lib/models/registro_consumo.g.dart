// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'registro_consumo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegistroConsumo _$RegistroConsumoFromJson(Map<String, dynamic> json) =>
    RegistroConsumo(
      idRegistroConsumo: (json['idRegistroConsumo'] as num).toInt(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      consumoEnergia: (json['consumoEnergia'] as num).toDouble(),
      idParticipante: (json['idParticipante'] as num).toInt(),
    );

Map<String, dynamic> _$RegistroConsumoToJson(RegistroConsumo instance) =>
    <String, dynamic>{
      'idRegistroConsumo': instance.idRegistroConsumo,
      'timestamp': instance.timestamp.toIso8601String(),
      'consumoEnergia': instance.consumoEnergia,
      'idParticipante': instance.idParticipante,
    };
