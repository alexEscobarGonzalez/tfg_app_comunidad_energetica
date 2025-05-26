import 'package:json_annotation/json_annotation.dart';

part 'registro_consumo.g.dart';

@JsonSerializable()
class RegistroConsumo {
  final int idRegistroConsumo;
  final DateTime timestamp;
  final double consumoEnergia;
  final int idParticipante;

  RegistroConsumo({
    required this.idRegistroConsumo,
    required this.timestamp,
    required this.consumoEnergia,
    required this.idParticipante,
  });

  factory RegistroConsumo.fromJson(Map<String, dynamic> json) =>
      _$RegistroConsumoFromJson(json);

  Map<String, dynamic> toJson() => _$RegistroConsumoToJson(this);

}