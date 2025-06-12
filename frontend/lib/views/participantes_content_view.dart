import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/widgets/loading_indicators.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../providers/participante_provider.dart';
import '../models/participante.dart';
import '../models/contrato_autoconsumo.dart';
import '../widgets/crear_participante_dialog.dart';
import '../widgets/editar_participante_dialog.dart';
import '../widgets/gestionar_contrato_dialog.dart';
import '../services/contrato_autoconsumo_api_service.dart';

class ParticipantesContentView extends ConsumerWidget {
  final int idComunidad;
  final String nombreComunidad;

  const ParticipantesContentView({
    super.key,
    required this.idComunidad,
    required this.nombreComunidad,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final participantesState = ref.watch(participantesProvider);

    return Column(
      children: [
        // Header con título y botón de agregar
        _buildHeader(context, ref),
        
        // Grid con participantes
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(8.w),
            child: _buildParticipantesGrid(participantesState, ref, context),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
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
                  'Participantes',
                  style: AppTextStyles.tabSectionTitle,
                ),
                SizedBox(height: 4.h),
                Text(
                  nombreComunidad,
                  style: AppTextStyles.tabDescription,
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _showCreateParticipanteDialog(context, ref),
            icon: const Icon(Icons.person_add, color: Colors.white),
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

  Widget _buildParticipantesGrid(ParticipantesState state, WidgetRef ref, BuildContext context) {
    if (state.isLoading) {
      return const GridLoadingState(
        itemCount: 8,
        crossAxisCount: 2,
      );
    }

    if (state.error != null) {
      return _buildErrorWidget(state.error!, ref);
    }

    if (state.participantes.isEmpty) {
      return _buildEmptyState(context, ref);
    }

    final participantes = state.participantes;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.0,
        crossAxisSpacing: 8.w,
        mainAxisSpacing: 8.h,
      ),
      itemCount: participantes.length,
      itemBuilder: (context, index) {
        final participante = participantes[index];
        return _buildParticipanteCard(participante, context, ref);
      },
    );
  }

  Widget _buildParticipanteCard(Participante participante, BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
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
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Avatar del participante
                CircleAvatar(
                  backgroundColor: AppColors.info,
                  radius: 24.r,
                  child: Text(
                    participante.nombre.isNotEmpty 
                        ? participante.nombre[0].toUpperCase()
                        : 'P',
                    style: AppTextStyles.cardTitle.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                
                // Nombre del participante
                Text(
                  participante.nombre,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.cardTitle.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                // Estado del contrato
                _buildContratoStatus(participante.idParticipante),
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
              onSelected: (value) => _handleMenuAction(value, participante, context, ref),
              itemBuilder: (context) => [
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
                  value: 'contrato',
                  child: Row(
                    children: [
                      const Icon(Icons.description, size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text('Gestionar contrato', style: AppTextStyles.bodyMedium),
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



  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.group_off,
            size: 64.sp,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 16.h),
          Text(
            'No hay participantes',
            style: AppTextStyles.headline3.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Agrega el primer participante a esta comunidad energética',
            style: AppTextStyles.bodySecondary,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: () => _showCreateParticipanteDialog(context, ref),
            icon: const Icon(Icons.person_add),
            label: Text('Agregar Participante', style: AppTextStyles.button.copyWith(color: Colors.white)),
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

  Widget _buildErrorWidget(String error, WidgetRef ref) {
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
            'Error al cargar participantes',
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
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: () {
              ref.read(participantesProvider.notifier).loadParticipantesByComunidad(idComunidad);
            },
            icon: const Icon(Icons.refresh),
            label: Text('Reintentar', style: AppTextStyles.button.copyWith(color: Colors.white)),
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

  void _showCreateParticipanteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => CrearParticipanteDialog(
        idComunidad: idComunidad,
        nombreComunidad: nombreComunidad,
      ),
    );
  }

  void _handleMenuAction(String action, Participante participante, BuildContext context, WidgetRef ref) {
    switch (action) {
      case 'ver':
        _navegarADetalleParticipante(context, participante);
        break;
      case 'editar':
        _navegarAEditarParticipante(context, participante);
        break;
      case 'contrato':
        _navegarAGestionarContrato(context, participante, ref);
        break;
      case 'eliminar':
        _mostrarDialogoEliminar(context, participante, ref);
        break;
    }
  }

  void _navegarADetalleParticipante(BuildContext context, Participante participante) {
    Navigator.pushNamed(
      context,
      '/participante/${participante.idParticipante}',
    );
  }

  void _navegarAEditarParticipante(BuildContext context, Participante participante) {
    showDialog(
      context: context,
      builder: (context) => EditarParticipanteDialog(
        participante: participante,
      ),
    );
  }

  void _navegarAGestionarContrato(BuildContext context, Participante participante, WidgetRef ref) async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (context) => GestionarContratoDialog(
        participante: participante,
      ),
    );
    
    // Si el diálogo retorna true (éxito), recargar los participantes
    if (resultado == true) {
      ref.read(participantesProvider.notifier).loadParticipantesByComunidad(idComunidad);
    }
  }

  void _mostrarDialogoEliminar(BuildContext context, Participante participante, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning, color: AppColors.error),
            const SizedBox(width: 8),
            Text('Eliminar participante', style: AppTextStyles.headline4),
          ],
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar a ${participante.nombre}?\n\n'
          'Esta acción no se puede deshacer.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: AppTextStyles.button),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref
                  .read(participantesProvider.notifier)
                  .deleteParticipante(participante.idParticipante);
              
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${participante.nombre} eliminado correctamente',
                      style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                    ),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text('Eliminar', style: AppTextStyles.button.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildContratoStatus(int idParticipante) {
    return FutureBuilder<ContratoAutoconsumo?>(
      future: _verificarContratoParticipante(idParticipante),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            width: 12.w,
            height: 12.h,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.textSecondary),
            ),
          );
        } else if (snapshot.hasError) {
          return Text(
            'Error',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.error,
            ),
          );
        } else {
          final tieneContrato = snapshot.data != null;
          return Text(
            tieneContrato ? 'Con contrato' : 'Sin contrato',
            style: AppTextStyles.cardSubtitle.copyWith(
              color: tieneContrato ? AppColors.success : AppColors.error,
              fontWeight: FontWeight.bold,
            ),
          );
        }
      },
    );
  }

  Future<ContratoAutoconsumo?> _verificarContratoParticipante(int idParticipante) async {
    try {
      return await ContratoAutoconsumoApiService.getContratoByParticipante(idParticipante);
    } catch (e) {
      // Si hay error (404 significa que no tiene contrato), retornamos null
      return null;
    }
  }
} 