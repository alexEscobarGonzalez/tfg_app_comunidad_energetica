import 'package:json_annotation/json_annotation.dart';
import 'package:frontend/models/enums/tipo_contrato.dart';

part 'contrato_autoconsumo.g.dart';



@JsonSerializable()
class ContratoAutoconsumo {
  final int idContrato;
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