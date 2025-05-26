import 'package:frontend/models/enums/tipo_activo_generacion.dart';
import 'package:json_annotation/json_annotation.dart';

part 'activo_generacion.g.dart';



@JsonSerializable()
class ActivoGeneracion {
  final int idActivoGeneracion;
  final String nombreDescriptivo;
  final DateTime fechaInstalacion;
  final double costeInstalacion_eur;
  final int vidaUtil_anios;
  final double latitud;
  final double longitud;
  final double potenciaNominal_kWp;
  final int idComunidadEnergetica;
  final TipoActivoGeneracion tipo_activo;
  final String? inclinacionGrados;
  final String? azimutGrados;
  final String? tecnologiaPanel;
  final String? perdidaSistema;
  final String? posicionMontaje;
  final String? curvaPotencia;


  ActivoGeneracion({
    required this.idActivoGeneracion,
    required this.nombreDescriptivo,
    required this.fechaInstalacion,
    required this.costeInstalacion_eur,
    required this.vidaUtil_anios,
    required this.latitud,
    required this.longitud,
    required this.potenciaNominal_kWp,
    required this.idComunidadEnergetica,
    required this.tipo_activo,
    this.inclinacionGrados,
    this.azimutGrados,
    this.tecnologiaPanel,
    this.perdidaSistema,
    this.posicionMontaje,
    this.curvaPotencia
  });

  factory ActivoGeneracion.fromJson(Map<String, dynamic> json) => 
      _$ActivoGeneracionFromJson(json);
  Map<String, dynamic> toJson() => _$ActivoGeneracionToJson(this);
} 