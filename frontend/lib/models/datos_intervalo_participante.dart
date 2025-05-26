import 'package:json_annotation/json_annotation.dart';

part 'datos_intervalo_participante.g.dart';

@JsonSerializable()
class DatosIntervaloParticipante {
  final int? idDatosIntervaloParticipante;
  final DateTime? timestamp;
  final double? consumoReal_kWh;
  final double? autoconsumo_kWh;
  final double? energiaRecibidaReparto_kWh;
  final double? energiaAlmacenamiento_kWh;
  final double? energiaDiferencia_kWh;
  final double? excedenteVertidoCompensado_kWh;
  final double? precioImportacionIntervalo;
  final double? precioExportacionIntervalo;
  final int? idResultadoParticipante;

  DatosIntervaloParticipante({
    this.idDatosIntervaloParticipante,
    this.timestamp,
    this.consumoReal_kWh,
    this.autoconsumo_kWh,
    this.energiaRecibidaReparto_kWh,
    this.energiaAlmacenamiento_kWh,
    this.energiaDiferencia_kWh,
    this.excedenteVertidoCompensado_kWh,
    this.precioImportacionIntervalo,
    this.precioExportacionIntervalo,
    this.idResultadoParticipante,
  });

  factory DatosIntervaloParticipante.fromJson(Map<String, dynamic> json) => _$DatosIntervaloParticipanteFromJson(json);
  Map<String, dynamic> toJson() => _$DatosIntervaloParticipanteToJson(this);
}
