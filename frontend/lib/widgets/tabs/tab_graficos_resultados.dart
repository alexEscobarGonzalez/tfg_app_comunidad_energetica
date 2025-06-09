import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/simulacion.dart';
import '../../models/datos_intervalo_participante.dart';
import '../../models/datos_intervalo_activo.dart';
import '../../providers/datos_intervalo_provider.dart';
import '../../providers/simulacion_provider.dart';

class _ChartData {
  _ChartData(this.x, this.y);
  final DateTime x;
  final double y;
}

class TabGraficosResultados extends ConsumerStatefulWidget {
  final Simulacion simulacionSeleccionada;

  const TabGraficosResultados({
    super.key,
    required this.simulacionSeleccionada,
  });

  @override
  ConsumerState<TabGraficosResultados> createState() => _TabGraficosResultadosState();
}

class _TabGraficosResultadosState extends ConsumerState<TabGraficosResultados> {
  PeriodoAgrupacion _periodoSeleccionado = PeriodoAgrupacion.diario;
  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  int _graficoSeleccionado = 0;
  bool _cargarDatos = false;
  
  // Variables para selección de ámbito
  int? _participanteSeleccionado; // null = toda la comunidad (para gráficos de participantes)
  int? _activoAlmacenamientoSeleccionado; // null = todos los activos (para gráfico SOC)
  
  final TextEditingController _fechaInicioController = TextEditingController();
  final TextEditingController _fechaFinController = TextEditingController();

  final List<String> _nombresGraficos = [
    'Consumo vs. Generación',
    'Estado de Carga (SOC)',
  ];

  @override
  void initState() {
    super.initState();
    // Establecer fechas automáticamente del período de simulación
    _fechaInicio = widget.simulacionSeleccionada.fechaInicio;
    _fechaFin = widget.simulacionSeleccionada.fechaFin.subtract(const Duration(days: 1));
    _fechaInicioController.text = _formatDateForInput(_fechaInicio!);
    _fechaFinController.text = _fechaFin != null ? _formatDateForInput(_fechaFin!) : '';
    _cargarDatos = true; // Cargar datos automáticamente
  }

  @override
  void dispose() {
    _fechaInicioController.dispose();
    _fechaFinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtros = FiltrosDatosIntervalo(
      fechaInicio: _fechaInicio,
      fechaFin: _fechaFin != null 
          ? DateTime(_fechaFin!.year, _fechaFin!.month, _fechaFin!.day, 23, 0, 0)
          : null,
      periodo: _periodoSeleccionado,
    );

    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: 12.h),
          _buildControles(),
          SizedBox(height: 16.h),
          _buildGraficoContainer(filtros),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.secondary, AppColors.secondary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Icon(
            Icons.bar_chart,
            color: Colors.white,
            size: 14.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gráficos de Series Temporales',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.simulacionSeleccionada.nombreSimulacion,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              'Gráficos',
              style: AppTextStyles.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControles() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Controles',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          // Primera fila de selectores
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tipo de Gráfico',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _graficoSeleccionado,
                          isExpanded: true,
                          items: _nombresGraficos.asMap().entries.map((entry) {
                            return DropdownMenuItem<int>(
                              value: entry.key,
                              child: Text(
                                entry.value,
                                style: AppTextStyles.bodyMedium,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _graficoSeleccionado = value!;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Período',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<PeriodoAgrupacion>(
                          value: _periodoSeleccionado,
                          isExpanded: true,
                          items: PeriodoAgrupacion.values.map((periodo) {
                            return DropdownMenuItem<PeriodoAgrupacion>(
                              value: periodo,
                              child: Text(
                                _getNombrePeriodo(periodo),
                                style: AppTextStyles.bodyMedium,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _periodoSeleccionado = value!;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // Segunda fila - Selector de participante
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _graficoSeleccionado == 1 ? 'Activo de Almacenamiento' : 'Ámbito de Análisis',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: _graficoSeleccionado == 1 
                            ? _buildSelectorActivosAlmacenamiento()
                            : _buildSelectorParticipantes(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // Controles de fecha
          Row(
            children: [
              Expanded(
                child: _buildDateInput(
                  'Fecha Inicio',
                  _fechaInicioController,
                  (fecha) => setState(() => _fechaInicio = fecha),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildDateInput(
                  'Fecha Fin',
                  _fechaFinController,
                  (fecha) => setState(() => _fechaFin = fecha),
                ),
              ),
              SizedBox(width: 12.w),
              ElevatedButton.icon(
                onPressed: _fechaInicio != null && _fechaFin != null 
                    ? () => _cargarDatosGraficos()
                    : null,
                icon: Icon(Icons.search, color: Colors.white),
                label: Text('Cargar', style: AppTextStyles.caption.copyWith(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.textHint,
                  disabledForegroundColor: Colors.white70,
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                ),
              ),
              SizedBox(width: 6.w),
              ElevatedButton.icon(
                onPressed: () => _limpiarConfiguracion(),
                icon: Icon(Icons.clear, color: Colors.white,),
                label: Text('Limpiar', style: AppTextStyles.caption.copyWith(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateInput(String label, TextEditingController controller, Function(DateTime) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 6.h),
        TextField(
          controller: controller,
          style: AppTextStyles.bodySmall,
          decoration: InputDecoration(
            hintText: 'dd/mm/yyyy',
            prefixIcon: Icon(Icons.calendar_today, color: AppColors.secondary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6.r),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6.r),
              borderSide: BorderSide(color: AppColors.secondary),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
            isDense: true,
          ),
          onChanged: (value) => _onDateChanged(value, onChanged),
          inputFormatters: [_DateInputFormatter()],
        ),
      ],
    );
  }

  String _formatDateForInput(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _onDateChanged(String value, Function(DateTime) onChanged) {
    if (value.length == 10) { // dd/mm/yyyy
      try {
        final parts = value.split('/');
        if (parts.length == 3) {
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final year = int.parse(parts[2]);
          final date = DateTime(year, month, day);
          onChanged(date);
        }
      } catch (e) {
        // Fecha inválida, no hacer nada
      }
    }
  }

  Widget _buildGraficoContainer(FiltrosDatosIntervalo filtros) {
    return Container(
      height: 400.h,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getIconoGrafico(_graficoSeleccionado),
                color: AppColors.secondary,
                size: 14.sp,
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _nombresGraficos[_graficoSeleccionado],
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      _getTextoAmbito(),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Expanded(
            child: _buildGrafico(filtros),
          ),
        ],
      ),
    );
  }

  Widget _buildGrafico(FiltrosDatosIntervalo filtros) {
    // Solo cargar datos si el usuario ha presionado el botón "Cargar Datos"
    if (!_cargarDatos) {
      return _buildEstadoInicial();
    }

    final participantesAsync = ref.watch(datosIntervaloParticipantesProvider((
      simulacionId: widget.simulacionSeleccionada.idSimulacion!,
      filtros: filtros,
    )));
    
    final generacionAsync = ref.watch(datosIntervaloGeneracionProvider((
      simulacionId: widget.simulacionSeleccionada.idSimulacion!,
      filtros: filtros,
    )));
    
    final almacenamientoAsync = ref.watch(datosIntervaloAlmacenamientoProvider((
      simulacionId: widget.simulacionSeleccionada.idSimulacion!,
      filtros: filtros,
    )));

    return participantesAsync.when(
      data: (participantes) => generacionAsync.when(
        data: (generacion) => almacenamientoAsync.when(
          data: (almacenamiento) {
            // Filtrar datos según el participante seleccionado
            final participantesFiltrados = _participanteSeleccionado == null 
                ? participantes  // Toda la comunidad
                : _filtrarDatosPorParticipante(participantes, _participanteSeleccionado!);
            
            final datosAgregados = ref.watch(datosAgregadosProvider((
              participantes: participantesFiltrados,
              generacion: generacion,
              almacenamiento: almacenamiento,
              periodo: _periodoSeleccionado,
            )));

            switch (_graficoSeleccionado) {
              case 0:
                return _buildGraficoConsumoGeneracion(datosAgregados);
              case 1:
                // Para SOC, usar datos sin filtrar por participante (solo por activos)
                return _buildGraficoSOCPorActivos(almacenamiento, filtros);
              default:
                return _buildGraficoConsumoGeneracion(datosAgregados);
            }
          },
          loading: () => _buildLoadingState(),
          error: (error, stack) => _buildErrorState(error.toString()),
        ),
        loading: () => _buildLoadingState(),
        error: (error, stack) => _buildErrorState(error.toString()),
      ),
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(error.toString()),
    );
  }

  Widget _buildEstadoInicial() {
    final fechasSeleccionadas = _fechaInicio != null && _fechaFin != null;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.date_range,
            color: AppColors.secondary,
            size: 32.sp,
          ),
          SizedBox(height: 16.h),
          Text(
            'Configura el análisis de datos',
            style: AppTextStyles.headline4.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Selecciona el ámbito de análisis (toda la comunidad o un participante específico), configura las fechas y presiona "Cargar Datos" para visualizar el gráfico.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          // Indicadores de estado
          ],
      ),
    );
  }

  Widget _buildIndicadorEstado(String label, bool completado, IconData icono) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: completado 
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.border.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: completado ? AppColors.success : AppColors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            completado ? Icons.check : icono,
            color: completado ? AppColors.success : AppColors.textHint,
            size: 16.sp,
          ),
          SizedBox(width: 6.w),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: completado ? AppColors.success : AppColors.textHint,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGraficoConsumoGeneracion(Map<String, List<double>> datos) {
    if (datos['timestamps']?.isEmpty ?? true) {
      return _buildEmptyState();
    }

    final List<_ChartData> consumoData = [];
    for (int i = 0; i < datos['timestamps']!.length; i++) {
      consumoData.add(_ChartData(
          DateTime.fromMillisecondsSinceEpoch(datos['timestamps']![i].toInt()),
          datos['consumo']![i]));
    }

    final List<_ChartData> generacionData = [];
    for (int i = 0; i < datos['timestamps']!.length; i++) {
      generacionData.add(_ChartData(
          DateTime.fromMillisecondsSinceEpoch(datos['timestamps']![i].toInt()),
          datos['generacion']![i]));
    }

    return SfCartesianChart(
      primaryXAxis: DateTimeAxis(
        dateFormat: _getAxisLabelFormat(),
      ),
      primaryYAxis: NumericAxis(
        labelFormat: '{value} MWh',
        numberFormat: NumberFormat.compact(),
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      legend: Legend(isVisible: true, position: LegendPosition.bottom),
      series: <CartesianSeries<_ChartData, DateTime>>[
        LineSeries<_ChartData, DateTime>(
          dataSource: consumoData,
          xValueMapper: (_ChartData data, _) => data.x,
          yValueMapper: (_ChartData data, _) => data.y / 1000,
          name: 'Consumo',
          color: AppColors.error,
        ),
        LineSeries<_ChartData, DateTime>(
          dataSource: generacionData,
          xValueMapper: (_ChartData data, _) => data.x,
          yValueMapper: (_ChartData data, _) => data.y / 1000,
          name: 'Generación',
          color: AppColors.solar,
        ),
      ],
    );
  }

  Widget _buildGraficoSOC(Map<String, List<double>> datos) {
    if (datos['timestamps']?.isEmpty ?? true || datos['soc']?.isEmpty == true) {
      return _buildEmptyState();
    }

    final List<_ChartData> socData = [];
    for (int i = 0; i < datos['timestamps']!.length; i++) {
      socData.add(_ChartData(
          DateTime.fromMillisecondsSinceEpoch(datos['timestamps']![i].toInt()),
          datos['soc']![i]));
    }

    return SfCartesianChart(
      primaryXAxis: DateTimeAxis(
        dateFormat: _getAxisLabelFormat(),
      ),
      primaryYAxis: NumericAxis(
        labelFormat: '{value} kWh',
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CartesianSeries<_ChartData, DateTime>>[
        LineSeries<_ChartData, DateTime>(
          dataSource: socData,
          xValueMapper: (_ChartData data, _) => data.x,
          yValueMapper: (_ChartData data, _) => data.y,
          name: 'SOC',
          color: AppColors.battery,
        )
      ],
    );
  }

  Widget _buildGraficoSOCPorActivos(List<DatosIntervaloActivo> almacenamiento, FiltrosDatosIntervalo filtros) {
    if (almacenamiento.isEmpty) {
      return _buildEmptyState();
    }

    // Filtrar por activo seleccionado si se ha seleccionado uno específico
    final List<DatosIntervaloActivo> almacenamientoFiltrado;
    if (_activoAlmacenamientoSeleccionado != null) {
      almacenamientoFiltrado = almacenamiento.where((dato) => 
        _obtenerIdActivoDeAlmacenamiento(dato) == _activoAlmacenamientoSeleccionado
      ).toList();
    } else {
      almacenamientoFiltrado = almacenamiento;
    }

    if (almacenamientoFiltrado.isEmpty) {
      return _buildEmptyState();
    }

    // Agrupar datos por activo
    final Map<int?, List<DatosIntervaloActivo>> datosPorActivo = {};
    for (final dato in almacenamientoFiltrado) {
      final activoId = _obtenerIdActivoDeAlmacenamiento(dato);
      datosPorActivo.putIfAbsent(activoId, () => []).add(dato);
    }

    // Colores predefinidos para los activos
    final List<Color> coloresActivos = [
      AppColors.battery,
      AppColors.solar,
      AppColors.success,
      AppColors.warning,
      AppColors.error,
      AppColors.secondary,
    ];

    List<CartesianSeries<_ChartData, DateTime>> series = [];
    datosPorActivo.entries.forEach((entry) {
      final activoId = entry.key;
      final datosActivo = entry.value;
      final index = datosPorActivo.keys.toList().indexOf(activoId);
      final color = coloresActivos[index % coloresActivos.length];

      final Map<DateTime, List<DatosIntervaloActivo>> datosPorPeriodo = {};
      for (final dato in datosActivo) {
        if (dato.timestamp != null) {
          final fechaAgrupada = _agruparPorPeriodo(dato.timestamp!, _periodoSeleccionado);
          datosPorPeriodo.putIfAbsent(fechaAgrupada, () => []).add(dato);
        }
      }

      final List<_ChartData> chartData = [];
      final fechasOrdenadas = datosPorPeriodo.keys.toList()..sort();
      
      for (final fecha in fechasOrdenadas) {
        final datosDelPeriodo = datosPorPeriodo[fecha]!;
        final socPromedio = datosDelPeriodo.isNotEmpty
           ? datosDelPeriodo.fold<double>(0.0, (sum, dato) => sum + (dato.SoC_kWh ?? 0.0)) / datosDelPeriodo.length
           : 0.0;
        
        chartData.add(_ChartData(fecha, socPromedio));
      }

      series.add(
        LineSeries<_ChartData, DateTime>(
          dataSource: chartData,
          xValueMapper: (_ChartData data, _) => data.x,
          yValueMapper: (_ChartData data, _) => data.y,
          name: 'Activo ${activoId ?? "N/A"}',
          color: color,
        )
      );
    });

    return SfCartesianChart(
      primaryXAxis: DateTimeAxis(
        dateFormat: _getAxisLabelFormat(),
      ),
      primaryYAxis: NumericAxis(
        labelFormat: '{value} kWh',
      ),
      tooltipBehavior: TooltipBehavior(enable: true, header: ''),
      legend: Legend(isVisible: true, position: LegendPosition.bottom),
      series: series,
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.secondary),
          SizedBox(height: 16.h),
          Text(
            'Cargando datos del gráfico...',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, color: AppColors.error, size: 48.sp),
          SizedBox(height: 16.h),
          Text(
            'Error al cargar el gráfico',
            style: AppTextStyles.headline4.copyWith(
              color: AppColors.error,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            error,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.show_chart, color: AppColors.textHint, size: 48.sp),
          SizedBox(height: 16.h),
          Text(
            'Sin datos para mostrar',
            style: AppTextStyles.headline4.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'No hay datos disponibles para el período seleccionado.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textHint,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getNombrePeriodo(PeriodoAgrupacion periodo) {
    switch (periodo) {
      case PeriodoAgrupacion.diario:
        return 'Diario';
      case PeriodoAgrupacion.semanal:
        return 'Semanal';
      case PeriodoAgrupacion.mensual:
        return 'Mensual';
    }
  }

  IconData _getIconoGrafico(int indice) {
    switch (indice) {
      case 0:
        return Icons.trending_up;
      case 1:
        return Icons.battery_charging_full;
      default:
        return Icons.bar_chart;
    }
  }

  String _formatFecha(DateTime fecha) {
    switch (_periodoSeleccionado) {
      case PeriodoAgrupacion.diario:
        return '${fecha.day}/${fecha.month}';
      case PeriodoAgrupacion.semanal:
        return 'S${fecha.weekday}';
      case PeriodoAgrupacion.mensual:
        return '${fecha.month}/${fecha.year}';
    }
  }

  void _cargarDatosGraficos() {
    if (_fechaInicio != null && _fechaFin != null) {
      // Validar que la fecha de inicio sea anterior a la fecha de fin
      if (_fechaInicio!.isAfter(_fechaFin!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('La fecha de inicio debe ser anterior a la fecha de fin'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      setState(() {
        _cargarDatos = true;
      });
    }
  }

  void _limpiarConfiguracion() {
    // Limpiar cache de datos para forzar nuevas consultas
    final clearCache = ref.read(clearCacheProvider);
    clearCache();
    
    setState(() {
      _fechaInicio = widget.simulacionSeleccionada.fechaInicio;
      _fechaFin = widget.simulacionSeleccionada.fechaFin;
      _fechaInicioController.text = _formatDateForInput(_fechaInicio!);
      _fechaFinController.text = _formatDateForInput(_fechaFin!);
      _cargarDatos = false;
      _participanteSeleccionado = null; // Reset a toda la comunidad
      _activoAlmacenamientoSeleccionado = null; // Reset a todos los activos
    });
  }

  // Método para filtrar datos por participante específico
  List<DatosIntervaloParticipante> _filtrarDatosPorParticipante(
    List<DatosIntervaloParticipante> todosLosDatos, 
    int idParticipante
  ) {
    // Para filtrar por participante específico, necesitamos el idResultadoParticipante
    // que corresponde al participante seleccionado
    final resultadosParticipantesAsync = ref.read(
      resultadosParticipantesProvider(widget.simulacionSeleccionada.idSimulacion!)
    );
    
    return resultadosParticipantesAsync.when(
      data: (resultados) {
        // Encontrar el resultado del participante seleccionado
        final resultadoParticipante = resultados.firstWhere(
          (r) => r.idParticipante == idParticipante,
          orElse: () => throw StateError('Participante no encontrado'),
        );
        
        // Filtrar los datos por el idResultadoParticipante
        return todosLosDatos.where((dato) => 
          dato.idResultadoParticipante == resultadoParticipante.idResultadoParticipante!
        ).toList();
      },
      loading: () => [],
      error: (error, stack) => [],
    );
  }

  // Método para obtener el ID del activo de almacenamiento
  int? _obtenerIdActivoDeAlmacenamiento(DatosIntervaloActivo dato) {
    // Para activos de almacenamiento, usar idResultadoActivoAlm
    // Este campo identifica únicamente cada activo de almacenamiento
    return dato.idResultadoActivoAlm;
  }

  // Método para agrupar por período (copiado del provider)
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

  // Método para obtener el texto del ámbito según el gráfico seleccionado
  String _getTextoAmbito() {
    if (_graficoSeleccionado == 1) {
      // Gráfico SOC - mostrar activo seleccionado
      return _activoAlmacenamientoSeleccionado == null 
          ? 'Todos los Activos' 
          : 'Activo $_activoAlmacenamientoSeleccionado';
    } else {
      // Otros gráficos - mostrar participante seleccionado
      return _participanteSeleccionado == null 
          ? 'Toda la Comunidad' 
          : 'Participante $_participanteSeleccionado';
    }
  }

  // Método para construir el selector de participantes
  Widget _buildSelectorParticipantes() {
    return Consumer(
      builder: (context, ref, child) {
        final resultadosParticipantesAsync = ref.watch(
          resultadosParticipantesProvider(widget.simulacionSeleccionada.idSimulacion!)
        );
        
        return resultadosParticipantesAsync.when(
          data: (resultados) {
            return DropdownButton<int?>(
              value: _participanteSeleccionado,
              isExpanded: true,
              hint: Text(
                'Seleccionar ámbito',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
              ),
              items: [
                // Opción para toda la comunidad
                DropdownMenuItem<int?>(
                  value: null,
                  child: Row(
                    children: [
                      Icon(Icons.group, color: AppColors.secondary),
                      SizedBox(width: 8.w),
                      Text(
                        'Toda la Comunidad',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Opciones para participantes individuales
                ...resultados.map((resultado) {
                  return DropdownMenuItem<int?>(
                    value: resultado.idParticipante,
                    child: Row(
                      children: [
                        Icon(Icons.person, color: AppColors.textSecondary),
                        SizedBox(width: 8.w),
                        Text(
                          'Participante ${resultado.idParticipante}',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
              onChanged: (value) {
                setState(() {
                  _participanteSeleccionado = value;
                });
              },
            );
          },
          loading: () => DropdownButton<int?>(
            value: null,
            isExpanded: true,
            items: [
              DropdownMenuItem<int?>(
                value: null,
                child: Text('Cargando participantes...', style: AppTextStyles.bodyMedium),
              ),
            ],
            onChanged: null,
          ),
          error: (error, stack) => DropdownButton<int?>(
            value: null,
            isExpanded: true,
            items: [
              DropdownMenuItem<int?>(
                value: null,
                child: Text('Error al cargar', style: AppTextStyles.bodyMedium),
              ),
            ],
            onChanged: null,
          ),
        );
      },
    );
  }

  // Método para construir el selector de activos de almacenamiento
  Widget _buildSelectorActivosAlmacenamiento() {
    final filtros = FiltrosDatosIntervalo(
      fechaInicio: _fechaInicio,
      fechaFin: _fechaFin,
      periodo: _periodoSeleccionado,
    );

    return Consumer(
      builder: (context, ref, child) {
        final almacenamientoAsync = ref.watch(datosIntervaloAlmacenamientoProvider((
          simulacionId: widget.simulacionSeleccionada.idSimulacion!,
          filtros: filtros,
        )));
        
        return almacenamientoAsync.when(
          data: (almacenamiento) {
            // Obtener activos únicos
            final Set<int?> idsActivos = {};
            for (final dato in almacenamiento) {
              idsActivos.add(_obtenerIdActivoDeAlmacenamiento(dato));
            }
            final activosUnicos = idsActivos.toList()..sort();

            return DropdownButton<int?>(
              value: _activoAlmacenamientoSeleccionado,
              isExpanded: true,
              hint: Text(
                'Seleccionar activo',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
              ),
              items: [
                // Opción para todos los activos
                DropdownMenuItem<int?>(
                  value: null,
                  child: Row(
                    children: [
                      Icon(Icons.battery_charging_full, color: AppColors.battery),
                      SizedBox(width: 8.w),
                      Text(
                        'Todos los Activos',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.battery,
                        ),
                      ),
                    ],
                  ),
                ),
                // Opciones para activos individuales
                ...activosUnicos.map((activoId) {
                  return DropdownMenuItem<int?>(
                    value: activoId,
                    child: Row(
                      children: [
                        Icon(Icons.battery_std, color: AppColors.textSecondary),
                        SizedBox(width: 8.w),
                        Text(
                          'Activo ${activoId ?? "N/A"}',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
              onChanged: (value) {
                setState(() {
                  _activoAlmacenamientoSeleccionado = value;
                });
              },
            );
          },
          loading: () => DropdownButton<int?>(
            value: null,
            isExpanded: true,
            items: [
              DropdownMenuItem<int?>(
                value: null,
                child: Text('Cargando activos...', style: AppTextStyles.bodyMedium),
              ),
            ],
            onChanged: null,
          ),
          error: (error, stack) => DropdownButton<int?>(
            value: null,
            isExpanded: true,
            items: [
              DropdownMenuItem<int?>(
                value: null,
                child: Text('Error al cargar', style: AppTextStyles.bodyMedium),
              ),
            ],
            onChanged: null,
          ),
        );
      },
    );
  }

  DateFormat _getAxisLabelFormat() {
    switch (_periodoSeleccionado) {
      case PeriodoAgrupacion.diario:
        return DateFormat('d MMM', 'es_ES');
      case PeriodoAgrupacion.semanal:
        return DateFormat('MMM y', 'es_ES');
      case PeriodoAgrupacion.mensual:
        return DateFormat('MMM y', 'es_ES');
    }
  }
}

class _DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text;
    
    if (newText.length > 10) {
      return oldValue;
    }
    
    String formattedText = '';
    int selectionIndex = newValue.selection.end;
    
    for (int i = 0; i < newText.length; i++) {
      if ('0123456789'.contains(newText[i])) {
        if (formattedText.length == 2 || formattedText.length == 5) {
          formattedText += '/';
          if (i < selectionIndex) selectionIndex++;
        }
        formattedText += newText[i];
      }
    }
    
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
} 