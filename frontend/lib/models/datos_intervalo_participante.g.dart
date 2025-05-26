// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'datos_intervalo_participante.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DatosIntervaloParticipante _$DatosIntervaloParticipanteFromJson(
  Map<String, dynamic> json,
) => DatosIntervaloParticipante(
  idDatosIntervaloParticipante:
      (json['idDatosIntervaloParticipante'] as num?)?.toInt(),
  timestamp:
      json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
  consumoReal_kWh: (json['consumoReal_kWh'] as num?)?.toDouble(),
  autoconsumo_kWh: (json['autoconsumo_kWh'] as num?)?.toDouble(),
  energiaRecibidaReparto_kWh:
      (json['energiaRecibidaReparto_kWh'] as num?)?.toDouble(),
  energiaAlmacenamiento_kWh:
      (json['energiaAlmacenamiento_kWh'] as num?)?.toDouble(),
  energiaDiferencia_kWh: (json['energiaDiferencia_kWh'] as num?)?.toDouble(),
  excedenteVertidoCompensado_kWh:
      (json['excedenteVertidoCompensado_kWh'] as num?)?.toDouble(),
  precioImportacionIntervalo:
      (json['precioImportacionIntervalo'] as num?)?.toDouble(),
  precioExportacionIntervalo:
      (json['precioExportacionIntervalo'] as num?)?.toDouble(),
  idResultadoParticipante: (json['idResultadoParticipante'] as num?)?.toInt(),
);

Map<String, dynamic> _$DatosIntervaloParticipanteToJson(
  DatosIntervaloParticipante instance,
) => <String, dynamic>{
  'idDatosIntervaloParticipante': instance.idDatosIntervaloParticipante,
  'timestamp': instance.timestamp?.toIso8601String(),
  'consumoReal_kWh': instance.consumoReal_kWh,
  'autoconsumo_kWh': instance.autoconsumo_kWh,
  'energiaRecibidaReparto_kWh': instance.energiaRecibidaReparto_kWh,
  'energiaAlmacenamiento_kWh': instance.energiaAlmacenamiento_kWh,
  'energiaDiferencia_kWh': instance.energiaDiferencia_kWh,
  'excedenteVertidoCompensado_kWh': instance.excedenteVertidoCompensado_kWh,
  'precioImportacionIntervalo': instance.precioImportacionIntervalo,
  'precioExportacionIntervalo': instance.precioExportacionIntervalo,
  'idResultadoParticipante': instance.idResultadoParticipante,
};
