import 'package:frontend/models/enums/tipo_reparto.dart';
import 'package:json_annotation/json_annotation.dart';
import 'participante.dart';

part 'coeficiente_reparto.g.dart';


@JsonSerializable(explicitToJson: true)
class CoeficienteReparto {
  final int idCoeficienteReparto;
  @JsonKey(fromJson: _tipoRepartoFromJson, toJson: _tipoRepartoToJson)
  final TipoReparto tipoReparto;
  final Map<String, dynamic> parametros;
  final int idParticipante;
  final Participante? participante;

  CoeficienteReparto({
    required this.idCoeficienteReparto,
    required this.tipoReparto,
    required this.parametros,
    required this.idParticipante,
    this.participante,
  });

  factory CoeficienteReparto.fromJson(Map<String, dynamic> json) =>
      _$CoeficienteRepartoFromJson(json);

  Map<String, dynamic> toJson() => _$CoeficienteRepartoToJson(this);
}

// Funciones de conversión para el enum TipoReparto
TipoReparto _tipoRepartoFromJson(String value) {
  switch (value) {
    case 'Reparto Fijo':
      return TipoReparto.REPARTO_FIJO;
    case 'Reparto Programado':
      return TipoReparto.REPARTO_PROGRAMADO;
    default:
      throw ArgumentError('Valor de TipoReparto no reconocido: $value');
  }
}

String _tipoRepartoToJson(TipoReparto tipoReparto) {
  return tipoReparto.value;
}