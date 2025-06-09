import 'package:frontend/models/enums/tipo_activo_generacion.dart';
import 'package:json_annotation/json_annotation.dart';

part 'activo_generacion.g.dart';

// Funciones auxiliares para serialización de fecha
String _dateToJson(DateTime date) => date.toIso8601String().split('T')[0];
DateTime _dateFromJson(String dateStr) => DateTime.parse(dateStr);

// Funciones auxiliares para serialización de enum
String _tipoActivoToJson(TipoActivoGeneracion tipo) {
  switch (tipo) {
    case TipoActivoGeneracion.INSTALACION_FOTOVOLTAICA:
      return 'Instalación Fotovoltaica';
    case TipoActivoGeneracion.AEROGENERADOR:
      return 'Aerogenerador';
  }
}

TipoActivoGeneracion _tipoActivoFromJson(String tipoStr) {
  switch (tipoStr) {
    case 'Instalación Fotovoltaica':
      return TipoActivoGeneracion.INSTALACION_FOTOVOLTAICA;
    case 'Aerogenerador':
      return TipoActivoGeneracion.AEROGENERADOR;
    default:
      throw ArgumentError('Tipo de activo no válido: $tipoStr');
  }
}

// Funciones auxiliares para conversión de campos numéricos a String
String? _numberToString(dynamic value) {
  if (value == null) return null;
  return value.toString();
}

dynamic _stringToNumber(String? value) {
  if (value == null) return null;
  return value;
}

@JsonSerializable()
class ActivoGeneracion {
  final int idActivoGeneracion;
  final String nombreDescriptivo;
  @JsonKey(toJson: _dateToJson, fromJson: _dateFromJson)
  final DateTime fechaInstalacion;
  final double costeInstalacion_eur;
  final int vidaUtil_anios;
  final double latitud;
  final double longitud;
  final double potenciaNominal_kWp;
  final int idComunidadEnergetica;
  @JsonKey(toJson: _tipoActivoToJson, fromJson: _tipoActivoFromJson)
  final TipoActivoGeneracion tipo_activo;
  @JsonKey(toJson: _stringToNumber, fromJson: _numberToString)
  final String? inclinacionGrados;
  @JsonKey(toJson: _stringToNumber, fromJson: _numberToString)
  final String? azimutGrados;
  final String? tecnologiaPanel;
  @JsonKey(toJson: _stringToNumber, fromJson: _numberToString)
  final String? perdidaSistema;
  final String? posicionMontaje;
  final Map<String, dynamic>? curvaPotencia;


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