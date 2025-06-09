import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/widgets/loading_indicators.dart';
import '../providers/simulacion_provider.dart';
import '../providers/comunidad_energetica_provider.dart';
import '../providers/user_provider.dart';
import '../services/simulacion_api_service.dart';
import '../models/simulacion.dart';
import '../models/enums/estado_simulacion.dart';
import '../widgets/crear_simulacion_dialog.dart';

class SimulacionView extends ConsumerWidget {
  const SimulacionView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comunidadSeleccionada = ref.watch(comunidadSeleccionadaProvider);

    if (comunidadSeleccionada == null) {
      return _buildNoCommunitySelected();
    }

    return Column(
      children: [
        // Header con título y botón de agregar
        _buildHeader(context, comunidadSeleccionada.idComunidadEnergetica, ref),
        
        // Grid con simulaciones
        Expanded(
          child: _buildSimulacionesContent(comunidadSeleccionada.idComunidadEnergetica, ref),
        ),
      ],
    );
  }

  Widget _buildNoCommunitySelected() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.science_outlined,
            size: 64.sp,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 16.h),
          Text(
            'No hay comunidad seleccionada',
            style: AppTextStyles.headline3.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Selecciona una comunidad para gestionar simulaciones',
            style: AppTextStyles.bodySecondary,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int idComunidad, WidgetRef ref) {
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Simulaciones',
                  style: AppTextStyles.tabSectionTitle,
                ),
                SizedBox(height: 4.h),
                Text(
                  comunidadSeleccionada?.nombre ?? 'Gestiona simulaciones energéticas',
                  style: AppTextStyles.tabDescription,
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _mostrarDialogoCrear(context, idComunidad, ref),
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text(
              'Agregar',
              style: AppTextStyles.button.copyWith(color: Colors.white),
            ),
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

  Widget _buildSimulacionesContent(int idComunidad, WidgetRef ref) {
    final simulacionesAsync = ref.watch(simulacionesComunidadProvider(idComunidad));

    return simulacionesAsync.when(
      data: (simulaciones) => _buildSimulacionesGrid(simulaciones, ref),
      loading: () => _buildLoadingGrid(),
      error: (error, stack) => _buildErrorWidget(error.toString(), idComunidad, ref),
    );
  }

  Widget _buildSimulacionesGrid(List<Simulacion> simulaciones, WidgetRef ref) {
    if (simulaciones.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => ref.refresh(simulacionesComunidadProvider(simulaciones.first.idComunidadEnergetica).future),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(8.w),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.2,
            crossAxisSpacing: 8.w,
            mainAxisSpacing: 8.h,
          ),
          itemCount: simulaciones.length,
          itemBuilder: (context, index) {
            final simulacion = simulaciones[index];
            return _buildSimulacionCard(simulacion, ref);
          },
        ),
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      padding: EdgeInsets.all(8.w),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.2,
        crossAxisSpacing: 8.w,
        mainAxisSpacing: 8.h,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Card(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: const Center(
              child: LoadingSpinner(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorWidget(String error, int idComunidad, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64.sp,
            color: AppColors.error,
          ),
          SizedBox(height: 16.h),
          Text(
            'Error al cargar simulaciones',
            style: AppTextStyles.headline3.copyWith(
              color: AppColors.error,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            error,
            style: AppTextStyles.bodySecondary,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () => ref.refresh(simulacionesComunidadProvider(idComunidad)),
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
          Icon(
            Icons.science_outlined,
            size: 64.sp,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 16.h),
          Text(
            'No hay simulaciones',
            style: AppTextStyles.headline3.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Crea tu primera simulación para analizar\nel comportamiento energético',
            style: AppTextStyles.bodySecondary,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSimulacionCard(Simulacion simulacion, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: _getEstadoColor(simulacion.estado).withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Estado y nombre
          Row(
            children: [
              Expanded(
                child: Text(
                  simulacion.nombreSimulacion,
                  style: AppTextStyles.cardTitle.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 4.w),
              _buildEstadoChip(simulacion.estado),
            ],
          ),
          
          SizedBox(height: 8.h),
          
          // Información de período
          Text(
            'Período: ${_formatearFecha(simulacion.fechaInicio)} - ${_formatearFecha(simulacion.fechaFin)}',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          SizedBox(height: 4.h),
          
          // Estrategia
          Text(
            _getEstrategiaTexto(simulacion.tipoEstrategiaExcedentes),
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const Spacer(),
          
          // Botones de acción
          Column(
            children: [
              // Botón de ejecución (si aplica)
              if (simulacion.estado == EstadoSimulacion.PENDIENTE) ...[
                SizedBox(
                  child: _buildBotonEjecutar(simulacion, ref),
                ),
                SizedBox(height: 20.h),
              ],
              
              // Botones de acción principales
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (simulacion.estado == EstadoSimulacion.PENDIENTE)
                    _buildActionButton(
                      icon: Icons.edit,
                      color: AppColors.primary,
                      onPressed: () => _editarSimulacion(simulacion, ref),
                    ),
                  if (simulacion.estado != EstadoSimulacion.EJECUTANDO)
                    _buildActionButton(
                      icon: Icons.copy,
                      color: AppColors.secondary,
                      onPressed: () => _clonarSimulacion(simulacion, ref),
                    ),
                  _buildActionButton(
                    icon: Icons.delete,
                    color: AppColors.error,
                    onPressed: () => _eliminarSimulacion(simulacion, ref),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEstadoChip(EstadoSimulacion estado) {
    final color = _getEstadoColor(estado);
    final texto = _getEstadoTexto(estado);
    final icono = _getEstadoIcon(estado);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 6.sp, color: color),
          SizedBox(width: 2.w),
          Text(
            texto,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotonEjecutar(Simulacion simulacion, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () => _ejecutarSimulacion(simulacion, ref),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.success,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        minimumSize: Size(0, 18.h),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.play_arrow, size: 6.sp),
          SizedBox(width: 2.w),
          Text(
            'Ejecutar',
            style: AppTextStyles.caption.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(6.r),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Icon(
          icon,
          color: color,
          size: 6.sp,
        ),
      ),
    );
  }

  // Métodos auxiliares
  Color _getEstadoColor(EstadoSimulacion estado) {
    switch (estado) {
      case EstadoSimulacion.PENDIENTE:
        return AppColors.warning;
      case EstadoSimulacion.EJECUTANDO:
        return AppColors.primary;
      case EstadoSimulacion.COMPLETADA:
        return AppColors.success;
      case EstadoSimulacion.FALLIDA:
        return AppColors.error;
    }
  }

  String _getEstadoTexto(EstadoSimulacion estado) {
    switch (estado) {
      case EstadoSimulacion.PENDIENTE:
        return 'Pendiente';
      case EstadoSimulacion.EJECUTANDO:
        return 'Ejecutando';
      case EstadoSimulacion.COMPLETADA:
        return 'Completada';
      case EstadoSimulacion.FALLIDA:
        return 'Fallida';
    }
  }

  IconData _getEstadoIcon(EstadoSimulacion estado) {
    switch (estado) {
      case EstadoSimulacion.PENDIENTE:
        return Icons.schedule;
      case EstadoSimulacion.EJECUTANDO:
        return Icons.play_circle_outline;
      case EstadoSimulacion.COMPLETADA:
        return Icons.check_circle;
      case EstadoSimulacion.FALLIDA:
        return Icons.error;
    }
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }

  String _getEstrategiaTexto(dynamic estrategia) {
    // Implementar según el enum TipoEstrategiaExcedentes
    return estrategia.toString().split('.').last.replaceAll('_', ' ');
  }

  // Métodos de acción
  void _mostrarDialogoCrear(BuildContext context, int idComunidad, WidgetRef ref) async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (context) => CrearSimulacionDialog(idComunidad: idComunidad),
    );
    
    if (resultado == true) {
      // Refrescar lista de simulaciones
      ref.refresh(simulacionesComunidadProvider(idComunidad));
    }
  }

  Future<void> _ejecutarSimulacion(Simulacion simulacion, WidgetRef ref) async {
    try {
      final exito = await SimulacionApiService.ejecutarSimulacion(simulacion.idSimulacion);
      if (exito) {
        // Refrescar lista para ver el cambio de estado
        ref.refresh(simulacionesComunidadProvider(simulacion.idComunidadEnergetica));
      }
    } catch (e) {
      // Manejar error
      print('Error ejecutando simulación: $e');
    }
  }

  void _editarSimulacion(Simulacion simulacion, WidgetRef ref) async {
    final resultado = await showDialog<bool>(
      context: ref.context,
      builder: (context) => CrearSimulacionDialog(
        idComunidad: simulacion.idComunidadEnergetica,
        simulacionParaEditar: simulacion,
      ),
    );
    
    if (resultado == true) {
      // Refrescar lista de simulaciones
      ref.refresh(simulacionesComunidadProvider(simulacion.idComunidadEnergetica));
    }
  }

  Future<void> _eliminarSimulacion(Simulacion simulacion, WidgetRef ref) async {
    // Implementar confirmación y eliminación
    try {
      final exito = await SimulacionApiService.eliminarSimulacion(simulacion.idSimulacion);
      if (exito) {
        ref.refresh(simulacionesComunidadProvider(simulacion.idComunidadEnergetica));
      }
    } catch (e) {
      print('Error eliminando simulación: $e');
    }
  }

  Future<void> _clonarSimulacion(Simulacion simulacion, WidgetRef ref) async {
    try {
      // Obtener el usuario actual
      final authState = ref.read(authProvider);
      if (!authState.isLoggedIn || authState.usuario == null) {
        print('Error: Usuario no autenticado');
        return;
      }
      final usuario = authState.usuario!;

      // Crear una nueva simulación con los mismos datos pero nombre diferente
      final nombreClonado = '${simulacion.nombreSimulacion} (Copia)';
      
      // Crear la simulación clonada con estado PENDIENTE
      final nuevaSimulacion = Simulacion(
        idSimulacion: 0, // Se asignará automáticamente
        nombreSimulacion: nombreClonado,
        idComunidadEnergetica: simulacion.idComunidadEnergetica,
        fechaInicio: simulacion.fechaInicio,
        fechaFin: simulacion.fechaFin,
        tiempo_medicion: simulacion.tiempo_medicion,
        tipoEstrategiaExcedentes: simulacion.tipoEstrategiaExcedentes,
        estado: EstadoSimulacion.PENDIENTE,
        idUsuario_creador: usuario.idUsuario,
      );
      
      // Crear la simulación usando el servicio API
      final nuevaSimulacionCreada = await SimulacionApiService.crearSimulacion(nuevaSimulacion);
      if (nuevaSimulacionCreada != null) {
        ref.refresh(simulacionesComunidadProvider(simulacion.idComunidadEnergetica));
      }
    } catch (e) {
      print('Error clonando simulación: $e');
    }
  }
} 