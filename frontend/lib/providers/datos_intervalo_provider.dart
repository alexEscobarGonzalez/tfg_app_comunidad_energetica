import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/datos_intervalo_participante.dart';
import '../models/datos_intervalo_activo.dart';
import '../services/datos_intervalo_participante_api_service.dart';
import '../services/datos_intervalo_activo_api_service.dart';
import 'simulacion_provider.dart';

enum PeriodoAgrupacion {
  diario,
  semanal,
  mensual,
}

class FiltrosDatosIntervalo {
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final PeriodoAgrupacion periodo;

  const FiltrosDatosIntervalo({
    this.fechaInicio,
    this.fechaFin,
    this.periodo = PeriodoAgrupacion.diario,
  });

  FiltrosDatosIntervalo copyWith({
    DateTime? fechaInicio,
    DateTime? fechaFin,
    PeriodoAgrupacion? periodo,
  }) {
    return FiltrosDatosIntervalo(
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      periodo: periodo ?? this.periodo,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FiltrosDatosIntervalo &&
          runtimeType == other.runtimeType &&
          fechaInicio == other.fechaInicio &&
          fechaFin == other.fechaFin &&
          periodo == other.periodo;

  @override
  int get hashCode => Object.hash(fechaInicio, fechaFin, periodo);
}

// Cache para evitar múltiples llamadas con los mismos parámetros
final _cacheParticipantes = <String, List<DatosIntervaloParticipante>>{};
final _cacheGeneracion = <String, List<DatosIntervaloActivo>>{};
final _cacheAlmacenamiento = <String, List<DatosIntervaloActivo>>{};

String _getCacheKey(int simulacionId, FiltrosDatosIntervalo filtros) {
  return '${simulacionId}_${filtros.fechaInicio?.millisecondsSinceEpoch ?? 'null'}_${filtros.fechaFin?.millisecondsSinceEpoch ?? 'null'}_${filtros.periodo.name}';
}

// Provider para obtener datos de intervalo de participantes por simulación
final datosIntervaloParticipantesProvider = FutureProvider.family<List<DatosIntervaloParticipante>, ({int simulacionId, FiltrosDatosIntervalo filtros})>((ref, params) async {
  final cacheKey = _getCacheKey(params.simulacionId, params.filtros);
  
  // Verificar cache primero
  if (_cacheParticipantes.containsKey(cacheKey)) {
    return _cacheParticipantes[cacheKey]!;
  }

  try {
    // Obtener los resultados de participantes para esta simulación
    final resultadosParticipantes = await ref.read(resultadosParticipantesProvider(params.simulacionId).future);
    
    List<DatosIntervaloParticipante> todosDatos = [];
    
    // Procesar en lotes para evitar sobrecargar el servidor
    const batchSize = 5; // Procesar máximo 5 participantes a la vez
    
    for (int i = 0; i < resultadosParticipantes.length; i += batchSize) {
      final batch = resultadosParticipantes.skip(i).take(batchSize);
      
      // Crear futures para el lote actual
      final batchFutures = batch.where((resultado) => resultado.idResultadoParticipante != null)
          .map((resultado) async {
        try {
          final datosJson = await DatosIntervaloParticipanteApiService.getDatosByResultadoParticipante(
            resultado.idResultadoParticipante!,
            startTime: params.filtros.fechaInicio,
            endTime: params.filtros.fechaFin,
          );
          
          return datosJson.map((json) => DatosIntervaloParticipante.fromJson(json)).toList();
        } catch (e) {
          print('Error cargando datos para participante ${resultado.idParticipante}: $e');
          return <DatosIntervaloParticipante>[];
        }
      }).toList();
      
      // Esperar a que se complete el lote
      final batchResults = await Future.wait(batchFutures);
      
      // Agregar resultados del lote
      for (final datos in batchResults) {
        todosDatos.addAll(datos);
      }
    }
    
    // Guardar en cache
    _cacheParticipantes[cacheKey] = todosDatos;
    
    return todosDatos;
  } catch (e) {
    print('Error en datosIntervaloParticipantesProvider: $e');
    return [];
  }
});

// Provider para obtener datos de intervalo de activos de generación por simulación
final datosIntervaloGeneracionProvider = FutureProvider.family<List<DatosIntervaloActivo>, ({int simulacionId, FiltrosDatosIntervalo filtros})>((ref, params) async {
  final cacheKey = _getCacheKey(params.simulacionId, params.filtros);
  
  // Verificar cache primero
  if (_cacheGeneracion.containsKey(cacheKey)) {
    return _cacheGeneracion[cacheKey]!;
  }

  try {
    // Obtener los resultados de activos de generación para esta simulación
    final resultadosGeneracion = await ref.read(resultadosActivosGeneracionProvider(params.simulacionId).future);
    
    List<DatosIntervaloActivo> todosDatos = [];
    
    // Procesar en lotes para evitar sobrecargar el servidor
    const batchSize = 3; // Procesar máximo 3 activos a la vez
    
    for (int i = 0; i < resultadosGeneracion.length; i += batchSize) {
      final batch = resultadosGeneracion.skip(i).take(batchSize);
      
      // Crear futures para el lote actual
      final batchFutures = batch.where((resultado) => resultado.idResultadoActivoGen != null)
          .map((resultado) async {
        try {
          final datosJson = await DatosIntervaloActivoApiService.getDatosByActivoGeneracion(
            resultado.idResultadoActivoGen!,
            startTime: params.filtros.fechaInicio,
            endTime: params.filtros.fechaFin,
          );
          
          return datosJson.map((json) => DatosIntervaloActivo.fromJson(json)).toList();
        } catch (e) {
          print('Error cargando datos para activo de generación ${resultado.idResultadoActivoGen}: $e');
          return <DatosIntervaloActivo>[];
        }
      }).toList();
      
      // Esperar a que se complete el lote
      final batchResults = await Future.wait(batchFutures);
      
      // Agregar resultados del lote
      for (final datos in batchResults) {
        todosDatos.addAll(datos);
      }
    }
    
    // Guardar en cache
    _cacheGeneracion[cacheKey] = todosDatos;
    
    return todosDatos;
  } catch (e) {
    print('Error en datosIntervaloGeneracionProvider: $e');
    return [];
  }
});

// Provider para obtener datos de intervalo de activos de almacenamiento por simulación
final datosIntervaloAlmacenamientoProvider = FutureProvider.family<List<DatosIntervaloActivo>, ({int simulacionId, FiltrosDatosIntervalo filtros})>((ref, params) async {
  final cacheKey = _getCacheKey(params.simulacionId, params.filtros);
  
  // Verificar cache primero
  if (_cacheAlmacenamiento.containsKey(cacheKey)) {
    return _cacheAlmacenamiento[cacheKey]!;
  }

  try {
    // Obtener los resultados de activos de almacenamiento para esta simulación
    final resultadosAlmacenamiento = await ref.read(resultadosActivosAlmacenamientoProvider(params.simulacionId).future);
    
    List<DatosIntervaloActivo> todosDatos = [];
    
    // Procesar en lotes para evitar sobrecargar el servidor
    const batchSize = 3; // Procesar máximo 3 activos a la vez
    
    for (int i = 0; i < resultadosAlmacenamiento.length; i += batchSize) {
      final batch = resultadosAlmacenamiento.skip(i).take(batchSize);
      
      // Crear futures para el lote actual
      final batchFutures = batch.where((resultado) => resultado.idResultadoActivoAlm != null)
          .map((resultado) async {
        try {
          final datosJson = await DatosIntervaloActivoApiService.getDatosByActivoAlmacenamiento(
            resultado.idResultadoActivoAlm!,
            startTime: params.filtros.fechaInicio,
            endTime: params.filtros.fechaFin,
          );
          
          return datosJson.map((json) => DatosIntervaloActivo.fromJson(json)).toList();
        } catch (e) {
          print('Error cargando datos para activo de almacenamiento ${resultado.idResultadoActivoAlm}: $e');
          return <DatosIntervaloActivo>[];
        }
      }).toList();
      
      // Esperar a que se complete el lote
      final batchResults = await Future.wait(batchFutures);
      
      // Agregar resultados del lote
      for (final datos in batchResults) {
        todosDatos.addAll(datos);
      }
    }
    
    // Guardar en cache
    _cacheAlmacenamiento[cacheKey] = todosDatos;
    
    return todosDatos;
  } catch (e) {
    print('Error en datosIntervaloAlmacenamientoProvider: $e');
    return [];
  }
});

// Provider para limpiar cache cuando sea necesario
final clearCacheProvider = Provider<void Function()>((ref) {
  return () {
    _cacheParticipantes.clear();
    _cacheGeneracion.clear();
    _cacheAlmacenamiento.clear();
  };
});

// Provider para datos agregados por periodo
final datosAgregadosProvider = Provider.family<Map<String, List<double>>, ({
  List<DatosIntervaloParticipante> participantes,
  List<DatosIntervaloActivo> generacion,
  List<DatosIntervaloActivo> almacenamiento,
  PeriodoAgrupacion periodo,
})>((ref, params) {
  final Map<String, List<double>> resultado = {
    'timestamps': [],
    'consumo': [],
    'generacion': [],
    'importacion': [],
    'exportacion': [],
    'soc': [],
    'costes': [],
  };

  if (params.participantes.isEmpty) {
    return resultado;
  }

  // Agrupar datos por período
  final Map<DateTime, List<DatosIntervaloParticipante>> participantesPorPeriodo = {};
  final Map<DateTime, List<DatosIntervaloActivo>> generacionPorPeriodo = {};
  final Map<DateTime, List<DatosIntervaloActivo>> almacenamientoPorPeriodo = {};

  // Agrupar participantes
  for (final dato in params.participantes) {
    if (dato.timestamp != null) {
      final fechaAgrupada = _agruparPorPeriodo(dato.timestamp!, params.periodo);
      participantesPorPeriodo.putIfAbsent(fechaAgrupada, () => []).add(dato);
    }
  }

  // Agrupar generación
  for (final dato in params.generacion) {
    if (dato.timestamp != null) {
      final fechaAgrupada = _agruparPorPeriodo(dato.timestamp!, params.periodo);
      generacionPorPeriodo.putIfAbsent(fechaAgrupada, () => []).add(dato);
    }
  }

  // Agrupar almacenamiento
  for (final dato in params.almacenamiento) {
    if (dato.timestamp != null) {
      final fechaAgrupada = _agruparPorPeriodo(dato.timestamp!, params.periodo);
      almacenamientoPorPeriodo.putIfAbsent(fechaAgrupada, () => []).add(dato);
    }
  }

  // Obtener fechas únicas y ordenadas
  final fechasUnicas = {
    ...participantesPorPeriodo.keys,
    ...generacionPorPeriodo.keys,
    ...almacenamientoPorPeriodo.keys,
  }.toList()..sort();

  // Calcular agregados por período
  for (final fecha in fechasUnicas) {
    resultado['timestamps']!.add(fecha.millisecondsSinceEpoch.toDouble());

    // Consumo total
    final participantesPeriodo = participantesPorPeriodo[fecha] ?? [];
    final consumoTotal = participantesPeriodo.fold<double>(
      0.0,
      (sum, dato) => sum + (dato.consumoReal_kWh ?? 0.0),
    );
    resultado['consumo']!.add(consumoTotal);

    // Generación total
    final generacionPeriodo = generacionPorPeriodo[fecha] ?? [];
    final generacionTotal = generacionPeriodo.fold<double>(
      0.0,
      (sum, dato) => sum + (dato.energiaGenerada_kWh ?? 0.0),
    );
    resultado['generacion']!.add(generacionTotal);

    // Importación y exportación (calculadas a partir de energiaDiferencia_kWh)
    final importacionTotal = participantesPeriodo.fold<double>(
      0.0,
      (sum, dato) {
        final diferencia = dato.energiaDiferencia_kWh ?? 0.0;
        return sum + (diferencia > 0 ? diferencia : 0.0);
      },
    );
    final exportacionTotal = participantesPeriodo.fold<double>(
      0.0,
      (sum, dato) {
        final diferencia = dato.energiaDiferencia_kWh ?? 0.0;
        return sum + (diferencia < 0 ? diferencia.abs() : 0.0);
      },
    );
    resultado['importacion']!.add(importacionTotal);
    resultado['exportacion']!.add(exportacionTotal);

    // SOC promedio
    final almacenamientoPeriodo = almacenamientoPorPeriodo[fecha] ?? [];
    final socPromedio = almacenamientoPeriodo.isNotEmpty
        ? almacenamientoPeriodo.fold<double>(
              0.0,
              (sum, dato) => sum + (dato.SoC_kWh ?? 0.0),
            ) /
            almacenamientoPeriodo.length
        : 0.0;
    resultado['soc']!.add(socPromedio);

    // Costes (calculados a partir de precios y diferencias de energía)
    final costesTotal = participantesPeriodo.fold<double>(
      0.0,
      (sum, dato) {
        final diferencia = dato.energiaDiferencia_kWh ?? 0.0;
        final precioImportacion = dato.precioImportacionIntervalo ?? 0.0;
        final precioExportacion = dato.precioExportacionIntervalo ?? 0.0;
        
        if (diferencia > 0) {
          // Importación - coste positivo
          return sum + (diferencia * precioImportacion);
        } else {
          // Exportación - ganancia (coste negativo)
          return sum - (diferencia.abs() * precioExportacion);
        }
      },
    );
    resultado['costes']!.add(costesTotal);
  }

  return resultado;
});

// Provider para datos acumulados
final datosAcumuladosProvider = Provider.family<List<double>, List<double>>((ref, datos) {
  if (datos.isEmpty) return [];
  
  List<double> acumulados = [];
  double suma = 0.0;
  
  for (final valor in datos) {
    suma += valor;
    acumulados.add(suma);
  }
  
  return acumulados;
});

DateTime _agruparPorPeriodo(DateTime fecha, PeriodoAgrupacion periodo) {
  switch (periodo) {
    case PeriodoAgrupacion.diario:
      return DateTime(fecha.year, fecha.month, fecha.day);
    case PeriodoAgrupacion.semanal:
      final diasDesdeLunes = fecha.weekday - 1;
      final inicioSemana = fecha.subtract(Duration(days: diasDesdeLunes));
      return DateTime(inicioSemana.year, inicioSemana.month, inicioSemana.day);
    case PeriodoAgrupacion.mensual:
      return DateTime(fecha.year, fecha.month, 1);
  }
} 