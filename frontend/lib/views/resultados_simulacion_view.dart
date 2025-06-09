import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/widgets/loading_indicators.dart';
import '../models/simulacion.dart';
import '../models/enums/estado_simulacion.dart';
import '../providers/comunidad_energetica_provider.dart';
import '../services/simulacion_api_service.dart';
import '../widgets/tabs/tab_economia_resultados.dart';
import '../widgets/tabs/tab_energia_resultados.dart';
import '../widgets/tabs/tab_activos_resultados.dart';
import '../widgets/tabs/tab_tablas_comparativas.dart';
import '../widgets/tabs/tab_graficos_resultados.dart';

enum TipoVistaResultados {
  kpis('KPIs', Icons.dashboard),
  tablasComparativas('Tablas Comparativas', Icons.table_chart),
  graficos('Gráficos', Icons.bar_chart);

  const TipoVistaResultados(this.label, this.icon);
  final String label;
  final IconData icon;
}

class ResultadosSimulacionView extends ConsumerStatefulWidget {
  final int idComunidad;
  final String nombreComunidad;

  const ResultadosSimulacionView({
    super.key,
    required this.idComunidad,
    required this.nombreComunidad,
  });

  @override
  ConsumerState<ResultadosSimulacionView> createState() => _ResultadosSimulacionViewState();
}

class _ResultadosSimulacionViewState extends ConsumerState<ResultadosSimulacionView> with TickerProviderStateMixin {
  List<Simulacion> _simulacionesCompletadas = [];
  Simulacion? _simulacionSeleccionada;
  bool _isLoading = true;
  String? _error;
  TipoVistaResultados _tipoVistaSeleccionado = TipoVistaResultados.kpis;
  
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        // Actualizar la interfaz cuando cambie de tab
      });
    });
    _cargarSimulacionesCompletadas();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cargarSimulacionesCompletadas() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final comunidadSeleccionada = ref.read(comunidadSeleccionadaProvider);
      final idComunidadActual = comunidadSeleccionada?.idComunidadEnergetica ?? widget.idComunidad;
      
      final todasLasSimulaciones = await SimulacionApiService.obtenerSimulacionesComunidad(idComunidadActual);
      final simulacionesCompletadas = todasLasSimulaciones
          .where((simulacion) => simulacion.estado == EstadoSimulacion.COMPLETADA)
          .toList();

      if (!mounted) return;
      
      setState(() {
        _simulacionesCompletadas = simulacionesCompletadas;
        if (simulacionesCompletadas.isNotEmpty) {
          _simulacionSeleccionada = simulacionesCompletadas.first;
        } else {
          _simulacionSeleccionada = null;
        }
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final comunidadSeleccionada = ref.watch(comunidadSeleccionadaProvider);

    ref.listen<dynamic>(comunidadSeleccionadaProvider, (previous, next) {
      if (previous != next && next != null) {
        setState(() {
          _simulacionSeleccionada = null;
        });
        _cargarSimulacionesCompletadas();
      }
    });

    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: _isLoading
              ? _buildLoadingState()
              : _error != null
                  ? _buildErrorState()
                  : _simulacionesCompletadas.isEmpty
                      ? _buildEmptyState()
                      : _buildContent(),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    final comunidadSeleccionada = ref.watch(comunidadSeleccionadaProvider);
    
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(2.r),
          bottomRight: Radius.circular(2.r),
        ),
      ),
      child: Row(
        children: [
          Flexible(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resultados de Simulación',
                  style: AppTextStyles.tabSectionTitle,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                SizedBox(height: 4.h),
                Text(
                  comunidadSeleccionada?.nombre ?? widget.nombreComunidad,
                  style: AppTextStyles.tabDescription,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Flexible(
            flex: 2,
            child: _buildDropdownSimulaciones(),
          ),
          SizedBox(width: 12.w),
          Flexible(
            flex: 2,
            child: _buildDropdownTipoVista(),
          ),
          SizedBox(width: 12.w),
          ElevatedButton.icon(
            onPressed: _cargarSimulacionesCompletadas,
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: Text('Actualizar', style: AppTextStyles.button.copyWith(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownSimulaciones() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Simulacion>(
          value: _simulacionSeleccionada,
          hint: Text(
            'Selecciona una simulación',
            style: AppTextStyles.bodySecondary,
            overflow: TextOverflow.ellipsis,
          ),
          icon: Icon(Icons.arrow_drop_down, color: AppColors.primary),
          isExpanded: true,
          items: _simulacionesCompletadas.map((simulacion) {
            return DropdownMenuItem<Simulacion>(
              value: simulacion,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    simulacion.nombreSimulacion,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    '${_formatFecha(simulacion.fechaFin)}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (Simulacion? nuevaSimulacion) {
            setState(() {
              _simulacionSeleccionada = nuevaSimulacion;
              // Resetear el tab controller al primer tab cuando cambie la simulación
              _tabController.animateTo(0);
            });
          },
        ),
      ),
    );
  }

  Widget _buildDropdownTipoVista() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<TipoVistaResultados>(
          value: _tipoVistaSeleccionado,
          hint: Text(
            'Selecciona un tipo de vista',
            style: AppTextStyles.bodySecondary,
            overflow: TextOverflow.ellipsis,
          ),
          icon: Icon(Icons.arrow_drop_down, color: AppColors.primary),
          isExpanded: true,
          items: TipoVistaResultados.values.map((tipoVista) {
            return DropdownMenuItem<TipoVistaResultados>(
              value: tipoVista,
              child: Text(
                tipoVista.label,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            );
          }).toList(),
          onChanged: (TipoVistaResultados? nuevaVista) {
            setState(() {
              _tipoVistaSeleccionado = nuevaVista!;
            });
          },
        ),
      ),
    );
  }

  String _formatFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildContent() {
    switch (_tipoVistaSeleccionado) {
      case TipoVistaResultados.kpis:
        return _buildKPIsContent();
      case TipoVistaResultados.tablasComparativas:
        return _buildTablasComparativasContent();
      case TipoVistaResultados.graficos:
        return _buildGraficosContent();
    }
  }

  Widget _buildKPIsContent() {
    // Usar la simulación seleccionada como key para forzar rebuild cuando cambie
    final simulacionKey = _simulacionSeleccionada?.idSimulacion.toString() ?? 'no-sim';
    
    return SingleChildScrollView(
      key: ValueKey('kpis-$simulacionKey'),
      padding: EdgeInsets.all(6.w),
      child: Column(
        children: [
          _buildTabBar(),
          SizedBox(height: 16.h),
          // Usar AnimatedSwitcher para transiciones suaves entre simulaciones
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: IndexedStack(
              key: ValueKey('tabs-$simulacionKey'),
              index: _tabController.index,
              children: [
                _buildTabEconomica(),
                _buildTabEnergetica(),
                _buildTabActivos(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          color: AppColors.primary,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTextStyles.bodyMedium,
        tabs: [
          Tab(
            icon: Icon(Icons.attach_money, size: 6.sp),
            text: 'Económica',
          ),
          Tab(
            icon: Icon(Icons.electrical_services, size: 6.sp),
            text: 'Energética',
          ),
          Tab(
            icon: Icon(Icons.devices, size: 6.sp),
            text: 'Activos',
          ),
        ],
      ),
    );
  }

  Widget _buildTabEconomica() {
    if (_simulacionSeleccionada == null) {
      return _buildNoSimulationSelectedState();
    }

    return TabEconomiaResultados(
      key: ValueKey('economia-${_simulacionSeleccionada!.idSimulacion}'),
      simulacionSeleccionada: _simulacionSeleccionada!,
    );
  }

  Widget _buildNoSimulationSelectedState() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline,
                size: 64.sp,
                color: AppColors.info,
              ),
              SizedBox(height: 16.h),
              Text(
                'Selecciona una simulación',
                style: AppTextStyles.headline3.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Selecciona una simulación completada del dropdown para ver sus resultados económicos.',
                style: AppTextStyles.bodySecondary,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabEnergetica() {
    if (_simulacionSeleccionada == null) {
      return _buildNoSimulationSelectedState();
    }

    return TabEnergiaResultados(
      key: ValueKey('energia-${_simulacionSeleccionada!.idSimulacion}'),
      simulacionSeleccionada: _simulacionSeleccionada!,
    );
  }

  Widget _buildTabActivos() {
    if (_simulacionSeleccionada == null) {
      return _buildNoSimulationSelectedState();
    }

    return TabActivosResultados(
      key: ValueKey('activos-${_simulacionSeleccionada!.idSimulacion}'),
      simulacionSeleccionada: _simulacionSeleccionada!,
    );
  }

  Widget _buildTablasComparativasContent() {
    if (_simulacionSeleccionada == null) {
      return _buildNoSimulationSelectedState();
    }

    return TabTablasComparativas(
      key: ValueKey('tablas-${_simulacionSeleccionada!.idSimulacion}'),
      simulacionSeleccionada: _simulacionSeleccionada!,
    );
  }

  Widget _buildGraficosContent() {
    if (_simulacionSeleccionada == null) {
      return _buildNoSimulationSelectedState();
    }

    return TabGraficosResultados(
      key: ValueKey('graficos-${_simulacionSeleccionada!.idSimulacion}'),
      simulacionSeleccionada: _simulacionSeleccionada!,
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: LoadingSpinner(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64.sp, color: AppColors.error),
          SizedBox(height: 16.h),
          Text(
            'Error al cargar simulaciones',
            style: AppTextStyles.headline3.copyWith(color: AppColors.error),
          ),
          SizedBox(height: 8.h),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySecondary,
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: _cargarSimulacionesCompletadas,
            child: Text('Reintentar', style: AppTextStyles.button.copyWith(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
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
          Icon(Icons.assessment_outlined, size: 64.sp, color: AppColors.textSecondary),
          SizedBox(height: 16.h),
          Text(
            'No hay simulaciones completadas',
            style: AppTextStyles.headline3.copyWith(color: AppColors.textSecondary),
          ),
          SizedBox(height: 8.h),
          Text(
            'Los resultados aparecerán aquí una vez que se ejecuten y completen las simulaciones',
            style: AppTextStyles.bodySecondary,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: _cargarSimulacionesCompletadas,
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: Text('Actualizar', style: AppTextStyles.button.copyWith(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6.r),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 