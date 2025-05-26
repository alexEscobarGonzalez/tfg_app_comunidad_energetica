// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usuario.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Usuario _$UsuarioFromJson(Map<String, dynamic> json) => Usuario(
  idUsuario: (json['idUsuario'] as num).toInt(),
  nombre: json['nombre'] as String,
  correo: json['correo'] as String,
);

Map<String, dynamic> _$UsuarioToJson(Usuario instance) => <String, dynamic>{
  'idUsuario': instance.idUsuario,
  'nombre': instance.nombre,
  'correo': instance.correo,
};
