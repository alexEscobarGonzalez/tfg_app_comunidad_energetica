import 'package:json_annotation/json_annotation.dart';

part 'usuario.g.dart';

@JsonSerializable()
class Usuario {
  final int idUsuario;
  final String nombre;
  final String correo;

  Usuario({
    required this.idUsuario,
    required this.nombre,
    required this.correo,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) => _$UsuarioFromJson(json);
  Map<String, dynamic> toJson() => _$UsuarioToJson(this);
} 