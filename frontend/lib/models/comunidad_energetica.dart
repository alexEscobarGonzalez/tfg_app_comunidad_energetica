import 'package:json_annotation/json_annotation.dart';
import 'package:frontend/models/enums/tipo_estrategia_excedentes.dart';

part 'comunidad_energetica.g.dart';

// Conversion functions for TipoEstrategiaExcedentes
TipoEstrategiaExcedentes _tipoEstrategiaExcedentesFromJson(dynamic value) {
  if (value is String) {
    return tipoEstrategiaExcedentesFromString(value);
  }
  throw Exception('Invalid TipoEstrategiaExcedentes value: $value');
}

String _tipoEstrategiaExcedentesToJson(TipoEstrategiaExcedentes tipo) {
  return tipo.toBackendString();
}

@JsonSerializable()
class ComunidadEnergetica {
  final int idComunidadEnergetica;
  final String nombre;
  final double latitud;
  final double longitud;
  @JsonKey(
    fromJson: _tipoEstrategiaExcedentesFromJson,
    toJson: _tipoEstrategiaExcedentesToJson
  )
  final TipoEstrategiaExcedentes tipoEstrategiaExcedentes;
  final int idUsuario;

  ComunidadEnergetica({
    required this.idComunidadEnergetica,
    required this.nombre,
    required this.latitud,
    required this.longitud,
    required this.tipoEstrategiaExcedentes,
    required this.idUsuario,
  });

  factory ComunidadEnergetica.fromJson(Map<String, dynamic> json) => 
      _$ComunidadEnergeticaFromJson(json);
  Map<String, dynamic> toJson() => _$ComunidadEnergeticaToJson(this);
} 