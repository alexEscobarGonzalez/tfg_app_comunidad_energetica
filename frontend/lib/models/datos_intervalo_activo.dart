import 'package:json_annotation/json_annotation.dart';

part 'datos_intervalo_activo.g.dart';

@JsonSerializable()
class DatosIntervaloActivo {
  final int? idDatosIntervaloActivo;
  final DateTime? timestamp;
  final double? energiaGenerada_kWh;
  final double? energiaCargada_kWh;
  final double? energiaDescargada_kWh;
  final double? SoC_kWh;
  final int? idResultadoActivoGen;
  final int? idResultadoActivoAlm;

  DatosIntervaloActivo({
    this.idDatosIntervaloActivo,
    this.timestamp,
    this.energiaGenerada_kWh,
    this.energiaCargada_kWh,
    this.energiaDescargada_kWh,
    this.SoC_kWh,
    this.idResultadoActivoGen,
    this.idResultadoActivoAlm,
  });

  factory DatosIntervaloActivo.fromJson(Map<String, dynamic> json) => _$DatosIntervaloActivoFromJson(json);
  Map<String, dynamic> toJson() => _$DatosIntervaloActivoToJson(this);
}
