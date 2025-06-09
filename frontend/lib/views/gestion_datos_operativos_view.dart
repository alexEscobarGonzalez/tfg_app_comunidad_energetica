import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/widgets/loading_indicators.dart';
import '../models/registro_consumo.dart';

import '../models/participante.dart';
import '../providers/datos_consumo_provider.dart';
import '../providers/participante_provider.dart';
import '../providers/comunidad_energetica_provider.dart';
import '../components/carga_datos_widget.dart';

class GestionDatosOperativosView extends ConsumerStatefulWidget {
  final int? idParticipanteInicial;

  const GestionDatosOperativosView({
    super.key,
    this.idParticipanteInicial,
  });

  @override
  ConsumerState<GestionDatosOperativosView> createState() => _GestionDatosOperativosViewState();
}

class _GestionDatosOperativosViewState extends ConsumerState<GestionDatosOperativosView> {
  int? _participanteSeleccionado;
  DateTime? _fechaInicioTabla;
  DateTime? _fechaFinTabla;
  final _dataGridController = DataGridController();

  @override
  void initState() {
    super.initState();
    _fechaInicioTabla = DateTime.now().subtract(const Duration(days: 30));
    _fechaFinTabla = DateTime.now();
    
    // Establecer participante inicial si se proporciona
    if (widget.idParticipanteInicial != null) {
      _participanteSeleccionado = widget.idParticipanteInicial;
    }
    
    // Cargar participantes al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarParticipantesComunidad();
      
      // Si hay un participante seleccionado, cargar sus datos
      if (_participanteSeleccionado != null) {
        _cargarDatosParticipante(_participanteSeleccionado!);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final participantesState = ref.watch(participantesProvider);
    final datosState = ref.watch(datosConsumoProvider);
    final comunidadSeleccionada = ref.watch(comunidadSeleccionadaProvider);

    // Escuchar cambios en la comunidad seleccionada
    ref.listen<dynamic>(comunidadSeleccionadaProvider, (previous, next) {
      if (previous != next && next != null) {
        // Reset participante seleccionado cuando cambie la comunidad
        setState(() {
          _participanteSeleccionado = null;
        });
        _cargarParticipantesComunidad();
      }
    });

    return Column(
      children: [
        // Header con título y acciones
        _buildHeader(context),
        
        // Contenido principal
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Panel de selección de participante
                _buildPanelParticipante(participantesState.participantes),
                
                // Panel de acciones principales
                if (_participanteSeleccionado != null) _buildPanelAcciones(),
                
                // Panel de filtros para la tabla
                if (_participanteSeleccionado != null) _buildPanelFiltros(),

                // Tabla de datos de consumo con altura suficiente
                if (_participanteSeleccionado != null)
                  Container(
                    height: MediaQuery.of(context).size.height * 0.75, // Aumentado a 75% para mayor altura
                    constraints: const BoxConstraints(
                      minHeight: 500, // Altura mínima aumentada
                      maxHeight: 900, // Altura máxima aumentada
                    ),
                    child: _buildContenidoTabla(datosState),
                  )
                else
                  SizedBox(
                    height: 400,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_search, size: 64.sp, color: AppColors.textSecondary),
                          SizedBox(height: 16.h),
                          Text(
                            'Selecciona un participante para ver sus datos de consumo',
                            style: AppTextStyles.bodySecondary,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                
                // Espacio adicional al final para mejor UX
                SizedBox(height: 50.h),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
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
                  widget.idParticipanteInicial != null 
                      ? 'Datos de Consumo'
                      : 'Gestión de Datos de Consumo',
                  style: AppTextStyles.tabSectionTitle,
                ),
                SizedBox(height: 4.h),
                Text(
                  widget.idParticipanteInicial != null
                      ? 'Participante ${widget.idParticipanteInicial}'
                      : comunidadSeleccionada?.nombre ?? 'Sin comunidad seleccionada',
                  style: AppTextStyles.tabDescription,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPanelParticipante(List<Participante> participantes) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Selector de participante
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<int>(
                  value: _participanteSeleccionado,
                  style: AppTextStyles.bodyMedium,
                  decoration: InputDecoration(
                    labelText: 'Participante',
                    labelStyle: AppTextStyles.bodyMedium,
                    prefixIcon: const Icon(Icons.person),
                    border: const OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  ),
                  items: participantes.map((participante) {
                    return DropdownMenuItem<int>(
                      value: participante.idParticipante,
                      child: Text(participante.nombre, style: AppTextStyles.bodyMedium),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _participanteSeleccionado = value;
                    });
                    if (value != null) {
                      _cargarDatosParticipante(value);
                    }
                  },
                ),
              ),
              SizedBox(width: 16.w),
              
              // Información del participante seleccionado
              ],
          ),

          // Indicadores rápidos
          if (_participanteSeleccionado != null) ...[
            SizedBox(height: 16.h),
            _buildIndicadoresRapidos(),
          ],
        ],
      ),
    );
  }

  Widget _buildIndicadoresRapidos() {
    final estadisticas = ref.watch(estadisticasRapidasProvider);
    final datosState = ref.watch(datosConsumoProvider);
    
    // Calcular período completo del dataset
    String periodoCompleto = 'Sin datos';
    if (datosState.datos.isNotEmpty) {
      final fechas = datosState.datos.map((d) => d.timestamp).toList();
      fechas.sort();
      final fechaMin = fechas.first;
      final fechaMax = fechas.last;
      periodoCompleto = '${DateFormat('dd/MM/yyyy').format(fechaMin)} - ${DateFormat('dd/MM/yyyy').format(fechaMax)}';
    }
    
    return Column(
      children: [
        // Primera fila de indicadores
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildIndicador(
              'Total Registros',
              estadisticas['total']?.toStringAsFixed(0) ?? '0',
              Icons.data_usage,
              AppColors.info,
            ),
            _buildIndicador(
              'Promedio',
              '${estadisticas['promedio']?.toStringAsFixed(2) ?? '0'} kWh',
              Icons.trending_up,
              AppColors.success,
            ),
            _buildIndicador(
              'Máximo',
              '${estadisticas['maximo']?.toStringAsFixed(2) ?? '0'} kWh',
              Icons.keyboard_arrow_up,
              AppColors.warning,
            ),
            _buildIndicador(
              'Mínimo',
              '${estadisticas['minimo']?.toStringAsFixed(2) ?? '0'} kWh',
              Icons.keyboard_arrow_down,
              AppColors.secondary,
            ),
          ],
        ),
        
        SizedBox(height: 12.h),
        
        // Segunda fila - Período completo
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.date_range, color: AppColors.info, size: 8.sp),
              SizedBox(width: 8.w),
              Text(
                'Período Completo: ',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.info,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                periodoCompleto,
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.info,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIndicador(String titulo, String valor, IconData icono, Color color) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, color: color, size: 8.sp),
          SizedBox(height: 4.h),
          Text(
            titulo,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            valor,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPanelAcciones() {
    return Container(
      padding: EdgeInsets.all(8.w),
      
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Botón cargar datos
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _mostrarDialogoCargaDatos(),
                  icon: const Icon(Icons.upload),
                  label: Text('Cargar Datos', style: AppTextStyles.button.copyWith(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              
              // Botón eliminar datos
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _confirmarEliminarDatos(),
                  icon: const Icon(Icons.delete),
                  label: Text('Eliminar Todos', style: AppTextStyles.button.copyWith(color: AppColors.error)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(color: AppColors.error),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Método para mostrar el diálogo de carga de datos
  void _mostrarDialogoCargaDatos() {
    if (_participanteSeleccionado == null) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: EdgeInsets.all(12.w),
          child: Column(
            children: [
              // Header del diálogo
              Row(
                children: [
                  Text(
                    'Cargar Datos de Consumo',
                    style: AppTextStyles.headline3.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              Divider(height: 24.h),
              
              // Contenido del diálogo
              Expanded(
                child: CargaDatosWidget(
                  key: ValueKey('dialog_carga_datos_${_participanteSeleccionado!}'),
                  idParticipante: _participanteSeleccionado!,
                  onDatosCargados: () {
                    Navigator.of(context).pop();
                    _cargarDatosParticipante(_participanteSeleccionado!);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Datos cargados exitosamente',
                          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                        ),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Método para confirmar eliminación de datos
  void _confirmarEliminarDatos() {
    if (_participanteSeleccionado == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: AppColors.error),
            SizedBox(width: 8.w),
            Text('Confirmar Eliminación', style: AppTextStyles.headline4),
          ],
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar TODOS los datos de consumo de este participante?\n\nEsta acción no se puede deshacer.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar', style: AppTextStyles.button),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _eliminarTodosLosDatos();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text('Eliminar Todo', style: AppTextStyles.button.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Método para eliminar todos los datos del participante
  Future<void> _eliminarTodosLosDatos() async {
    if (_participanteSeleccionado == null) return;

    try {
      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const LoadingSpinner(),
                  SizedBox(height: 16.h),
                  Text('Eliminando datos...', style: AppTextStyles.bodyMedium),
                ],
              ),
            ),
          ),
        ),
      );

      // Eliminar datos usando el provider
      await ref.read(datosConsumoProvider.notifier).eliminarTodosRegistrosParticipante(_participanteSeleccionado!);

      // Cerrar indicador de carga
      if (context.mounted) {
        Navigator.of(context).pop();

        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Todos los datos han sido eliminados exitosamente',
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
            ),
            backgroundColor: AppColors.success,
          ),
        );

        // Recargar datos
        _cargarDatosParticipante(_participanteSeleccionado!);
      }
    } catch (e) {
      // Cerrar indicador de carga
      if (context.mounted) {
        Navigator.of(context).pop();

        // Mostrar mensaje de error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al eliminar datos: ${e.toString()}',
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Widget _buildPanelFiltros() {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtros de Tabla',
            style: AppTextStyles.cardTitle.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              // Fecha inicio
              Expanded(
                child: TextFormField(
                  style: AppTextStyles.bodyMedium,
                  decoration: InputDecoration(
                    labelText: 'Fecha Inicio',
                    labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: const OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  ),
                  readOnly: true,
                  controller: TextEditingController(
                    text: _fechaInicioTabla != null 
                        ? DateFormat('dd/MM/yyyy').format(_fechaInicioTabla!)
                        : '',
                  ),
                  onTap: () => _seleccionarFechaTabla(true),
                ),
              ),
              SizedBox(width: 16.w),

              // Fecha fin
              Expanded(
                child: TextFormField(
                  style: AppTextStyles.bodyMedium,
                  decoration: InputDecoration(
                    labelText: 'Fecha Fin',
                    labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: const OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  ),
                  readOnly: true,
                  controller: TextEditingController(
                    text: _fechaFinTabla != null 
                        ? DateFormat('dd/MM/yyyy').format(_fechaFinTabla!)
                        : '',
                  ),
                  onTap: () => _seleccionarFechaTabla(false),
                ),
              ),
              SizedBox(width: 16.w),

              // Botón aplicar filtros
              ElevatedButton.icon(
                onPressed: _participanteSeleccionado != null ? _aplicarFiltrosTabla : null,
                icon: const Icon(Icons.filter_list),
                label: Text('Filtrar', style: AppTextStyles.button.copyWith(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
              SizedBox(width: 8.w),

              // Botón limpiar filtros
              OutlinedButton.icon(
                onPressed: _limpiarFiltrosTabla,
                icon: const Icon(Icons.clear),
                label: Text('Limpiar', style: AppTextStyles.button),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContenidoTabla(DatosConsumoState datosState) {
    if (datosState.isLoading) {
      return const Center(child: LoadingSpinner());
    }

    // Aplicar filtros de fecha a los datos para la tabla
    List<RegistroConsumo> datosFiltrados = datosState.datos;
    
    if (_fechaInicioTabla != null || _fechaFinTabla != null) {
      datosFiltrados = datosState.datos.where((dato) {
        bool cumpleFechaInicio = _fechaInicioTabla == null || 
            dato.timestamp.isAfter(_fechaInicioTabla!.subtract(const Duration(days: 1)));
        bool cumpleFechaFin = _fechaFinTabla == null || 
            dato.timestamp.isBefore(_fechaFinTabla!.add(const Duration(days: 1)));
        return cumpleFechaInicio && cumpleFechaFin;
      }).toList();
    }

    if (datosFiltrados.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64.sp, color: AppColors.textSecondary),
            SizedBox(height: 16.h),
            Text(
              'No hay datos de consumo en el rango seleccionado',
              style: AppTextStyles.bodySecondary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.all(12.w),
      child: Card(
        child: Column(
          children: [
            // Header de la tabla
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.r),
                  topRight: Radius.circular(12.r),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.table_view,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Datos de Consumo',
                    style: AppTextStyles.cardTitle.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${datosFiltrados.length} registros mostrados (${datosState.datos.length} total)',
                    style: AppTextStyles.bodySecondary,
                  ),
                ],
              ),
            ),

            // Tabla de datos con altura específica
            Expanded(
              child: SfDataGrid(
                source: _DatosConsumoDataSource(datosFiltrados),
                controller: _dataGridController,
                allowSorting: true,
                allowFiltering: true,
                columnWidthMode: ColumnWidthMode.fill,
                gridLinesVisibility: GridLinesVisibility.both,
                headerGridLinesVisibility: GridLinesVisibility.both,
                columns: [
                  GridColumn(
                    columnName: 'fechaHora',
                    label: Container(
                      padding: EdgeInsets.all(2.w),
                      alignment: Alignment.center,
                      child: Text('Fecha y Hora', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  GridColumn(
                    columnName: 'consumo',
                    label: Container(
                      padding: EdgeInsets.all(2.w),
                      alignment: Alignment.center,
                      child: Text('Consumo (kWh)', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),

            // Footer de la tabla (igual al header pero sin texto)
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12.r),
                  bottomRight: Radius.circular(12.r),
                ),
              ),
              child: Row(
                children: [
                  SizedBox(),
                ],
              ), // Altura vacía para mantener proporción
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _seleccionarFechaTabla(bool esInicio) async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: esInicio ? _fechaInicioTabla ?? DateTime.now() : _fechaFinTabla ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (fecha != null) {
      setState(() {
        if (esInicio) {
          _fechaInicioTabla = fecha;
        } else {
          _fechaFinTabla = fecha;
        }
      });
    }
  }

  void _aplicarFiltrosTabla() {
    // Los filtros se aplican automáticamente en _buildContenidoTabla()
    // Solo necesitamos hacer un setState para refrescar la UI
    setState(() {});
    
    // También actualizar las estadísticas con el rango de fechas de la tabla
    if (_participanteSeleccionado != null && _fechaInicioTabla != null && _fechaFinTabla != null) {
      ref.read(datosConsumoProvider.notifier).calcularEstadisticas(
        _participanteSeleccionado!,
        _fechaInicioTabla!,
        _fechaFinTabla!,
      );
    }
  }

  void _limpiarFiltrosTabla() {
    setState(() {
      _fechaInicioTabla = null;
      _fechaFinTabla = null;
    });
    
    // Recalcular estadísticas sin filtros
    if (_participanteSeleccionado != null) {
      _cargarDatosParticipante(_participanteSeleccionado!);
    }
  }

  void _cargarDatosParticipante(int idParticipante) {
    // Cargar TODOS los datos del participante
    ref.read(datosConsumoProvider.notifier).cargarDatos(
      idParticipante,
      // Sin filtros para cargar todos los datos
      fechaInicio: null,
      fechaFin: null,
    );
  }

  void _cargarParticipantesComunidad() {
    final comunidadSeleccionada = ref.read(comunidadSeleccionadaProvider);
    
    if (comunidadSeleccionada != null) {
      ref.read(participantesProvider.notifier).loadParticipantesByComunidad(
        comunidadSeleccionada.idComunidadEnergetica
      );
    } else {
      // Si no hay comunidad seleccionada, intentar obtener la primera del usuario
      final comunidades = ref.read(comunidadesNotifierProvider);
      if (comunidades.isNotEmpty) {
        ref.read(comunidadSeleccionadaProvider.notifier).autoSeleccionarPrimera(comunidades);
        ref.read(participantesProvider.notifier).loadParticipantesByComunidad(
          comunidades.first.idComunidadEnergetica
        );
      }
    }
  }

}

// DataSource para la tabla de datos
class _DatosConsumoDataSource extends DataGridSource {
  final List<RegistroConsumo> datos;

  _DatosConsumoDataSource(this.datos) {
    _buildDataGridRows();
  }

  List<DataGridRow> _dataGridRows = [];

  void _buildDataGridRows() {
    _dataGridRows = datos.map<DataGridRow>((dato) {
      return DataGridRow(cells: [
        DataGridCell<String>(
          columnName: 'fechaHora',
          value: DateFormat('dd/MM/yyyy HH:00').format(dato.timestamp),
        ),
        DataGridCell<double>(
          columnName: 'consumo',
          value: dato.consumoEnergia,
        ),
      ]);
    }).toList();
  }

  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((cell) {
        if (cell.columnName == 'consumo') {
          return Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.all(2.w),
            child: Text(
              '${cell.value.toStringAsFixed(2)} kWh',
              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
            ),
          );
        } else if (cell.columnName == 'fechaHora') {
          return Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.all(2.w),
            child: Text(
              cell.value.toString(),
              style: AppTextStyles.bodyMedium,
            ),
          );
        }else {
          return Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.all(2.w),
            child: Text(cell.value.toString(), style: AppTextStyles.bodyMedium),
          );
        }
      }).toList(),
    );
  }
} 