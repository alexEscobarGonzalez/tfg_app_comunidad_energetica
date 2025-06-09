import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/simulacion.dart';
import '../../models/resultado_simulacion_participante.dart';
import '../../providers/simulacion_provider.dart';

class TabTablasComparativas extends ConsumerWidget {
  final Simulacion simulacionSeleccionada;

  const TabTablasComparativas({
    super.key,
    required this.simulacionSeleccionada,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final participantesAsync = ref.watch(resultadosParticipantesProvider(simulacionSeleccionada.idSimulacion!));

    return SingleChildScrollView(
      padding: EdgeInsets.all(6.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: 24.h),
          participantesAsync.when(
            data: (participantes) => _buildTablasComparativas(participantes),
            loading: () => _buildLoadingState(),
            error: (error, stack) => _buildErrorState(error.toString()),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(8.w),
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
            Icons.table_chart,
            color: Colors.white,
            size: 20.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Comparación Entre Participantes',
                  style: AppTextStyles.headline4.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  simulacionSeleccionada.nombreSimulacion,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Text(
              'Tablas',
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

  Widget _buildTablasComparativas(List<ResultadoSimulacionParticipante> participantes) {
    if (participantes.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTablaEconomica(participantes),
        SizedBox(height: 24.h),
        _buildTablaEnergetica(participantes),
        SizedBox(height: 24.h),
        _buildResumenComparativo(participantes),
      ],
    );
  }

  Widget _buildTablaEconomica(List<ResultadoSimulacionParticipante> participantes) {
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
          _buildSeccionHeader(
            'Comparación Económica',
            Icons.attach_money,
            AppColors.primary,
          ),
          SizedBox(height: 16.h),
          _buildTablaEconomicaContent(participantes),
        ],
      ),
    );
  }

  Widget _buildTablaEconomicaContent(List<ResultadoSimulacionParticipante> participantes) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: DataTable(
          headingRowColor: WidgetStateColor.resolveWith(
            (states) => AppColors.primary.withValues(alpha: 0.1),
          ),
          headingTextStyle: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
          dataTextStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
          ),
          columnSpacing: 24.w,
          horizontalMargin: 16.w,
          columns: [
            DataColumn(
              label: Text('Participante'),
            ),
            DataColumn(
              label: Text('Coste Neto'),
              numeric: true,
            ),
            DataColumn(
              label: Text('Ahorro Total'),
              numeric: true,
            ),
            DataColumn(
              label: Text('% Ahorro'),
              numeric: true,
            ),
          ],
          rows: participantes.map((participante) {
            final costeNeto = participante.costeNetoParticipante_eur ?? 0.0;
            final ahorro = participante.ahorroParticipante_eur ?? 0.0;
            final porcentajeAhorro = costeNeto != 0 ? (ahorro.abs() / costeNeto.abs()) * 100 : 0.0;
            
            return DataRow(
              cells: [
                DataCell(
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Text(
                      'Participante ${participante.idParticipante}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  _buildCeldaMonetaria(costeNeto, '€', AppColors.error),
                ),
                DataCell(
                  _buildCeldaMonetaria(ahorro, '€', AppColors.success),
                ),
                DataCell(
                  _buildCeldaPercentage(porcentajeAhorro),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTablaEnergetica(List<ResultadoSimulacionParticipante> participantes) {
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
          _buildSeccionHeader(
            'Comparación Energética',
            Icons.electrical_services,
            AppColors.solar,
          ),
          SizedBox(height: 16.h),
          _buildTablaEnergeticaContent(participantes),
        ],
      ),
    );
  }

  Widget _buildTablaEnergeticaContent(List<ResultadoSimulacionParticipante> participantes) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: DataTable(
          headingRowColor: WidgetStateColor.resolveWith(
            (states) => AppColors.solar.withValues(alpha: 0.1),
          ),
          headingTextStyle: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.solar,
          ),
          dataTextStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
          ),
          columnSpacing: 24.w,
          horizontalMargin: 16.w,
          columns: [
            DataColumn(
              label: Text('Participante'),
            ),
            DataColumn(
              label: Text('SCR Individual'),
              numeric: true,
            ),
            DataColumn(
              label: Text('SSR Individual'),
              numeric: true,
            ),
            DataColumn(
              label: Text('Clasificación'),
            ),
          ],
          rows: participantes.map((participante) {
            final scr = participante.tasaAutoconsumoSCR_pct ?? 0.0;
            final ssr = participante.tasaAutosuficienciaSSR_pct ?? 0.0;
            
            return DataRow(
              cells: [
                DataCell(
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Text(
                      'Participante ${participante.idParticipante}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  _buildCeldaPercentage(scr),
                ),
                DataCell(
                  _buildCeldaPercentage(ssr),
                ),
                DataCell(
                  _buildCeldaClasificacion(scr, ssr),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildResumenComparativo(List<ResultadoSimulacionParticipante> participantes) {
    // Calcular estadísticas
    final ahorros = participantes.map((p) => p.ahorroParticipante_eur ?? 0.0).toList();
    final scrs = participantes.map((p) => p.tasaAutoconsumoSCR_pct ?? 0.0).toList();
    final ssrs = participantes.map((p) => p.tasaAutosuficienciaSSR_pct ?? 0.0).toList();

    final ahorroPromedio = ahorros.isNotEmpty ? ahorros.reduce((a, b) => a + b) / ahorros.length : 0.0;
    final scrPromedio = scrs.isNotEmpty ? scrs.reduce((a, b) => a + b) / scrs.length : 0.0;
    final ssrPromedio = ssrs.isNotEmpty ? ssrs.reduce((a, b) => a + b) / ssrs.length : 0.0;

    final mejorParticipanteAhorro = participantes.isNotEmpty 
        ? participantes.reduce((a, b) => (a.ahorroParticipante_eur ?? 0) > (b.ahorroParticipante_eur ?? 0) ? a : b)
        : null;

    final mejorParticipanteSCR = participantes.isNotEmpty 
        ? participantes.reduce((a, b) => (a.tasaAutoconsumoSCR_pct ?? 0) > (b.tasaAutoconsumoSCR_pct ?? 0) ? a : b)
        : null;

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
          _buildSeccionHeader(
            'Resumen Comparativo',
            Icons.analytics,
            AppColors.secondary,
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildEstadisticaCard(
                  'Ahorro Promedio',
                  '${ahorroPromedio.toStringAsFixed(0)} €',
                  Icons.savings,
                  AppColors.success,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildEstadisticaCard(
                  'SCR Promedio',
                  '${scrPromedio.toStringAsFixed(1)}%',
                  Icons.solar_power,
                  AppColors.warning,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildEstadisticaCard(
                  'SSR Promedio',
                  '${ssrPromedio.toStringAsFixed(1)}%',
                  Icons.battery_charging_full,
                  AppColors.info,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          if (mejorParticipanteAhorro != null && mejorParticipanteSCR != null) ...[
            Text(
              'Mejores Participantes',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  child: _buildMejorParticipanteCard(
                    'Mayor Ahorro',
                    'Participante ${mejorParticipanteAhorro.idParticipante}',
                    '${mejorParticipanteAhorro.ahorroParticipante_eur?.toStringAsFixed(0) ?? '0'} €',
                    Icons.trending_up,
                    AppColors.success,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildMejorParticipanteCard(
                    'Mayor SCR',
                    'Participante ${mejorParticipanteSCR.idParticipante}',
                    '${mejorParticipanteSCR.tasaAutoconsumoSCR_pct?.toStringAsFixed(1) ?? '0'}%',
                    Icons.solar_power,
                    AppColors.warning,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSeccionHeader(String titulo, IconData icono, Color color) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            icono,
            color: color,
            size: 16.sp,
          ),
        ),
        SizedBox(width: 12.w),
        Text(
          titulo,
          style: AppTextStyles.headline4.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildCeldaMonetaria(double valor, String unidad, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        '${valor.toStringAsFixed(0)} $unidad',
        style: AppTextStyles.bodyMedium.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCeldaPercentage(double valor) {
    Color color = AppColors.info;
    if (valor >= 80) color = AppColors.success;
    else if (valor >= 60) color = AppColors.warning;
    else color = AppColors.error;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        '${valor.toStringAsFixed(1)}%',
        style: AppTextStyles.bodyMedium.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCeldaClasificacion(double scr, double ssr) {
    String clasificacion;
    Color color;
    
    final promedio = (scr + ssr) / 2;
    
    if (promedio >= 80) {
      clasificacion = 'Excelente';
      color = AppColors.success;
    } else if (promedio >= 60) {
      clasificacion = 'Bueno';
      color = AppColors.warning;
    } else if (promedio >= 40) {
      clasificacion = 'Regular';
      color = AppColors.info;
    } else {
      clasificacion = 'Bajo';
      color = AppColors.error;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        clasificacion,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEstadisticaCard(String titulo, String valor, IconData icono, Color color) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icono, color: color, size: 16.sp),
          SizedBox(height: 4.h),
          Text(
            titulo,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            valor,
            style: AppTextStyles.bodyLarge.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMejorParticipanteCard(String categoria, String participante, String valor, IconData icono, Color color) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, color: color, size: 14.sp),
              SizedBox(width: 4.w),
              Text(
                categoria,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            participante,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            valor,
            style: AppTextStyles.bodyLarge.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 400.h,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.info),
            SizedBox(height: 16.h),
            Text(
              'Cargando tablas comparativas...',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(Icons.error, color: AppColors.error, size: 48.sp),
          SizedBox(height: 16.h),
          Text(
            'Error al cargar datos',
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
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(Icons.people_outline, color: AppColors.textHint, size: 48.sp),
          SizedBox(height: 16.h),
          Text(
            'Sin participantes para comparar',
            style: AppTextStyles.headline4.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'No se encontraron participantes en esta simulación.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textHint,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
} 