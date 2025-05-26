import 'package:frontend/models/enums/tipo_reparto.dart';
import 'package:json_annotation/json_annotation.dart';
import 'participante.dart';

part 'coeficiente_reparto.g.dart';


@JsonSerializable(explicitToJson: true)
class CoeficienteReparto {
  final int idCoeficienteReparto;
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