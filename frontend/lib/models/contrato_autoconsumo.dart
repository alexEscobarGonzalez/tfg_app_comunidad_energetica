import 'package:json_annotation/json_annotation.dart';
import 'package:frontend/models/enums/tipo_contrato.dart';

part 'contrato_autoconsumo.g.dart';

// Helper para serialización del enum
TipoContrato _tipoContratoFromJson(String tipoStr) {
  switch (tipoStr) {
    case 'PVPC':
      return TipoContrato.PVPC;
    case 'Precio Fijo':
      return TipoContrato.MERCADO_LIBRE;
    default:
      return TipoContrato.PVPC; // Valor por defecto
  }
}

String _tipoContratoToJson(TipoContrato tipo) {
  switch (tipo) {
    case TipoContrato.PVPC:
      return 'PVPC';
    case TipoContrato.MERCADO_LIBRE:
      return 'Precio Fijo';
  }
}

@JsonSerializable()
class ContratoAutoconsumo {
  final int idContrato;
  @JsonKey(fromJson: _tipoContratoFromJson, toJson: _tipoContratoToJson)
  final TipoContrato tipoContrato;
  final double precioEnergiaImportacion_eur_kWh;
  final double precioCompensacionExcedentes_eur_kWh;
  final double potenciaContratada_kW;
  final double precioPotenciaContratado_eur_kWh;
  final int idParticipante;

  ContratoAutoconsumo({
    required this.idContrato,
    required this.tipoContrato,
    required this.precioEnergiaImportacion_eur_kWh,
    required this.precioCompensacionExcedentes_eur_kWh,
    required this.potenciaContratada_kW,
    required this.precioPotenciaContratado_eur_kWh,
    required this.idParticipante,
  });

  factory ContratoAutoconsumo.fromJson(Map<String, dynamic> json) =>
      _$ContratoAutoconsumoFromJson(json);

  Map<String, dynamic> toJson() => _$ContratoAutoconsumoToJson(this);
}