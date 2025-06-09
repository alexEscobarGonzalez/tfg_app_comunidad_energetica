import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sidebarx/sidebarx.dart';
import 'dart:typed_data';
import 'dart:html' as html;
import '../core/widgets/loading_indicators.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../providers/navigation_provider.dart';
import '../services/comunidad_energetica_service.dart';
import 'dashboard_content.dart';
import 'comunidad_content_view.dart';
import 'participantes_content_view.dart';
import 'lista_activos_energeticos_view.dart';
import 'gestion_datos_operativos_view.dart';
import 'coeficientes_content_view.dart';
import 'simulacion_view.dart';
import '../providers/comunidad_energetica_provider.dart';
import '../providers/participante_provider.dart';
import '../providers/activo_generacion_provider.dart';
import '../providers/simulacion_provider.dart';
import '../providers/user_provider.dart';
import '../models/comunidad_energetica.dart';
import '../widgets/crear_comunidad_dialog.dart';
import '../widgets/logout_button.dart';
import 'resultados_simulacion_view.dart';

class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({super.key});

  @override
  ConsumerState<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView> {
  bool _importandoEnProgreso = false;
  String _estadoImportacion = '';

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(sidebarControllerProvider);
    final selectedIndex = ref.watch(selectedIndexProvider);
    final comunidades = ref.watch(comunidadesNotifierProvider);
    final comunidadSeleccionada = ref.watch(comunidadSeleccionadaProvider);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0), 
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFF66BB6A), // Verde suave más claro
                Color(0xFF4CAF50), // Verde intermedio
                Color(0xFF66BB6A), // Verde más oscuro pero suave
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: AppBar(
            actionsPadding: const EdgeInsets.only(top: 10.0),
            title: Text(
              'Comunidad Energética',
              style: AppTextStyles.headline1.copyWith(color: AppColors.textOnPrimary),
            ),
            elevation: 0, // Removemos la elevación para que se vea el gradiente
            shadowColor: Colors.transparent,
            toolbarHeight: 60.0,
            backgroundColor: Colors.transparent, // Hacemos el AppBar transparente para mostrar el gradiente
            foregroundColor: Colors.white,
            automaticallyImplyLeading: false,
            centerTitle: true,
            actions: [
              // Botón de recargar datos
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                tooltip: 'Recargar datos',
                onPressed: () => _loadInitialData(ref),
              ),
              const SizedBox(width: 8),
              Container(
                constraints: const BoxConstraints(minWidth: 280, maxWidth: 380),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: DropdownButtonHideUnderline(
                    child: SizedBox(
                      height: 48.0,
                      child: DropdownButton<int?>(
                        value: comunidadSeleccionada?.idComunidadEnergetica,
                        hint: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(
                            'Seleccionar Comunidad',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        icon: const Padding(
                          padding: EdgeInsets.only(right: 12.0),
                          child: Icon(Icons.arrow_drop_down, color: AppColors.textPrimary, size: 24),
                        ),
                        dropdownColor: AppColors.surface,
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                        isExpanded: true,
                        isDense: false,
                        itemHeight: null,
                        items: [
                          // Opción para crear nueva comunidad
                          DropdownMenuItem<int?>(
                            value: -1,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.add, color: AppColors.primary, size: 22),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Crear Nueva Comunidad',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Separador
                          if (comunidades.isNotEmpty)
                            const DropdownMenuItem<int?>(
                              value: null,
                              enabled: false,
                              child: Divider(color: AppColors.divider),
                            ),
                          // Lista de comunidades existentes
                          ...comunidades.map((comunidad) {
                            return DropdownMenuItem<int?>(
                              value: comunidad.idComunidadEnergetica,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                child: Row(
                                  children: [
                                    const Icon(Icons.location_city, color: AppColors.textPrimary, size: 22),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        comunidad.nombre,
                                        style: AppTextStyles.bodyMedium.copyWith(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                        onChanged: (idComunidad) {
                          if (idComunidad == -1) {
                            // Crear nueva comunidad
                            _showCreateCommunityDialog(context, ref);
                          } else if (idComunidad != null) {
                            // Seleccionar comunidad existente
                            final comunidad = comunidades.firstWhere(
                              (c) => c.idComunidadEnergetica == idComunidad,
                            );
                            ref.read(comunidadSeleccionadaProvider.notifier).seleccionarComunidad(comunidad);
                            _loadDataForSelectedCommunity(ref, idComunidad);
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              if (comunidadSeleccionada != null) ...[
                // Botón de exportar comunidad
                IconButton(
                  icon: const Icon(Icons.download, color: Colors.white, size: 24),
                  tooltip: 'Exportar Comunidad Completa',
                  onPressed: () => _showExportDialog(context, ref, comunidadSeleccionada),
                ),
                // Botón de eliminar comunidad
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white, size: 24),
                  tooltip: 'Eliminar Comunidad',
                  onPressed: () {
                    _showDeleteCommunityDialog(context, ref, comunidadSeleccionada);
                  },
                ),
              ],
                            // Botón de importar comunidad con estado visual
              Container(
                decoration: BoxDecoration(
                  color: _importandoEnProgreso ? Colors.orange : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: _importandoEnProgreso 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: LoadingSpinner(
                      color: Colors.white,
                      size: 20,
                      strokeWidth: 2,
                    ),
                      )
                    : const Icon(Icons.upload, color: Colors.white, size: 24),
                  tooltip: _importandoEnProgreso ? _estadoImportacion : 'Importar Comunidad',
                  onPressed: _importandoEnProgreso ? null : () => _iniciarImportacionSimple(),
                ),
              ),
              const SizedBox(width: 20),
            ],
          ),
        ),
      ),
      body: Container(
        color: AppColors.background,
        child: Row(
          children: [
            SidebarX(
              controller: controller,
              theme: const SidebarXTheme(
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  boxShadow: [AppColors.cardShadow],
                ),
                hoverColor: Color(0x1A2E7D32), 
                textStyle: AppTextStyles.bodyMedium,
                selectedTextStyle: TextStyle(color: Colors.white),
                itemTextPadding: EdgeInsets.only(left: 30),
                selectedItemTextPadding: EdgeInsets.only(left: 30),
                itemDecoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  border: Border.fromBorderSide(BorderSide(color: AppColors.border)),
                ),
                selectedItemDecoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: AppColors.primary,
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x472E7D32), // AppColors.primary with opacity 0.28
                      blurRadius: 30,
                    )
                  ],
                ),
                iconTheme: IconThemeData(
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                selectedIconTheme: IconThemeData(
                  color: Colors.white,
                  size: 20,
                ),
              ),
              extendedTheme: const SidebarXTheme(
                width: 280,
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  boxShadow: [AppColors.cardShadow],
                ),
              ),
              footerDivider: const Divider(color: AppColors.divider, height: 1),
              headerBuilder: (context, extended) {
                return SizedBox(
                  height: 80,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.eco,
                          color: AppColors.primary,
                          size: 32,
                        ),
                        if (extended) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Comunidad',
                                  style: AppTextStyles.cardTitle.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                                Text(
                                  comunidadSeleccionada?.nombre ?? 'Energética',
                                  style: AppTextStyles.caption,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          // Botón de cerrar sesión
                          const LogoutButton(),
                        ],
                      ],
                    ),
                  ),
                );
              },
              items: [
                SidebarXItem(
                  icon: Icons.dashboard,
                  label: 'Dashboard',
                  onTap: () => ref.read(selectedIndexProvider.notifier).state = 0,
                ),
                SidebarXItem(
                  icon: Icons.location_city,
                  label: 'Comunidad',
                  onTap: () => ref.read(selectedIndexProvider.notifier).state = 1,
                ),
                SidebarXItem(
                  icon: Icons.people,
                  label: 'Participantes',
                  onTap: () => ref.read(selectedIndexProvider.notifier).state = 2,
                ),
                SidebarXItem(
                  icon: Icons.solar_power,
                  label: 'Activos Energéticos',
                  onTap: () => ref.read(selectedIndexProvider.notifier).state = 3,
                ),
                SidebarXItem(
                  icon: Icons.storage,
                  label: 'Datos de Consumo',
                  onTap: () => ref.read(selectedIndexProvider.notifier).state = 4,
                ),
                SidebarXItem(
                  icon: Icons.percent,
                  label: 'Coeficientes',
                  onTap: () => ref.read(selectedIndexProvider.notifier).state = 5,
                ),
                SidebarXItem(
                  icon: Icons.science,
                  label: 'Simulaciones',
                  onTap: () => ref.read(selectedIndexProvider.notifier).state = 6,
                ),
                SidebarXItem(
                  icon: Icons.analytics,
                  label: 'Visualizar Resultados',
                  onTap: () => ref.read(selectedIndexProvider.notifier).state = 7,
                ),
              ],
            ),
            Expanded(
              child: _buildPageContent(selectedIndex, comunidadSeleccionada, ref),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageContent(int selectedIndex, ComunidadEnergetica? comunidadSeleccionada, WidgetRef ref) {
    switch (selectedIndex) {
      case 0:
        return const DashboardContent();
      case 1:
        return const ComunidadContentView();
      case 2:
        if (comunidadSeleccionada != null) {
          return ParticipantesContentView(
            idComunidad: comunidadSeleccionada.idComunidadEnergetica,
            nombreComunidad: comunidadSeleccionada.nombre,
          );
        }
        return _buildNoCommunitySelected();
      case 3: // Activos Energéticos
        if (comunidadSeleccionada != null) {
          return ListaActivosEnergeticosView(
            idComunidad: comunidadSeleccionada.idComunidadEnergetica,
            nombreComunidad: comunidadSeleccionada.nombre,
          );
        }
        return _buildNoCommunitySelected();
      case 4: // Datos de Consumo
        if (comunidadSeleccionada != null) {
          return const GestionDatosOperativosView();
        }
        return _buildNoCommunitySelected();
      case 5: // Coeficientes
        if (comunidadSeleccionada != null) {
          return CoeficientesContentView(
            idComunidad: comunidadSeleccionada.idComunidadEnergetica,
            nombreComunidad: comunidadSeleccionada.nombre,
          );
        }
        return _buildNoCommunitySelected();
      case 6: // Simulaciones
        return const SimulacionView();
      case 7: // Visualizar Resultados
        if (comunidadSeleccionada != null) {
          return ResultadosSimulacionView(
            idComunidad: comunidadSeleccionada.idComunidadEnergetica,
            nombreComunidad: comunidadSeleccionada.nombre,
          );
        }
        return _buildNoCommunitySelected();
      default:
        return const DashboardContent();
    }
  }

  Widget _buildNoCommunitySelected() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.info_outline,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay comunidad seleccionada',
            style: AppTextStyles.headline1.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Selecciona o crea una comunidad para acceder a esta función',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildComingSoon(String feature) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.construction,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            feature,
            style: AppTextStyles.headline1.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Esta función estará disponible próximamente',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _loadInitialData(WidgetRef ref) {
    final authState = ref.read(authProvider);
    if (authState.isLoggedIn && authState.usuario != null) {
      final usuario = authState.usuario!;
      ref.read(comunidadesNotifierProvider.notifier).loadComunidadesUsuario(usuario.idUsuario).then((_) {
        final comunidades = ref.read(comunidadesNotifierProvider);
        if (comunidades.isNotEmpty) {
          // Auto-seleccionar la primera comunidad si no hay ninguna seleccionada
          final comunidadActual = ref.read(comunidadSeleccionadaProvider);
          if (comunidadActual == null) {
            ref.read(comunidadSeleccionadaProvider.notifier).autoSeleccionarPrimera(comunidades);
          }
          
          // Cargar datos de la comunidad seleccionada o la primera
          final idComunidad = comunidadActual?.idComunidadEnergetica ?? comunidades.first.idComunidadEnergetica;
          _loadDataForSelectedCommunity(ref, idComunidad);
        }
      });
    }
  }

  void _loadDataForSelectedCommunity(WidgetRef ref, int idComunidad) {
    // Cargar datos específicos de la comunidad seleccionada
    ref.read(participantesProvider.notifier).loadParticipantesByComunidad(idComunidad);
    ref.read(activosGeneracionProvider.notifier).loadActivosGeneracionByComunidad(idComunidad);
    // Invalidar simulaciones para recargar cuando cambie la comunidad
    ref.invalidate(estadisticasSimulacionProvider(idComunidad));
  }

  void _showCreateCommunityDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const CrearComunidadDialog(),
    );
  }

  void _showEditCommunityDialog(BuildContext context, WidgetRef ref, ComunidadEnergetica comunidad) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.edit, color: AppColors.warning),
            SizedBox(width: 8),
            Text('Editar Comunidad'),
          ],
        ),
        content: Text(
          'Editar la comunidad "${comunidad.nombre}".\nSerás redirigido a la página de edición.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Cambiar a la vista de comunidades y mostrar formulario de edición
              ref.read(selectedIndexProvider.notifier).state = 1;
              // TODO: Aquí podrías pasar el ID de la comunidad para editar
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              foregroundColor: Colors.white,
            ),
            child: const Text('Editar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteCommunityDialog(BuildContext context, WidgetRef ref, ComunidadEnergetica comunidad) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: AppColors.error),
            SizedBox(width: 8),
            Text('Eliminar Comunidad'),
          ],
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar la comunidad "${comunidad.nombre}"?\n\n'
          'Esta acción no se puede deshacer y eliminará todos los datos asociados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteCommunity(ref, comunidad);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _deleteCommunity(WidgetRef ref, ComunidadEnergetica comunidad) async {
    try {
      // Eliminar la comunidad
      await ref.read(comunidadesNotifierProvider.notifier).deleteComunidad(comunidad.idComunidadEnergetica);
      
      // Limpiar la selección actual
      ref.read(comunidadSeleccionadaProvider.notifier).limpiarSeleccion();
      
      // Recargar la lista de comunidades
      final authState = ref.read(authProvider);
      if (authState.isLoggedIn && authState.usuario != null) {
        await ref.read(comunidadesNotifierProvider.notifier).loadComunidadesUsuario(authState.usuario!.idUsuario);
      }
      
      // Volver al dashboard
      ref.read(selectedIndexProvider.notifier).state = 0;
      
    } catch (e) {
      // Manejar error
      print('Error al eliminar comunidad: $e');
    }
  }

  /// Muestra el diálogo de opciones de exportación
  void _showExportDialog(BuildContext context, WidgetRef ref, ComunidadEnergetica comunidad) {
    DateTime? fechaInicio;
    DateTime? fechaFin;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  const Icon(Icons.download, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text('Exportar Comunidad Completa', style: AppTextStyles.headline4),
                ],
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 500, // Ancho fijo para el diálogo
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Comunidad: ${comunidad.nombre}',
                        style: AppTextStyles.cardTitle.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Esta función descargará toda la información de la comunidad en un archivo ZIP que incluye:',
                        style: AppTextStyles.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      Text('• Metadatos de la comunidad (JSON)', style: AppTextStyles.bodySmall),
                      Text('• Lista de participantes (JSON)', style: AppTextStyles.bodySmall),
                      Text('• Activos de generación (JSON)', style: AppTextStyles.bodySmall),
                      Text('• Activos de almacenamiento (JSON)', style: AppTextStyles.bodySmall),
                      Text('• Coeficientes de reparto (JSON)', style: AppTextStyles.bodySmall),
                      Text('• Contratos de autoconsumo (JSON)', style: AppTextStyles.bodySmall),
                      Text('• Datos de consumo por participante (CSV)', style: AppTextStyles.bodySmall),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 12),
                      Text(
                        'Filtros opcionales para datos de consumo:',
                        style: AppTextStyles.subtitle,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final fecha = await showDatePicker(
                                  context: context,
                                  initialDate: fechaInicio ?? DateTime.now().subtract(const Duration(days: 30)),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime.now(),
                                );
                                if (fecha != null) {
                                  setState(() {
                                    fechaInicio = fecha;
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Fecha inicio', style: AppTextStyles.caption),
                                    Text(
                                      fechaInicio != null
                                          ? '${fechaInicio!.day}/${fechaInicio!.month}/${fechaInicio!.year}'
                                          : 'Seleccionar',
                                      style: AppTextStyles.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final fecha = await showDatePicker(
                                  context: context,
                                  initialDate: fechaFin ?? DateTime.now(),
                                  firstDate: fechaInicio ?? DateTime(2020),
                                  lastDate: DateTime.now(),
                                );
                                if (fecha != null) {
                                  setState(() {
                                    fechaFin = fecha;
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Fecha fin', style: AppTextStyles.caption),
                                    Text(
                                      fechaFin != null
                                          ? '${fechaFin!.day}/${fechaFin!.month}/${fechaFin!.year}'
                                          : 'Seleccionar',
                                      style: AppTextStyles.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (fechaInicio != null || fechaFin != null)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    fechaInicio = null;
                                    fechaFin = null;
                                  });
                                },
                                child: const Text('Limpiar fechas'),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 12),
                      Text(
                        'Si no seleccionas fechas, se exportarán todos los datos disponibles.',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _iniciarExportacion(context, ref, comunidad, fechaInicio, fechaFin);
                  },
                  icon: const Icon(Icons.download),
                  label: const Text('Exportar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Inicia el proceso de exportación mostrando el progreso
  void _iniciarExportacion(
    BuildContext context, 
    WidgetRef ref, 
    ComunidadEnergetica comunidad,
    DateTime? fechaInicio, 
    DateTime? fechaFin
  ) async {
    // Variable para almacenar el Navigator del diálogo
    NavigatorState? dialogNavigator;
    
    // Mostrar diálogo de progreso
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        // Guardar referencia al Navigator del diálogo
        dialogNavigator = Navigator.of(dialogContext);
        
        return AlertDialog(
          title: Row(
            children: [
                              const LoadingSpinner(),
              const SizedBox(width: 16),
              Text('Exportando Comunidad', style: AppTextStyles.headline4),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Preparando exportación...', style: AppTextStyles.bodyMedium),
              const SizedBox(height: 8),
              Text('Este proceso puede tardar unos minutos', style: AppTextStyles.bodySecondary),
            ],
          ),
        );
      },
    );

    try {
      // Realizar exportación
      print('🚀 Iniciando exportación...');
      final resultado = await ComunidadEnergeticaService.exportarComunidadCompleta(
        comunidadId: comunidad.idComunidadEnergetica,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
      );

      print('🔄 Exportación completada, cerrando diálogo...');
      
      // Cerrar diálogo de progreso usando la referencia directa
      try {
        dialogNavigator?.pop();
        print('✅ Diálogo de progreso cerrado exitosamente');
      } catch (e) {
        print('⚠️ Error cerrando diálogo de progreso: $e');
        // Fallback: intentar cerrar con el contexto original
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      }

      // Pequeña pausa para asegurar que el diálogo se cierre
      await Future.delayed(const Duration(milliseconds: 100));

      // Verificar resultado y mostrar éxito
      if (resultado['success'] == true) {
        print('🎉 Mostrando diálogo de éxito...');
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (BuildContext successContext) {
              return AlertDialog(
                title: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Text('Exportación Completada', style: AppTextStyles.headline4),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('La exportación se ha completado exitosamente.', style: AppTextStyles.bodyMedium),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.file_download, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              resultado['message'] ?? 'Exportación completada',
                              style: AppTextStyles.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(successContext).pop(),
                    child: const Text('Cerrar'),
                  ),
                ],
              );
            },
          );
        }
      } else {
        throw Exception('Error en la exportación: resultado no exitoso');
      }
    } catch (error) {
      print('💥 Error en exportación: $error');
      
      // Cerrar diálogo de progreso en caso de error
      try {
        dialogNavigator?.pop();
        print('✅ Diálogo de progreso cerrado después de error');
      } catch (e) {
        print('⚠️ Error cerrando diálogo de progreso después de error: $e');
        // Fallback: intentar cerrar con el contexto original
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      }

      // Pequeña pausa
      await Future.delayed(const Duration(milliseconds: 100));

      // Mostrar error
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (BuildContext errorContext) {
            return AlertDialog(
              title: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  const SizedBox(width: 8),
                  Text('Error en la Exportación', style: AppTextStyles.headline4),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Error al exportar la comunidad:\n\n$error', style: AppTextStyles.bodyMedium),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(errorContext).pop(),
                  child: const Text('Cerrar'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  /// Muestra un diálogo de error
  void _mostrarError(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(mensaje)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Método simplificado para iniciar importación sin diálogos complejos
  void _iniciarImportacionSimple() {
    // Verificar usuario
    final authState = ref.read(authProvider);
    if (!authState.isLoggedIn || authState.usuario == null) {
      _mostrarError(context, 'No se pudo identificar al usuario');
      return;
    }
    
    final usuario = authState.usuario!;

    // Crear input de archivo HTML
    final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = '.zip';
    uploadInput.multiple = false;

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files != null && files.isNotEmpty) {
        final file = files[0];
        print('📁 Archivo seleccionado: ${file.name} (${file.size} bytes)');
        
        // Verificar que es un ZIP
        if (!file.name.toLowerCase().endsWith('.zip')) {
          _mostrarError(context, 'Solo se permiten archivos ZIP');
          return;
        }

        // Mostrar progreso inmediatamente
        setState(() {
          _importandoEnProgreso = true;
          _estadoImportacion = 'Leyendo archivo...';
        });

        // Mostrar información en SnackBar
        SnackBarLoading.show(
          context,
          'Iniciando importación de ${file.name}...',
          backgroundColor: Colors.blue,
        );
        
        // Leer el archivo
        final reader = html.FileReader();
        reader.readAsArrayBuffer(file);
        
        reader.onLoadEnd.listen((e) {
          final Uint8List bytes = reader.result as Uint8List;
          _procesarImportacion(bytes, file.name, usuario.idUsuario);
        });
        
        reader.onError.listen((e) {
          setState(() {
            _importandoEnProgreso = false;
            _estadoImportacion = '';
          });
          _mostrarError(context, 'Error al leer el archivo seleccionado');
        });
      }
    });

    // Activar selector de archivos
    uploadInput.click();
  }

  /// Procesa la importación de manera simple
  void _procesarImportacion(Uint8List archivoBytes, String nombreArchivo, int idUsuario) async {
    try {
      setState(() {
        _estadoImportacion = 'Procesando archivo...';
      });

      // Actualizar SnackBar
      SnackBarLoading.show(
        context,
        'Importando datos al servidor...',
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 5),
      );

      print('🚀 Iniciando importación...');
      final resultado = await ComunidadEnergeticaService.importarComunidadCompleta(
        archivoZip: archivoBytes,
        nombreArchivo: nombreArchivo,
        idUsuario: idUsuario,
      );

      print('🔄 Importación completada');

      // Limpiar estado de progreso
      setState(() {
        _importandoEnProgreso = false;
        _estadoImportacion = '';
      });

      // Verificar resultado
      if (resultado['success'] == true) {
        final estadisticas = resultado['estadisticas'] as Map<String, dynamic>? ?? {};
        final nombreComunidad = estadisticas['comunidad_nombre'] ?? 'Sin nombre';
        final participantes = estadisticas['participantes_creados'] ?? 0;
        final registros = estadisticas['registros_consumo_creados'] ?? 0;

        // Mostrar éxito con SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 8),
                    const Text('¡Importación Exitosa!', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Comunidad: $nombreComunidad'),
                Text('$participantes participantes, $registros registros de datos'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Ver',
              textColor: Colors.white,
              onPressed: () {
                _loadInitialData(ref);
              },
            ),
          ),
        );

        // Recargar datos automáticamente
        print('🔄 Recargando datos después de importación exitosa...');
        _loadInitialData(ref);
      } else {
        throw Exception('Error en la importación: resultado no exitoso');
      }
    } catch (error) {
      print('💥 Error en importación: $error');
      
      setState(() {
        _importandoEnProgreso = false;
        _estadoImportacion = '';
      });

      // Mostrar error con SnackBar
      _mostrarError(context, 'Error al importar: $error');
    }
  }
} 