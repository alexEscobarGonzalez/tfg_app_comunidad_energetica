import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/widgets/loading_indicators.dart';
import '../providers/activo_generacion_provider.dart';
import '../providers/activo_almacenamiento_provider.dart';
import '../models/activo_generacion.dart';
import '../models/activo_almacenamiento.dart';
import '../models/enums/tipo_activo_generacion.dart';
import '../widgets/crear_activo_dialog.dart';

class ListaActivosEnergeticosView extends ConsumerStatefulWidget {
  final int idComunidad;
  final String nombreComunidad;

  const ListaActivosEnergeticosView({
    super.key,
    required this.idComunidad,
    required this.nombreComunidad,
  });

  @override
  ConsumerState<ListaActivosEnergeticosView> createState() => _ListaActivosEnergeticosViewState();
}

class _ListaActivosEnergeticosViewState extends ConsumerState<ListaActivosEnergeticosView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    ref.read(activosGeneracionProvider.notifier).loadActivosGeneracionByComunidad(widget.idComunidad);
    ref.read(activosAlmacenamientoProvider.notifier).loadActivosAlmacenamientoByComunidad(widget.idComunidad);
  }

  @override
  Widget build(BuildContext context) {
    final activosGeneracionState = ref.watch(activosGeneracionProvider);
    final activosAlmacenamientoState = ref.watch(activosAlmacenamientoProvider);

    return Column(
      children: [
        // Header con título y botón de agregar
        _buildHeader(context),
        
        // Grid con activos energéticos
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(8.w),
            child: _buildActivosGrid(activosGeneracionState, activosAlmacenamientoState),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
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
                  'Activos Energéticos',
                  style: AppTextStyles.tabSectionTitle,
                ),
                SizedBox(height: 4.h),
                Text(
                  widget.nombreComunidad,
                  style: AppTextStyles.tabDescription,
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _mostrarDialogoCrear(context),
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text('Agregar', style: AppTextStyles.button),
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

  Widget _buildActivosGrid(ActivosGeneracionState generacionState, ActivosAlmacenamientoState almacenamientoState) {
    final bool isLoading = generacionState.isLoading || almacenamientoState.isLoading;
    final String? error = generacionState.error ?? almacenamientoState.error;
    
    if (isLoading) {
      return _buildLoadingGrid();
    }

    if (error != null) {
      return _buildErrorWidget(error);
    }

    final activosGeneracion = generacionState.activos;
    final activosAlmacenamiento = almacenamientoState.activos;
    final totalActivos = activosGeneracion.length + activosAlmacenamiento.length;

    if (totalActivos == 0) {
      return _buildEmptyState();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.0,
        crossAxisSpacing: 8.w,
        mainAxisSpacing: 8.h,
      ),
      itemCount: totalActivos,
      itemBuilder: (context, index) {
        if (index < activosGeneracion.length) {
          return _buildActivoGeneracionCard(activosGeneracion[index]);
        } else {
          final almacenamientoIndex = index - activosGeneracion.length;
          return _buildActivoAlmacenamientoCard(activosAlmacenamiento[almacenamientoIndex]);
        }
      },
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.0,
        crossAxisSpacing: 8.w,
        mainAxisSpacing: 8.h,
      ),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: const Center(
            child: LoadingSpinner(),
          ),
        );
      },
    );
  }

  Widget _buildErrorWidget(String error) {
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
            'Error al cargar activos',
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
            onPressed: _loadData,
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
            Icons.electrical_services,
            size: 64.sp,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 16.h),
          Text(
            'No hay activos energéticos',
            style: AppTextStyles.headline3.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Comienza agregando tu primer activo energético',
            style: AppTextStyles.bodySecondary,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: () => _mostrarDialogoCrear(context),
            icon: const Icon(Icons.add),
            label: Text('Agregar Activo', style: AppTextStyles.button.copyWith(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivoGeneracionCard(ActivoGeneracion activo) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: _getTipoActivoColor(activo.tipo_activo).withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icono del activo
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: _getTipoActivoColor(activo.tipo_activo),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    _getTipoActivoIcon(activo.tipo_activo),
                    color: Colors.white,
                    size: 8.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                
                // Nombre del activo
                Text(
                  activo.nombreDescriptivo,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.cardTitle.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                
                // Tipo de activo
                Text(
                  _getTipoActivoText(activo.tipo_activo),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                
                // Potencia
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: _getTipoActivoColor(activo.tipo_activo).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    '${activo.potenciaNominal_kWp.toStringAsFixed(1)} kWp',
                    style: AppTextStyles.cardSubtitle.copyWith(
                      color: _getTipoActivoColor(activo.tipo_activo),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 1.0,
            right: 1.0,
            child: PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: AppColors.textSecondary,
                size: 4.sp,
              ),
              onSelected: (value) => _onActivoGeneracionAction(value, activo),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'ver',
                  child: Row(
                    children: [
                      const Icon(Icons.visibility, size: 16, color: AppColors.info),
                      const SizedBox(width: 8),
                      Text('Ver detalles', style: AppTextStyles.bodyMedium),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'editar',
                  child: Row(
                    children: [
                      const Icon(Icons.edit, size: 16, color: AppColors.warning),
                      const SizedBox(width: 8),
                      Text('Editar', style: AppTextStyles.bodyMedium),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'eliminar',
                  child: Row(
                    children: [
                      const Icon(Icons.delete, size: 16, color: AppColors.error),
                      const SizedBox(width: 8),
                      Text(
                        'Eliminar', 
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivoAlmacenamientoCard(ActivoAlmacenamiento activo) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.battery.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icono del activo
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: AppColors.battery,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.battery_charging_full,
                    color: Colors.white,
                    size: 8.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                
                // ID del activo
                Text(
                  activo.nombreDescriptivo ?? 'Batería #${activo.idActivoAlmacenamiento}',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.cardTitle.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                
                // Tipo de activo
                Text(
                  'Sistema de Almacenamiento',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                
                // Capacidad
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppColors.battery.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    '${activo.capacidadNominal_kWh.toStringAsFixed(1)} kWh',
                    style: AppTextStyles.cardSubtitle.copyWith(
                      color: AppColors.battery,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 1.0,
            right: 1.0,
            child: PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: AppColors.textSecondary,
                size: 4.sp,
              ),
              onSelected: (value) => _onActivoAlmacenamientoAction(value, activo),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'ver',
                  child: Row(
                    children: [
                      const Icon(Icons.visibility, size: 16, color: AppColors.info),
                      const SizedBox(width: 8),
                      Text('Ver detalles', style: AppTextStyles.bodyMedium),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'editar',
                  child: Row(
                    children: [
                      const Icon(Icons.edit, size: 16, color: AppColors.warning),
                      const SizedBox(width: 8),
                      Text('Editar', style: AppTextStyles.bodyMedium),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'eliminar',
                  child: Row(
                    children: [
                      const Icon(Icons.delete, size: 16, color: AppColors.error),
                      const SizedBox(width: 8),
                      Text(
                        'Eliminar', 
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getTipoActivoColor(TipoActivoGeneracion tipo) {
    switch (tipo) {
      case TipoActivoGeneracion.INSTALACION_FOTOVOLTAICA:
        return AppColors.solar;
      case TipoActivoGeneracion.AEROGENERADOR:
        return AppColors.wind;
    }
  }

  IconData _getTipoActivoIcon(TipoActivoGeneracion tipo) {
    switch (tipo) {
      case TipoActivoGeneracion.INSTALACION_FOTOVOLTAICA:
        return Icons.solar_power;
      case TipoActivoGeneracion.AEROGENERADOR:
        return Icons.air;
    }
  }

  String _getTipoActivoText(TipoActivoGeneracion tipo) {
    switch (tipo) {
      case TipoActivoGeneracion.INSTALACION_FOTOVOLTAICA:
        return 'Instalación Fotovoltaica';
      case TipoActivoGeneracion.AEROGENERADOR:
        return 'Aerogenerador';
    }
  }

  void _mostrarDialogoCrear(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CrearActivoDialog(
        idComunidad: widget.idComunidad,
      ),
    );
  }

  void _onActivoGeneracionAction(String action, ActivoGeneracion activo) {
    switch (action) {
      case 'ver':
        _mostrarDialogoDetallesGeneracion(activo);
        break;
      case 'editar':
        _mostrarDialogoEditarGeneracion(activo);
        break;
      case 'eliminar':
        _mostrarDialogoEliminarGeneracion(activo);
        break;
    }
  }

  void _onActivoAlmacenamientoAction(String action, ActivoAlmacenamiento activo) {
    switch (action) {
      case 'ver':
        _mostrarDialogoDetallesAlmacenamiento(activo);
        break;
      case 'editar':
        _mostrarDialogoEditarAlmacenamiento(activo);
        break;
      case 'eliminar':
        _mostrarDialogoEliminarAlmacenamiento(activo);
        break;
    }
  }

  void _mostrarDialogoDetallesGeneracion(ActivoGeneracion activo) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        child: Container(
          width: 500.w,
          constraints: BoxConstraints(maxHeight: 600.h),
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header fijo
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: _getTipoActivoColor(activo.tipo_activo),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      _getTipoActivoIcon(activo.tipo_activo),
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activo.nombreDescriptivo,
                          style: AppTextStyles.headline4.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _getTipoActivoText(activo.tipo_activo),
                          style: AppTextStyles.bodySecondary,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              
              SizedBox(height: 20.h),
              
              // Contenido con scroll
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Información general
                      _buildSeccionDetalle('Información General', [
                        _buildDetalleItem('Potencia Nominal', '${activo.potenciaNominal_kWp.toStringAsFixed(1)} kWp'),
                        _buildDetalleItem('Fecha de Instalación', activo.fechaInstalacion.toString().split(' ')[0]),
                        _buildDetalleItem('Coste de Instalación', '€${activo.costeInstalacion_eur.toStringAsFixed(2)}'),
                        _buildDetalleItem('Vida Útil', '${activo.vidaUtil_anios} años'),
                        _buildDetalleItem('Ubicación', '${activo.latitud.toStringAsFixed(4)}, ${activo.longitud.toStringAsFixed(4)}'),
                      ]),
                      
                      SizedBox(height: 16.h),
                      
                      // Información específica
                      if (activo.tipo_activo == TipoActivoGeneracion.INSTALACION_FOTOVOLTAICA) ...[
                        _buildSeccionDetalle('Configuración Fotovoltaica', [
                          _buildDetalleItem('Inclinación', '${activo.inclinacionGrados ?? 'N/A'}°'),
                          _buildDetalleItem('Azimut', '${activo.azimutGrados ?? 'N/A'}°'),
                          _buildDetalleItem('Tecnología', activo.tecnologiaPanel ?? 'N/A'),
                          _buildDetalleItem('Pérdidas del Sistema', '${activo.perdidaSistema ?? 'N/A'}%'),
                          _buildDetalleItem('Tipo de Montaje', activo.posicionMontaje ?? 'N/A'),
                        ]),
                      ] else if (activo.tipo_activo == TipoActivoGeneracion.AEROGENERADOR) ...[
                        _buildSeccionDetalle('Configuración Aerogenerador', [
                          _buildDetalleItem('Curva de Potencia', activo.curvaPotencia != null ? 'Configurada' : 'No configurada'),
                          if (activo.curvaPotencia != null)
                            _buildDetalleItem('Puntos en Curva', '${activo.curvaPotencia!.length} velocidades'),
                        ]),
                      ],
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 20.h),
              
              // Botones fijos
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _mostrarDialogoEditarGeneracion(activo);
                      },
                      icon: const Icon(Icons.edit),
                      label: Text('Editar', style: AppTextStyles.button),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cerrar', style: AppTextStyles.button.copyWith(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarDialogoDetallesAlmacenamiento(ActivoAlmacenamiento activo) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        child: Container(
          width: 500.w,
          constraints: BoxConstraints(maxHeight: 500.h),
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header fijo
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppColors.battery,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.battery_charging_full,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activo.nombreDescriptivo ?? 'Batería #${activo.idActivoAlmacenamiento}',
                          style: AppTextStyles.headline4.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Sistema de Almacenamiento',
                          style: AppTextStyles.bodySecondary,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              
              SizedBox(height: 20.h),
              
              // Contenido con scroll
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Información técnica
                      _buildSeccionDetalle('Especificaciones Técnicas', [
                        _buildDetalleItem('Capacidad Nominal', '${activo.capacidadNominal_kWh?.toStringAsFixed(1) ?? 'N/A'} kWh'),
                        _buildDetalleItem('Potencia Máx. Carga', '${activo.potenciaMaximaCarga_kW?.toStringAsFixed(1) ?? 'N/A'} kW'),
                        _buildDetalleItem('Potencia Máx. Descarga', '${activo.potenciaMaximaDescarga_kW?.toStringAsFixed(1) ?? 'N/A'} kW'),
                        _buildDetalleItem('Eficiencia Ciclo Completo', '${activo.eficienciaCicloCompleto_pct?.toStringAsFixed(1) ?? 'N/A'}%'),
                        _buildDetalleItem('Profundidad Descarga Máx.', '${activo.profundidadDescargaMax_pct?.toStringAsFixed(1) ?? 'N/A'}%'),
                      ]),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 20.h),
              
              // Botones fijos
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _mostrarDialogoEditarAlmacenamiento(activo);
                      },
                      icon: const Icon(Icons.edit),
                      label: Text('Editar', style: AppTextStyles.button),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cerrar', style: AppTextStyles.button.copyWith(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeccionDetalle(String titulo, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: AppTextStyles.cardTitle.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildDetalleItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTextStyles.bodySecondary,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoEditarGeneracion(ActivoGeneracion activo) {
    showDialog(
      context: context,
      builder: (context) => CrearActivoDialog(
        idComunidad: widget.idComunidad,
        activoGeneracionEditar: activo,
      ),
    ).then((_) {
      // Recargar datos después de editar
      _loadData();
    });
  }

  void _mostrarDialogoEditarAlmacenamiento(ActivoAlmacenamiento activo) {
    showDialog(
      context: context,
      builder: (context) => CrearActivoDialog(
        idComunidad: widget.idComunidad,
        activoAlmacenamientoEditar: activo,
      ),
    ).then((_) {
      // Recargar datos después de editar
      _loadData();
    });
  }

  void _mostrarDialogoEliminarGeneracion(ActivoGeneracion activo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar activo de generación', style: AppTextStyles.headline4),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${activo.nombreDescriptivo}"?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: AppTextStyles.button),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref
                  .read(activosGeneracionProvider.notifier)
                  .deleteActivoGeneracion(activo.idActivoGeneracion);
              
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Activo de generación eliminado correctamente',
                      style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                    ),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text('Eliminar', style: AppTextStyles.button.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoEliminarAlmacenamiento(ActivoAlmacenamiento activo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar sistema de almacenamiento', style: AppTextStyles.headline4),
        content: Text(
          '¿Estás seguro de que deseas eliminar la batería #${activo.idActivoAlmacenamiento}?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: AppTextStyles.button),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref
                  .read(activosAlmacenamientoProvider.notifier)
                  .deleteActivoAlmacenamiento(activo.idActivoAlmacenamiento);
              
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Sistema de almacenamiento eliminado correctamente',
                      style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                    ),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text('Eliminar', style: AppTextStyles.button.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
} 