// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comunidad_energetica.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ComunidadEnergetica _$ComunidadEnergeticaFromJson(Map<String, dynamic> json) =>
    ComunidadEnergetica(
      idComunidadEnergetica: (json['idComunidadEnergetica'] as num).toInt(),
      nombre: json['nombre'] as String,
      latitud: (json['latitud'] as num).toDouble(),
      longitud: (json['longitud'] as num).toDouble(),
      tipoEstrategiaExcedentes: _tipoEstrategiaExcedentesFromJson(
        json['tipoEstrategiaExcedentes'],
      ),
      idUsuario: (json['idUsuario'] as num).toInt(),
    );

Map<String, dynamic> _$ComunidadEnergeticaToJson(
  ComunidadEnergetica instance,
) => <String, dynamic>{
  'idComunidadEnergetica': instance.idComunidadEnergetica,
  'nombre': instance.nombre,
  'latitud': instance.latitud,
  'longitud': instance.longitud,
  'tipoEstrategiaExcedentes': _tipoEstrategiaExcedentesToJson(
    instance.tipoEstrategiaExcedentes,
  ),
  'idUsuario': instance.idUsuario,
};
