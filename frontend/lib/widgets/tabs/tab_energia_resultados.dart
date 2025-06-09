import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:reorderable_staggered_scroll_view/reorderable_staggered_scroll_view.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/simulacion.dart';
import '../../models/resultado_simulacion.dart';
import '../../models/resultado_simulacion_participante.dart';
import '../../providers/participante_provider.dart';
import '../../services/simulacion_api_service.dart';
import '../../providers/simulacion_provider.dart';

class TabEnergiaResultados extends ConsumerStatefulWidget {
  final Simulacion simulacionSeleccionada;

  const TabEnergiaResultados({
    super.key,
    required this.simulacionSeleccionada,
  });

  @override
  ConsumerState<TabEnergiaResultados> createState() => _TabEnergiaResultadosState();
}

class _TabEnergiaResultadosState extends ConsumerState<TabEnergiaResultados> {
  bool _dragEnabled = true;
  List<String> _kpiOrder = [
    'tasaAutoconsumoSCR',
    'tasaAutosuficienciaSSR',
    'reduccionCO2',
  ];

  @override
  Widget build(BuildContext context) {
    final resultadoAsync = ref.watch(resultadoSimulacionProvider(widget.simulacionSeleccionada.idSimulacion!));

    return resultadoAsync.when(
      data: (resultado) => _buildContent(resultado),
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(error.toString()),
    );
  }

  Widget _buildContent(ResultadoSimulacion? resultado) {
    if (resultado == null) {
      return _buildNoDataState();
    }

    final participantesAsync = ref.watch(resultadosParticipantesProvider(widget.simulacionSeleccionada.idSimulacion!));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        SizedBox(height: 24.h),
        _buildCommunitySection(resultado),
        SizedBox(height: 24.h),
        participantesAsync.when(
          data: (participantes) => _buildParticipantesSection(participantes),
          loading: () => _buildParticipantesLoadingState(),
          error: (error, stack) => _buildParticipantesErrorState(error.toString()),
        ),
      ],
    );
  }

  Widget _buildHeader() {
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
            Icons.energy_savings_leaf,
            color: Colors.white,
            size: 12.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Análisis Energético de la Comunidad',
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
              'Energía',
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

  Widget _buildCommunitySection(ResultadoSimulacion resultado) {
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
          SizedBox(height: 16.h),
          _buildKPIGrid(resultado),
        ],
      ),
    );
  }

  Widget _buildKPIGrid(ResultadoSimulacion resultado) {
    return ReorderableStaggeredScrollView.grid(
      enable: _dragEnabled,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      isLongPressDraggable: false,
      onDragEnd: (details, item) {
        print('onDragEnd: $details ${item.key}');
      },
      children: _kpiOrder.asMap().entries.map((entry) {
        final index = entry.key;
        final kpiType = entry.value;
        return _buildKPIGridItem(kpiType, resultado, index);
      }).toList(),
    );
  }

  ReorderableStaggeredScrollViewGridCountItem _buildKPIGridItem(String kpiType, ResultadoSimulacion resultado, int index) {
    late final String title;
    late final String value;
    late final String unit;
    late final IconData icon;
    late final Color color;
    late final Color backgroundColor;
    late final String description;

    switch (kpiType) {
      case 'tasaAutoconsumoSCR':
        title = 'Tasa de Autoconsumo (SCR)';
        value = resultado.tasaAutoconsumoSCR_pct?.toStringAsFixed(1) ?? 'N/A';
        unit = '%';
        icon = Icons.bolt;
        color = AppColors.success;
        backgroundColor = AppColors.success.withValues(alpha: 0.1);
        description = 'Porcentaje de energía generada que se consume directamente';
        break;
      case 'tasaAutosuficienciaSSR':
        title = 'Tasa de Autosuficiencia (SSR)';
        value = resultado.tasaAutosuficienciaSSR_pct?.toStringAsFixed(1) ?? 'N/A';
        unit = '%';
        icon = Icons.home;
        color = AppColors.primary;
        backgroundColor = AppColors.primary.withValues(alpha: 0.1);
        description = 'Porcentaje de demanda cubierta con energía propia';
        break;
      case 'reduccionCO2':
        title = 'Reducción de CO₂';
        value = resultado.reduccionCO2_kg?.toStringAsFixed(2) ?? 'N/A';
        unit = 'kg';
        icon = Icons.co2;
        color = AppColors.success;
        backgroundColor = AppColors.success.withValues(alpha: 0.1);
        description = 'Reducción de emisiones de CO₂ respecto a la red eléctrica';
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
      case 'tasaAutoconsumoSCR':
      case 'tasaAutosuficienciaSSR':
      case 'reduccionCO2':
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

  Widget _buildParticipantesSection(List<ResultadoSimulacionParticipante> participantes) {
    if (participantes.isEmpty) {
      return _buildNoParticipantesState();
    }

    final participantesState = ref.watch(participantesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildParticipantesHeader(),
        SizedBox(height: 16.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.1,
            crossAxisSpacing: 8.w,
            mainAxisSpacing: 8.h,
          ),
          itemCount: participantes.length,
          itemBuilder: (context, index) {
            final participante = participantes[index];
            
            // Buscar el nombre del participante
            final participanteInfo = participantesState.participantes.firstWhere(
              (p) => p.idParticipante == participante.idParticipante,
              orElse: () => throw StateError('Participante no encontrado'),
            );
            
            return _buildParticipanteCard(participante, participanteInfo.nombre);
          },
        ),
      ],
    );
  }

  Widget _buildParticipantesHeader() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.secondary, AppColors.secondary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(
            Icons.people,
            color: Colors.white,
            size: 12.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Análisis Energético por Participante Individual',
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
              'Individual',
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

  Widget _buildParticipanteCard(ResultadoSimulacionParticipante participante, String nombreParticipante) {
    return Container(
      padding: EdgeInsets.all(8.w),
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
          // Header del participante
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppColors.solar.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.person,
                  color: AppColors.solar,
                  size: 8.sp,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  nombreParticipante,
                  style: AppTextStyles.cardTitle.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          
          // KPIs del participante
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: _buildParticipanteKPI(
                    title: 'SCR Individual',
                    value: participante.tasaAutoconsumoSCR_pct?.toStringAsFixed(1) ?? 'N/A',
                    unit: '%',
                    icon: Icons.bolt,
                    color: AppColors.success,
                    backgroundColor: AppColors.success.withValues(alpha: 0.1),
                  ),
                ),
                SizedBox(height: 8.h),
                Expanded(
                  child: _buildParticipanteKPI(
                    title: 'SSR Individual',
                    value: participante.tasaAutosuficienciaSSR_pct?.toStringAsFixed(1) ?? 'N/A',
                    unit: '%',
                    icon: Icons.home,
                    color: AppColors.primary,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipanteKPI({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
    required Color backgroundColor,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 4.sp,
                ),
              ),
              SizedBox(width: 6.w),
              Column(
                children: [
                  Text(
                    title,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Text(
                        value,
                        style: AppTextStyles.cardTitle.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      if (unit.isNotEmpty) ...[
                        SizedBox(width: 1.w),
                        Text(
                          unit,
                          style: AppTextStyles.caption.copyWith(
                            color: color.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          _buildHeader(),
          SizedBox(height: 24.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.border),
            ),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                childAspectRatio: 1.2,
              ),
              itemCount: 4,
              itemBuilder: (context, index) {
                return Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppColors.textHint.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 40.w,
                        height: 40.h,
                        decoration: BoxDecoration(
                          color: AppColors.textHint.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Container(
                        width: double.infinity,
                        height: 16.h,
                        decoration: BoxDecoration(
                          color: AppColors.textHint.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        width: 80.w,
                        height: 24.h,
                        decoration: BoxDecoration(
                          color: AppColors.textHint.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          _buildHeader(),
          SizedBox(height: 24.h),
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64.sp,
                  color: AppColors.error,
                ),
                SizedBox(height: 16.h),
                Text(
                  'Error al cargar datos energéticos',
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
                SizedBox(height: 24.h),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.refresh(resultadoSimulacionProvider(widget.simulacionSeleccionada.idSimulacion!));
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataState() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(6.w),
      child: Column(
        children: [
          _buildHeader(),
          SizedBox(height: 24.h),
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.energy_savings_leaf_outlined,
                  size: 64.sp,
                  color: AppColors.textHint,
                ),
                SizedBox(height: 16.h),
                Text(
                  'Sin resultados energéticos',
                  style: AppTextStyles.headline4.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Los resultados energéticos aparecerán una vez que la simulación se complete exitosamente.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textHint,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantesLoadingState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildParticipantesHeader(),
        SizedBox(height: 16.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.1,
            crossAxisSpacing: 8.w,
            mainAxisSpacing: 8.h,
          ),
          itemCount: 6,
          itemBuilder: (context, index) {
            return Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 24.w,
                        height: 24.h,
                        decoration: BoxDecoration(
                          color: AppColors.textSecondary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Container(
                          height: 12.h,
                          decoration: BoxDecoration(
                            color: AppColors.textSecondary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.textSecondary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.textSecondary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildParticipantesErrorState(String error) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildParticipantesHeader(),
        SizedBox(height: 16.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Icon(
                Icons.error_outline,
                size: 48.sp,
                color: AppColors.error,
              ),
              SizedBox(height: 16.h),
              Text(
                'Error al cargar datos energéticos de participantes',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                error,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              ElevatedButton.icon(
                onPressed: () {
                  ref.refresh(resultadosParticipantesProvider(widget.simulacionSeleccionada.idSimulacion!));
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNoParticipantesState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildParticipantesHeader(),
        SizedBox(height: 16.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Icon(
                Icons.people_outline,
                size: 48.sp,
                color: AppColors.textHint,
              ),
              SizedBox(height: 16.h),
              Text(
                'Sin datos energéticos de participantes',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                'No se encontraron datos energéticos para los participantes individuales.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textHint,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
} 