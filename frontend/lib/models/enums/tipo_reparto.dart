enum TipoReparto {
  REPARTO_FIJO('Reparto Fijo'),
  REPARTO_PROGRAMADO('Reparto Programado');

  const TipoReparto(this.value);
  final String value;

  @override
  String toString() => value;
}