import 'package:json_annotation/json_annotation.dart';

part 'participante.g.dart';

@JsonSerializable()
class Participante {
  final int idParticipante;
  final String nombre;
  final int idComunidadEnergetica;

  Participante({
    required this.idParticipante,
    required this.nombre,
    required this.idComunidadEnergetica,
  });

  factory Participante.fromJson(Map<String, dynamic> json) => 
      _$ParticipanteFromJson(json);
  Map<String, dynamic> toJson() => _$ParticipanteToJson(this);
} 