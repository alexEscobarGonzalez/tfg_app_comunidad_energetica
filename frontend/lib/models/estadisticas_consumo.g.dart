// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'estadisticas_consumo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EstadisticasConsumo _$EstadisticasConsumoFromJson(Map<String, dynamic> json) =>
    EstadisticasConsumo(
      idParticipante: (json['idParticipante'] as num).toInt(),
      fechaInicio: DateTime.parse(json['fechaInicio'] as String),
      fechaFin: DateTime.parse(json['fechaFin'] as String),
      consumoTotal: (json['consumoTotal'] as num).toDouble(),
      consumoPromedio: (json['consumoPromedio'] as num).toDouble(),
      consumoMaximo: (json['consumoMaximo'] as num).toDouble(),
      consumoMinimo: (json['consumoMinimo'] as num).toDouble(),
      totalRegistros: (json['totalRegistros'] as num).toInt(),
      registrosAnomalos: (json['registrosAnomalos'] as num).toInt(),
    );

Map<String, dynamic> _$EstadisticasConsumoToJson(
  EstadisticasConsumo instance,
) => <String, dynamic>{
  'idParticipante': instance.idParticipante,
  'fechaInicio': instance.fechaInicio.toIso8601String(),
  'fechaFin': instance.fechaFin.toIso8601String(),
  'consumoTotal': instance.consumoTotal,
  'consumoPromedio': instance.consumoPromedio,
  'consumoMaximo': instance.consumoMaximo,
  'consumoMinimo': instance.consumoMinimo,
  'totalRegistros': instance.totalRegistros,
  'registrosAnomalos': instance.registrosAnomalos,
};

ResultadoCargaDatos _$ResultadoCargaDatosFromJson(Map<String, dynamic> json) =>
    ResultadoCargaDatos(
      registrosProcesados: (json['registrosProcesados'] as num).toInt(),
      registrosValidos: (json['registrosValidos'] as num).toInt(),
      registrosInvalidos: (json['registrosInvalidos'] as num).toInt(),
      errores:
          (json['errores'] as List<dynamic>).map((e) => e as String).toList(),
      datosValidos:
          (json['datosValidos'] as List<dynamic>)
              .map((e) => RegistroConsumo.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$ResultadoCargaDatosToJson(
  ResultadoCargaDatos instance,
) => <String, dynamic>{
  'registrosProcesados': instance.registrosProcesados,
  'registrosValidos': instance.registrosValidos,
  'registrosInvalidos': instance.registrosInvalidos,
  'errores': instance.errores,
  'datosValidos': instance.datosValidos,
};
