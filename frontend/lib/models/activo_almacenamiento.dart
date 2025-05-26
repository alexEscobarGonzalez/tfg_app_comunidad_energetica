import 'package:json_annotation/json_annotation.dart';

part 'activo_almacenamiento.g.dart';

@JsonSerializable()
class ActivoAlmacenamiento {
  final int idActivoAlmacenamiento;
  final double capacidadNominal_kWh;
  final double potenciaMaximaCarga_kW;
  final double potenciaMaximaDescarga_kW;
  final double eficienciaCicloCompleto_pct;
  final double profundidadDescargaMax_pct;
  final int idComunidadEnergetica;

  ActivoAlmacenamiento({
    required this.idActivoAlmacenamiento,
    required this.capacidadNominal_kWh,
    required this.potenciaMaximaCarga_kW,
    required this.potenciaMaximaDescarga_kW,
    required this.eficienciaCicloCompleto_pct,
    required this.profundidadDescargaMax_pct,
    required this.idComunidadEnergetica,
  });

  factory ActivoAlmacenamiento.fromJson(Map<String, dynamic> json) => 
      _$ActivoAlmacenamientoFromJson(json);
  Map<String, dynamic> toJson() => _$ActivoAlmacenamientoToJson(this);
} 