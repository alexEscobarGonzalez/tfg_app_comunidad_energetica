import 'package:json_annotation/json_annotation.dart';

part 'datos_ambientales.g.dart';

@JsonSerializable()
class DatosAmbientales {
  final int? idRegistro;
  final DateTime? timestamp;
  final String? fuenteDatos;
  final double? radiacionGlobalHoriz_Wh_m2;
  final double? temperaturaAmbiente_C;
  final double? velocidadViento_m_s;
  final int? idSimulacion;

  DatosAmbientales({
    this.idRegistro,
    this.timestamp,
    this.fuenteDatos,
    this.radiacionGlobalHoriz_Wh_m2,
    this.temperaturaAmbiente_C,
    this.velocidadViento_m_s,
    this.idSimulacion,
  });

  factory DatosAmbientales.fromJson(Map<String, dynamic> json) => _$DatosAmbientalesFromJson(json);
  Map<String, dynamic> toJson() => _$DatosAmbientalesToJson(this);
}
