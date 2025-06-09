import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:reorderable_staggered_scroll_view/reorderable_staggered_scroll_view.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/simulacion.dart';
import '../../models/resultado_simulacion_activo_generacion.dart';
import '../../models/resultado_simulacion_activo_almacenamiento.dart';
import '../../services/simulacion_api_service.dart';
import '../../providers/simulacion_provider.dart';

class TabActivosResultados extends ConsumerStatefulWidget {
  final Simulacion simulacionSeleccionada;

  const TabActivosResultados({
    super.key,
    required this.simulacionSeleccionada,
  });

  @override
  ConsumerState<TabActivosResultados> createState() => _TabActivosResultadosState();
}

class _TabActivosResultadosState extends ConsumerState<TabActivosResultados> {
  bool _dragEnabled = true;
  List<String> _almacenamientoKpiOrder = [
    'energiaTotalCargada',
    'energiaTotalDescargada',
    'ciclosEquivalentes',
    'socMedio',
    'socMin',
    'socMax',
  ];

  @override
  Widget build(BuildContext context) {
    final generacionAsync = ref.watch(resultadosActivosGeneracionProvider(widget.simulacionSeleccionada.idSimulacion!));
    final almacenamientoAsync = ref.watch(resultadosActivosAlmacenamientoProvider(widget.simulacionSeleccionada.idSimulacion!));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        SizedBox(height: 24.h),
        // Sección de Generación
        generacionAsync.when(
          data: (activosGeneracion) => _buildGeneracionSection(activosGeneracion),
          loading: () => _buildGeneracionLoadingState(),
          error: (error, stack) => _buildGeneracionErrorState(error.toString()),
        ),
        SizedBox(height: 24.h),
        // Sección de Almacenamiento
        almacenamientoAsync.when(
          data: (activosAlmacenamiento) => _buildAlmacenamientoSection(activosAlmacenamiento),
          loading: () => _buildAlmacenamientoLoadingState(),
          error: (error, stack) => _buildAlmacenamientoErrorState(error.toString()),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.info, AppColors.info.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(
            Icons.devices,
            color: Colors.white,
            size: 12.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Análisis de Activos de la Comunidad',
                  style: AppTextStyles.headline4.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.simulacionSeleccionada.nombreSimulacion,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Text(
              'Activos',
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

  Widget _buildGeneracionSection(List<ResultadoSimulacionActivoGeneracion> activosGeneracion) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGeneracionHeader(),
          SizedBox(height: 16.h),
          if (activosGeneracion.isEmpty)
            _buildNoGeneracionDataState()
          else
            _buildGeneracionList(activosGeneracion),
        ],
      ),
    );
  }

  Widget _buildGeneracionHeader() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.solar, AppColors.solar.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(
            Icons.wb_sunny,
            color: Colors.white,
            size: 12.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Activos de Generación',
              style: AppTextStyles.headline4.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Text(
              'Generación',
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

  Widget _buildGeneracionList(List<ResultadoSimulacionActivoGeneracion> activosGeneracion) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activosGeneracion.length,
      separatorBuilder: (context, index) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        return _buildGeneracionCard(activosGeneracion[index], index + 1);
      },
    );
  }

  Widget _buildGeneracionCard(ResultadoSimulacionActivoGeneracion activo, int numero) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.solar.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.wb_sunny,
                  color: AppColors.solar,
                  size: 16.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Activo de Generación $numero',
                  style: AppTextStyles.headline4.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildGeneracionKPI(
            title: 'Energía Total Generada',
            value: (activo.energiaTotalGenerada_kWh != null) 
                ? (activo.energiaTotalGenerada_kWh! / 1000).toStringAsFixed(1) 
                : 'N/A',
            unit: 'MWh',
            icon: Icons.flash_on,
            color: AppColors.warning,
            backgroundColor: AppColors.warning.withValues(alpha: 0.1),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneracionKPI({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
    required Color backgroundColor,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 12.sp,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Text(
                value,
                style: AppTextStyles.headline4.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              if (unit.isNotEmpty) ...[
                SizedBox(width: 2.w),
                Text(
                  unit,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: color.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlmacenamientoSection(List<ResultadoSimulacionActivoAlmacenamiento> activosAlmacenamiento) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAlmacenamientoHeader(),
          SizedBox(height: 16.h),
          if (activosAlmacenamiento.isEmpty)
            _buildNoAlmacenamientoDataState()
          else
            _buildAlmacenamientoList(activosAlmacenamiento),
        ],
      ),
    );
  }

  Widget _buildAlmacenamientoHeader() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.battery, AppColors.battery.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(
            Icons.battery_charging_full,
            color: Colors.white,
            size: 12.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Activos de Almacenamiento',
              style: AppTextStyles.headline4.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Text(
              'Almacenamiento',
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

  Widget _buildAlmacenamientoList(List<ResultadoSimulacionActivoAlmacenamiento> activosAlmacenamiento) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activosAlmacenamiento.length,
      separatorBuilder: (context, index) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        return _buildAlmacenamientoCard(activosAlmacenamiento[index], index + 1);
      },
    );
  }

  Widget _buildAlmacenamientoCard(ResultadoSimulacionActivoAlmacenamiento activo, int numero) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.battery.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.battery_charging_full,
                  color: AppColors.battery,
                  size: 16.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Activo de Almacenamiento $numero',
                  style: AppTextStyles.headline4.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildAlmacenamientoKPIGrid(activo),
        ],
      ),
    );
  }

  Widget _buildAlmacenamientoKPIGrid(ResultadoSimulacionActivoAlmacenamiento activo) {
    return ReorderableStaggeredScrollView.grid(
      enable: _dragEnabled,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      isLongPressDraggable: false,
      onDragEnd: (details, item) {
        print('onDragEnd: $details ${item.key}');
      },
      children: _almacenamientoKpiOrder.asMap().entries.map((entry) {
        final index = entry.key;
        final kpiType = entry.value;
        return _buildAlmacenamientoKPIGridItem(kpiType, activo, index);
      }).toList(),
    );
  }

  ReorderableStaggeredScrollViewGridCountItem _buildAlmacenamientoKPIGridItem(String kpiType, ResultadoSimulacionActivoAlmacenamiento activo, int index) {
    late final String title;
    late final String value;
    late final String unit;
    late final IconData icon;
    late final Color color;
    late final Color backgroundColor;
    late final String description;

    switch (kpiType) {
      case 'energiaTotalCargada':
        title = 'Energía Total Cargada';
        value = (activo.energiaTotalCargada_kWh != null) 
            ? (activo.energiaTotalCargada_kWh! / 1000).toStringAsFixed(1) 
            : 'N/A';
        unit = 'MWh';
        icon = Icons.battery_charging_full;
        color = AppColors.success;
        backgroundColor = AppColors.success.withValues(alpha: 0.1);
        description = 'Energía total cargada en el sistema de almacenamiento';
        break;
      case 'energiaTotalDescargada':
        title = 'Energía Total Descargada';
        value = (activo.energiaTotalDescargada_kWh != null) 
            ? (activo.energiaTotalDescargada_kWh! / 1000).toStringAsFixed(1) 
            : 'N/A';
        unit = 'MWh';
        icon = Icons.battery_alert;
        color = AppColors.warning;
        backgroundColor = AppColors.warning.withValues(alpha: 0.1);
        description = 'Energía total descargada del sistema de almacenamiento';
        break;
      case 'ciclosEquivalentes':
        title = 'Ciclos Equivalentes';
        value = activo.ciclosEquivalentes?.toStringAsFixed(0) ?? 'N/A';
        unit = 'ciclos';
        icon = Icons.refresh;
        color = AppColors.info;
        backgroundColor = AppColors.info.withValues(alpha: 0.1);
        description = 'Número de ciclos completos de carga y descarga';
        break;

      case 'socMedio':
        title = 'SOC Medio';
        value = activo.socMedio_pct?.toStringAsFixed(1) ?? 'N/A';
        unit = '%';
        icon = Icons.battery_std;
        color = AppColors.primary;
        backgroundColor = AppColors.primary.withValues(alpha: 0.1);
        description = 'Estado de carga promedio durante la simulación';
        break;
      case 'socMin':
        title = 'SOC Mínimo';
        value = activo.socMin_pct?.toStringAsFixed(1) ?? 'N/A';
        unit = '%';
        icon = Icons.battery_0_bar;
        color = AppColors.error;
        backgroundColor = AppColors.error.withValues(alpha: 0.1);
        description = 'Estado de carga mínimo alcanzado';
        break;
      case 'socMax':
        title = 'SOC Máximo';
        value = activo.socMax_pct?.toStringAsFixed(1) ?? 'N/A';
        unit = '%';
        icon = Icons.battery_full;
        color = AppColors.success;
        backgroundColor = AppColors.success.withValues(alpha: 0.1);
        description = 'Estado de carga máximo alcanzado';
        break;
      default:
        title = 'Desconocido';
        value = 'N/A';
        unit = '';
        icon = Icons.help;
        color = AppColors.textSecondary;
        backgroundColor = AppColors.surface;
        description = '';
    }

    return ReorderableStaggeredScrollViewGridCountItem(
      key: ValueKey(kpiType),
      mainAxisCellCount: _getMainAxisCellCount(kpiType),
      crossAxisCellCount: 1,
      widget: _buildKPICardContent(
        title: title,
        value: value,
        unit: unit,
        icon: icon,
        color: color,
        backgroundColor: backgroundColor,
        description: description,
      ),
    );
  }

  int _getMainAxisCellCount(String kpiType) {
    switch (kpiType) {
      case 'energiaTotalCargada':
      case 'energiaTotalDescargada':
        return 1;
      case 'ciclosEquivalentes':
        return 1;
      case 'socMedio':
      case 'socMin':
      case 'socMax':
        return 1;
      default:
        return 1;
    }
  }

  Widget _buildKPICardContent({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
    required Color backgroundColor,
    required String description,
  }) {
    return Container(
      padding: EdgeInsets.all(4.w),
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 8.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Text(
                value,
                style: AppTextStyles.headline3.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              if (unit.isNotEmpty) ...[
                SizedBox(width: 1.w),
                Text(
                  unit,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: color.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
          if (description.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(
              description,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  // Estados de carga y error para Generación
  Widget _buildGeneracionLoadingState() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildGeneracionHeader(),
          SizedBox(height: 16.h),
          Container(
            height: 100.h,
            decoration: BoxDecoration(
              color: AppColors.textHint.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneracionErrorState(String error) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildGeneracionHeader(),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Column(
              children: [
                Icon(Icons.error, color: AppColors.error, size: 32.sp),
                SizedBox(height: 8.h),
                Text(
                  'Error al cargar activos de generación',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  error,
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoGeneracionDataState() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.textHint.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        children: [
          Icon(Icons.wb_sunny_outlined, color: AppColors.textHint, size: 32.sp),
          SizedBox(height: 8.h),
          Text(
            'Sin activos de generación',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'No se encontraron activos de generación para esta simulación.',
            style: AppTextStyles.caption.copyWith(color: AppColors.textHint),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Estados de carga y error para Almacenamiento
  Widget _buildAlmacenamientoLoadingState() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildAlmacenamientoHeader(),
          SizedBox(height: 16.h),
          Container(
            height: 200.h,
            decoration: BoxDecoration(
              color: AppColors.textHint.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlmacenamientoErrorState(String error) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildAlmacenamientoHeader(),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Column(
              children: [
                Icon(Icons.error, color: AppColors.error, size: 32.sp),
                SizedBox(height: 8.h),
                Text(
                  'Error al cargar activos de almacenamiento',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  error,
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoAlmacenamientoDataState() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.textHint.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        children: [
          Icon(Icons.battery_charging_full_outlined, color: AppColors.textHint, size: 32.sp),
          SizedBox(height: 8.h),
          Text(
            'Sin activos de almacenamiento',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'No se encontraron activos de almacenamiento para esta simulación.',
            style: AppTextStyles.caption.copyWith(color: AppColors.textHint),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
} 