import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart'; // Para kDebugMode
import 'package:flutter/services.dart'; // Para TextInputFormatter y TextEditingResult
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/widgets/custom_card.dart';
import '../core/widgets/custom_button.dart';
import '../core/widgets/loading_indicators.dart';
import '../models/registro_consumo.dart';
import '../models/estadisticas_consumo.dart';
import '../services/datos_consumo_api_service.dart';
import '../providers/datos_consumo_provider.dart';


class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    
    final numericText = text.replaceAll(RegExp(r'[^0-9]'), '');
    

    final limitedText = numericText.length > 8 ? numericText.substring(0, 8) : numericText;
    

    String formattedText = '';
    for (int i = 0; i < limitedText.length; i++) {
      if (i == 2 || i == 4) {
        formattedText += '/';
      }
      formattedText += limitedText[i];
    }
    
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

// Formatter para fecha y hora con formato dd/mm/yyyy hh:mm
class DateTimeInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    
    // Remover caracteres no numéricos
    final numericText = text.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Limitar a 12 dígitos (ddmmyyyyhhmm)
    final limitedText = numericText.length > 12 ? numericText.substring(0, 12) : numericText;
    
    // Formatear con "/" y ":"
    String formattedText = '';
    for (int i = 0; i < limitedText.length; i++) {
      if (i == 2 || i == 4) {
        formattedText += '/';
      } else if (i == 8) {
        formattedText += ' ';
      } else if (i == 10) {
        formattedText += ':';
      }
      formattedText += limitedText[i];
    }
    
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

class CargaDatosWidget extends ConsumerStatefulWidget {
  final int idParticipante;
  final VoidCallback? onDatosCargados;

  const CargaDatosWidget({
    super.key,
    required this.idParticipante,
    this.onDatosCargados,
  });

  @override
  ConsumerState<CargaDatosWidget> createState() => _CargaDatosWidgetState();
}

class _CargaDatosWidgetState extends ConsumerState<CargaDatosWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Controladores para carga manual
  final _consumoController = TextEditingController();
  final _fechaController = TextEditingController();
  final _horaController = TextEditingController();
  
  // Estado
  bool _isLoading = false;
  String? _error;
  DateTime? _fechaSeleccionada;
  TimeOfDay? _horaSeleccionada;
  bool _isInitialized = false;
  
  // Variables para carga por lotes
  final List<Map<String, dynamic>> _datosTemporales = [];
  final _rangoFechaInicioController = TextEditingController();
  final _rangoFechaFinController = TextEditingController();
  final _consumoBaseController = TextEditingController();
  final _variacionController = TextEditingController();
  
  DateTime? _rangoFechaInicio;
  DateTime? _rangoFechaFin;

  // Variables para carga CSV
  String? _nombreArchivoCSV;
  ResultadoCargaDatos? _resultadoCargaCSV;
  FilePickerResult? _archivoSeleccionado;

  // Variables para eliminación de datos
  bool _eliminandoDatos = false;

  // Variables para predicción IA
  final _prediccionFechaInicioController = TextEditingController();
  final _prediccionFechaFinController = TextEditingController();
  final _prediccionIntervalosController = TextEditingController();
  final _tipoViviendaController = TextEditingController();
  final _numPersonasController = TextEditingController();
  final _temperaturaController = TextEditingController();
  final _lagMes1Controller = TextEditingController();
  final _lagMes2Controller = TextEditingController();
  final _lagMes3Controller = TextEditingController();
  
  DateTime? _prediccionFechaInicio;
  DateTime? _prediccionFechaFin;
  int _tipoViviendaSeleccionada = 2; // Apartamento por defecto
  Map<String, dynamic>? _resultadoPrediccion;
  bool _generandoConIA = false;
  Map<String, dynamic>? _estadoModelo;
  bool _verificandoModelo = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fechaSeleccionada = DateTime.now();
    _horaSeleccionada = TimeOfDay.now();
    _inicializarValoresPrediccion();
    _verificarEstadoModelo();
  }

  void _inicializarValoresPrediccion() {
    // Valores por defecto para predicción IA
    _tipoViviendaSeleccionada = 2; // Apartamento
    // Intervalo fijo de 1 hora - ya no es configurable
    _numPersonasController.text = '3'; // 3 personas
    // Temperatura fija de 20°C - ya no es configurable
    _lagMes1Controller.text = '0.45'; // Valores típicos de consumo
    _lagMes2Controller.text = '0.48';
    _lagMes3Controller.text = '0.52';
    
    // Fechas por defecto: próximas 24 horas
    final ahora = DateTime.now();
    _prediccionFechaInicio = DateTime(ahora.year, ahora.month, ahora.day, ahora.hour);
    _prediccionFechaFin = _prediccionFechaInicio!.add(const Duration(hours: 23));
    
    _prediccionFechaInicioController.text = DateFormat('dd/MM/yyyy HH:mm').format(_prediccionFechaInicio!);
    _prediccionFechaFinController.text = DateFormat('dd/MM/yyyy HH:mm').format(_prediccionFechaFin!);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _consumoController.dispose();
    _fechaController.dispose();
    _horaController.dispose();
    _rangoFechaInicioController.dispose();
    _rangoFechaFinController.dispose();
    _consumoBaseController.dispose();
    _variacionController.dispose();
    // Controladores de predicción simplificados
    _prediccionFechaInicioController.dispose();
    _prediccionFechaFinController.dispose();
    _numPersonasController.dispose();
    _lagMes1Controller.dispose();
    _lagMes2Controller.dispose();
    _lagMes3Controller.dispose();
    super.dispose();
  }

  void _actualizarControladores() {
    if (!mounted) return;
    
    if (_fechaSeleccionada != null) {
      _fechaController.text = DateFormat('dd/MM/yyyy').format(_fechaSeleccionada!);
    }
    if (_horaSeleccionada != null) {
      _horaController.text = _horaSeleccionada!.format(context);
    }
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (fecha != null) {
      setState(() {
        _fechaSeleccionada = fecha;
        _actualizarControladores();
      });
    }
  }

  Future<void> _seleccionarHora() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: _horaSeleccionada ?? TimeOfDay.now(),
    );

    if (hora != null) {
      setState(() {
        _horaSeleccionada = hora;
        _actualizarControladores();
      });
    }
  }

  Future<void> _guardarRegistroManual() async {
    // Validar fecha
    if (_fechaController.text.isEmpty || _fechaController.text.length != 10) {
      setState(() {
        _error = 'Ingrese una fecha válida en formato dd/mm/yyyy';
      });
      return;
    }

    // Parsear fecha manualmente
    final fechaParts = _fechaController.text.split('/');
    if (fechaParts.length != 3) {
      setState(() {
        _error = 'Formato de fecha inválido. Use dd/mm/yyyy';
      });
      return;
    }

    final dia = int.tryParse(fechaParts[0]);
    final mes = int.tryParse(fechaParts[1]);
    final anio = int.tryParse(fechaParts[2]);

    if (dia == null || mes == null || anio == null || 
        dia < 1 || dia > 31 || mes < 1 || mes > 12 || anio < 2020) {
      setState(() {
        _error = 'Fecha inválida. Verifique día (1-31), mes (1-12) y año (>=2020)';
      });
      return;
    }

    // Crear fecha
    DateTime fechaSeleccionada;
    try {
      fechaSeleccionada = DateTime(anio, mes, dia);
    } catch (e) {
      setState(() {
        _error = 'Fecha inválida. Verifique que la fecha exista';
      });
      return;
    }

    if (_horaSeleccionada == null) {
      setState(() {
        _error = 'Debe seleccionar una hora';
      });
      return;
    }

    if (_consumoController.text.isEmpty) {
      setState(() {
        _error = 'Debe ingresar un valor de consumo';
      });
      return;
    }

    final consumo = double.tryParse(_consumoController.text);
    if (consumo == null || consumo < 0) {
      setState(() {
        _error = 'Valor de consumo inválido';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final timestamp = DateTime(
        fechaSeleccionada.year,
        fechaSeleccionada.month,
        fechaSeleccionada.day,
        _horaSeleccionada!.hour,
        _horaSeleccionada!.minute,
      );

      final nuevoRegistro = RegistroConsumo(
        idRegistroConsumo: 0, // Será asignado por el backend
        idParticipante: widget.idParticipante,
        timestamp: timestamp,
        consumoEnergia: consumo,
      );
      await DatosConsumoApiService().crearRegistroConsumo(nuevoRegistro);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  'Registro guardado exitosamente',
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        );
        
        _consumoController.clear();
        _fechaController.clear();
        setState(() {
          _horaSeleccionada = null;
          _fechaSeleccionada = null;
        });
        widget.onDatosCargados?.call();
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _seleccionarRangoFecha(bool esInicio) async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: esInicio 
          ? (_rangoFechaInicio ?? DateTime.now().subtract(const Duration(days: 30)))
          : (_rangoFechaFin ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (fecha != null) {
      setState(() {
        if (esInicio) {
          _rangoFechaInicio = fecha;
          _rangoFechaInicioController.text = DateFormat('dd/MM/yyyy').format(fecha);
        } else {
          _rangoFechaFin = fecha;
          _rangoFechaFinController.text = DateFormat('dd/MM/yyyy').format(fecha);
        }
      });
    }
  }

  void _generarDatosTemporales() {
    // Validar fechas
    if (_rangoFechaInicioController.text.isEmpty || _rangoFechaFinController.text.isEmpty) {
      setState(() {
        _error = 'Debe ingresar ambas fechas';
      });
      return;
    }

    // Parsear fecha inicio
    final fechaInicioParts = _rangoFechaInicioController.text.split('/');
    if (fechaInicioParts.length != 3) {
      setState(() {
        _error = 'Formato de fecha inicio inválido. Use dd/mm/yyyy';
      });
      return;
    }

    final diaInicio = int.tryParse(fechaInicioParts[0]);
    final mesInicio = int.tryParse(fechaInicioParts[1]);
    final anioInicio = int.tryParse(fechaInicioParts[2]);

    if (diaInicio == null || mesInicio == null || anioInicio == null ||
        diaInicio < 1 || diaInicio > 31 || mesInicio < 1 || mesInicio > 12 || anioInicio < 2020) {
      setState(() {
        _error = 'Fecha inicio inválida';
      });
      return;
    }

    // Parsear fecha fin
    final fechaFinParts = _rangoFechaFinController.text.split('/');
    if (fechaFinParts.length != 3) {
      setState(() {
        _error = 'Formato de fecha fin inválido. Use dd/mm/yyyy';
      });
      return;
    }

    final diaFin = int.tryParse(fechaFinParts[0]);
    final mesFin = int.tryParse(fechaFinParts[1]);
    final anioFin = int.tryParse(fechaFinParts[2]);

    if (diaFin == null || mesFin == null || anioFin == null ||
        diaFin < 1 || diaFin > 31 || mesFin < 1 || mesFin > 12 || anioFin < 2020) {
      setState(() {
        _error = 'Fecha fin inválida';
      });
      return;
    }

    // Crear fechas
    DateTime fechaInicio;
    DateTime fechaFin;
    try {
      fechaInicio = DateTime(anioInicio, mesInicio, diaInicio);
      fechaFin = DateTime(anioFin, mesFin, diaFin);
    } catch (e) {
      setState(() {
        _error = 'Error al crear las fechas. Verifique que las fechas existan';
      });
      return;
    }

    if (fechaInicio.isAfter(fechaFin)) {
      setState(() {
        _error = 'La fecha de inicio debe ser anterior o igual a la fecha de fin';
      });
      return;
    }

    const intervalos = 24; // Siempre 24 intervalos (1 por hora)
    final consumoBase = double.tryParse(_consumoBaseController.text) ?? 1.0;
    final variacion = double.tryParse(_variacionController.text) ?? 0.2;

    _datosTemporales.clear();
    
    final diferenciaDias = fechaFin.difference(fechaInicio).inDays + 1;
    const horasInterval = 1; // 1 hora por intervalo

    for (int dia = 0; dia < diferenciaDias; dia++) {
      final fecha = fechaInicio.add(Duration(days: dia));
      
      for (int intervalo = 0; intervalo < intervalos; intervalo++) {
        final hora = intervalo * horasInterval;
        final timestamp = DateTime(fecha.year, fecha.month, fecha.day, hora);
        
        // Generar variación aleatoria más realista
        final factor = 0.8 + (0.4 * (timestamp.hour / 24)); // Más consumo durante el día
        final variacionAleatoria = (consumoBase * variacion * (2 * (timestamp.millisecond / 1000) - 1));
        final consumo = (consumoBase * factor + variacionAleatoria).abs();
        
        _datosTemporales.add({
          'timestamp': timestamp,
          'consumo': double.parse(consumo.toStringAsFixed(3)),
        });
      }
    }

    setState(() {
      _error = null;
    });
  }

  Future<void> _cargarDatosGenerados() async {
    // Redirigir a la nueva implementación con CSV
    await _cargarDatosGeneradosComoCSV();
  }

  // Métodos para carga CSV
  Future<void> _seleccionarArchivoCSV() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: false,
        withData: true, // Importante para web - asegura que los bytes estén disponibles
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (kDebugMode) {
          print('DEBUG: Archivo seleccionado: ${file.name}');
          print('DEBUG: Tiene bytes: ${file.bytes != null}');
          print('DEBUG: Tamaño bytes: ${file.bytes?.length ?? 0}');
          // NO acceder a file.path en web - causará error
        }
        
        setState(() {
          _archivoSeleccionado = result;
          _nombreArchivoCSV = file.name;
          _resultadoCargaCSV = null;
          _error = null;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('DEBUG ERROR: Error al seleccionar archivo: $e');
      }
      setState(() {
        _error = 'Error al seleccionar archivo: $e';
      });
    }
  }

  Future<void> _cargarArchivoCSV() async {
    if (_archivoSeleccionado == null || _archivoSeleccionado!.files.isEmpty) {
      setState(() {
        _error = 'Debe seleccionar un archivo CSV primero';
      });
      return;
    }

    final file = _archivoSeleccionado!.files.first;
    if (kDebugMode) {
      print('DEBUG: Iniciando carga de archivo: ${file.name}');
    }

    await _mostrarDialogoCarga(
      titulo: 'Cargando Archivo CSV',
      mensaje: 'Procesando archivo ${file.name} y enviando datos a la base de datos...',
      operacion: () async {
        ResultadoCargaDatos? resultado;
        
        try {
          // Para web, usar solo bytes
          if (file.bytes != null && file.bytes!.isNotEmpty) {
            if (kDebugMode) {
              print('DEBUG: Usando bytes (${file.bytes!.length} bytes)');
            }
            resultado = await ref.read(datosConsumoProvider.notifier)
                .cargarDatosCSVBytes(file.bytes!, widget.idParticipante);
          } else {
            throw Exception('El archivo seleccionado no tiene datos accesibles. Intente seleccionar el archivo nuevamente.');
          }

          if (resultado != null && mounted) {
            if (kDebugMode) {
              print('DEBUG: Resultado obtenido - Válidos: ${resultado.registrosValidos}, Inválidos: ${resultado.registrosInvalidos}');
            }
            
            setState(() {
              _resultadoCargaCSV = resultado;
            });
            
            widget.onDatosCargados?.call();
          } else {
            throw Exception('No se obtuvo respuesta del servidor');
          }
        } catch (e) {
          if (kDebugMode) {
            print('DEBUG ERROR: Error durante la carga: $e');
          }
          rethrow; // Re-throw para que sea manejado por _mostrarDialogoCarga
        }
      },
    );
  }

  void _limpiarSeleccionCSV() {
    setState(() {
      _archivoSeleccionado = null;
      _nombreArchivoCSV = null;
      _resultadoCargaCSV = null;
      _error = null;
    });
  }

  // Método para eliminar todos los datos de consumo del participante
  Future<void> _eliminarTodosLosDatos() async {
    // Mostrar diálogo de confirmación
    final confirmacion = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red, size: 24.sp),
            SizedBox(width: 8.w),
            Text('Confirmar eliminación'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Está seguro de que desea eliminar TODOS los datos de consumo de este participante?',
              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.red, size: 16.sp),
                      SizedBox(width: 6.w),
                      Text(
                        'Esta acción es irreversible',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '• Se eliminarán todos los registros de consumo\n'
                    '• No se podrán recuperar los datos\n'
                    '• Afectará a todas las estadísticas y análisis',
                    style: AppTextStyles.caption.copyWith(color: Colors.red),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Eliminar Todo'),
          ),
        ],
      ),
    );

    if (confirmacion != true) return;

    setState(() {
      _eliminandoDatos = true;
      _error = null;
    });

    try {
      final exitoso = await ref.read(datosConsumoProvider.notifier)
          .eliminarTodosRegistrosParticipante(widget.idParticipante);

      if (exitoso && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8.w),
                Text('Todos los datos de consumo han sido eliminados'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        
        // Limpiar también los datos temporales locales
        setState(() {
          _datosTemporales.clear();
          _resultadoCargaCSV = null;
        });
        
        widget.onDatosCargados?.call();
      }
    } catch (e) {
      setState(() {
        _error = 'Error al eliminar datos: $e';
      });
    } finally {
      setState(() {
        _eliminandoDatos = false;
      });
    }
  }

  // Helper para mostrar diálogo de carga
  Future<void> _mostrarDialogoCarga({
    required String titulo,
    required String mensaje,
    required Future<void> Function() operacion,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: Row(
              children: [
                SizedBox(
                  width: 20.w,
                  height: 20.h,
                  child: LoadingSpinner(),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    titulo,
                    style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  mensaje,
                  style: AppTextStyles.bodyMedium,
                ),
                SizedBox(height: 16.h),
                const LinearLoading(),
              ],
            ),
          ),
        );
      },
    );

    try {
      await operacion();
      if (mounted) {
        Navigator.of(context).pop(); // Cerrar diálogo de carga
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Cerrar diálogo de carga
        setState(() {
          _error = e.toString();
        });
      }
    }
  }

  // Convertir datos generados a formato CSV
  String _convertirDatosACSV(List<Map<String, dynamic>> datos) {
    if (datos.isEmpty) return '';
    
    final buffer = StringBuffer();
    buffer.writeln('timestamp,consumoEnergia');
    
    for (final dato in datos) {
      final timestamp = dato['timestamp'] as DateTime;
      final consumo = dato['consumo'] as double;
      buffer.writeln('${timestamp.toIso8601String()},${consumo.toStringAsFixed(3)}');
    }
    
    return buffer.toString();
  }

  // Función mejorada para cargar datos generados usando el endpoint CSV
  Future<void> _cargarDatosGeneradosComoCSV() async {
    if (_datosTemporales.isEmpty) {
      setState(() {
        _error = 'No hay datos generados para cargar';
      });
      return;
    }

    await _mostrarDialogoCarga(
      titulo: 'Cargando Datos Generados',
      mensaje: 'Convirtiendo ${_datosTemporales.length} registros a CSV y enviando a la base de datos...',
      operacion: () async {
        // Convertir datos a CSV
        final contenidoCSV = _convertirDatosACSV(_datosTemporales);
        
        // Usar el servicio de carga CSV con bytes
        final resultado = await ref.read(datosConsumoProvider.notifier)
            .cargarDatosCSVBytes(contenidoCSV.codeUnits, widget.idParticipante);

        if (resultado != null && mounted) {
          final mensaje = 'Carga completada: ${resultado.registrosValidos} registros válidos de ${_datosTemporales.length} generados';
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(mensaje),
              backgroundColor: resultado.registrosInvalidos == 0 ? Colors.green : Colors.orange,
              duration: const Duration(seconds: 4),
            ),
          );
          
          _datosTemporales.clear();
          widget.onDatosCargados?.call();
        }
      },
    );
  }

  Future<void> _seleccionarFechaPrediccion(bool esInicio) async {
    final fechaInicial = esInicio 
        ? (_prediccionFechaInicio ?? DateTime.now())
        : (_prediccionFechaFin ?? DateTime.now().add(const Duration(hours: 24)));
        
    final fecha = await showDatePicker(
      context: context,
      initialDate: fechaInicial,
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (fecha != null) {
      // Mostrar selector de hora
      final hora = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(fechaInicial),
      );

      if (hora != null) {
        final fechaCompleta = DateTime(fecha.year, fecha.month, fecha.day, hora.hour, hora.minute);
        
        setState(() {
          if (esInicio) {
            _prediccionFechaInicio = fechaCompleta;
            _prediccionFechaInicioController.text = DateFormat('dd/MM/yyyy HH:mm').format(fechaCompleta);
          } else {
            _prediccionFechaFin = fechaCompleta;
            _prediccionFechaFinController.text = DateFormat('dd/MM/yyyy HH:mm').format(fechaCompleta);
          }
        });
      }
    }
  }

  Future<void> _generarDatosConIA() async {
    if (_prediccionFechaInicio == null || _prediccionFechaFin == null) {
      setState(() {
        _error = 'Debe seleccionar el rango de fechas para la predicción';
      });
      return;
    }

    if (_prediccionFechaInicio!.isAfter(_prediccionFechaFin!)) {
      setState(() {
        _error = 'La fecha de inicio debe ser anterior a la fecha de fin';
      });
      return;
    }

    // Validar otros campos (intervalo y temperatura fijos)
    const intervalos = 1; // Siempre 1 hora
    const temperatura = 20.0; // Temperatura fija por defecto
    final numPersonas = int.tryParse(_numPersonasController.text);
    final lagMes1 = double.tryParse(_lagMes1Controller.text);
    final lagMes2 = double.tryParse(_lagMes2Controller.text);
    final lagMes3 = double.tryParse(_lagMes3Controller.text);

    if (numPersonas == null || numPersonas < 1 || numPersonas > 8) {
      setState(() {
        _error = 'El número de personas debe ser entre 1 y 8';
      });
      return;
    }

    if (lagMes1 == null || lagMes2 == null || lagMes3 == null) {
      setState(() {
        _error = 'Todos los valores de consumo histórico son requeridos';
      });
      return;
    }

    await _mostrarDialogoCarga(
      titulo: 'Generando con IA',
      mensaje: 'Utilizando el Modelo Socioeconómico v3 para generar predicciones horarias...',
      operacion: () async {
        try {
          setState(() {
            _generandoConIA = true;
          });

          // Llamar al endpoint de predicción con valores fijos
          final resultado = await _llamarPrediccionIA(
            fechaInicio: _prediccionFechaInicio!,
            fechaFin: _prediccionFechaFin!,
            intervalos: intervalos,
            tipoVivienda: _tipoViviendaSeleccionada,
            numPersonas: numPersonas,
            temperatura: temperatura,
            lagMes1: lagMes1,
            lagMes2: lagMes2,
            lagMes3: lagMes3,
          );

          if (resultado != null && mounted) {
            setState(() {
              _resultadoPrediccion = resultado;
              _error = null;
            });

            // Convertir predicciones a registros y cargar automáticamente
            if (resultado['predicciones'] != null) {
              await _cargarPrediccionesComoRegistros(resultado['predicciones']);
            }
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              _error = 'Error al generar predicciones: $e';
            });
          }
        } finally {
          setState(() {
            _generandoConIA = false;
          });
        }
      },
    );
  }

  Future<Map<String, dynamic>?> _llamarPrediccionIA({
    required DateTime fechaInicio,
    required DateTime fechaFin,
    required int intervalos,
    required int tipoVivienda,
    required int numPersonas,
    required double temperatura,
    required double lagMes1,
    required double lagMes2,
    required double lagMes3,
  }) async {
    try {
      // Construir la URL del endpoint
      const baseUrl = 'http://localhost:8000'; // Cambiar por la URL real del backend
      const endpoint = '/registros-consumo/predecir-consumo';
      final url = Uri.parse('$baseUrl$endpoint');
      
      // Preparar el cuerpo de la solicitud
      final requestBody = {
        'fecha_inicio': fechaInicio.toIso8601String(),
        'fecha_fin': fechaFin.toIso8601String(),
        'intervalo_horas': intervalos,
        'tipo_vivienda': tipoVivienda,
        'num_personas': numPersonas,
        'temperatura': temperatura,
        'lag_mes1': lagMes1,
        'lag_mes2': lagMes2,
        'lag_mes3': lagMes3,
      };
      
      if (kDebugMode) {
        print('DEBUG: Enviando solicitud a IA - $url');
        print('DEBUG: Datos de solicitud: ${json.encode(requestBody)}');
      }
      
      // Realizar la solicitud HTTP
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      );
      
      if (kDebugMode) {
        print('DEBUG: Respuesta HTTP: ${response.statusCode}');
        print('DEBUG: Cuerpo de respuesta: ${response.body}');
      }
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body) as Map<String, dynamic>;
        
        // Procesar la respuesta del backend
        return responseData;
      } else {
        // Error en la respuesta del servidor
        final errorData = json.decode(response.body);
        throw Exception('Error del servidor (${response.statusCode}): ${errorData['detail'] ?? 'Error desconocido'}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('DEBUG ERROR: Error en llamada a IA: $e');
      }
      
      // Si hay error de conexión, usar simulación como fallback
      if (e.toString().contains('connection') || e.toString().contains('network')) {
        if (kDebugMode) {
          print('DEBUG: Error de conexión, usando simulación como fallback');
        }
        return await _simularPrediccionIA(
          fechaInicio: fechaInicio,
          fechaFin: fechaFin,
          intervalos: intervalos,
          tipoVivienda: tipoVivienda,
          numPersonas: numPersonas,
          temperatura: temperatura,
          lagMes1: lagMes1,
          lagMes2: lagMes2,
          lagMes3: lagMes3,
        );
      }
      
      rethrow; // Re-lanzar otros errores
    }
  }

  Future<Map<String, dynamic>?> _simularPrediccionIA({
    required DateTime fechaInicio,
    required DateTime fechaFin,
    required int intervalos,
    required int tipoVivienda,
    required int numPersonas,
    required double temperatura,
    required double lagMes1,
    required double lagMes2,
    required double lagMes3,
  }) async {
    // Simulación mejorada cuando no hay conexión al backend
    await Future.delayed(const Duration(seconds: 1));
    
    final List<Map<String, dynamic>> predicciones = [];
    DateTime currentTime = fechaInicio;
    
    while (currentTime.isBefore(fechaFin) || currentTime.isAtSameMomentAs(fechaFin)) {
      final hora = currentTime.hour;
      
      // Simular predicción más realista basada en la documentación del modelo
      double factorHora = 0.3 + (0.7 * ((hora % 12) / 12.0)); // Patrón más realista por horas
      double factorVivienda = [0.8, 1.0, 1.2, 1.5][tipoVivienda - 1]; // Factor por tipo de vivienda
      double factorPersonas = 0.6 + (numPersonas * 0.1); // Incremento por persona
      double factorTemperatura = temperatura > 25 ? 1.3 : (temperatura < 15 ? 1.4 : 1.0); // Factor por temperatura
      double promedioLags = (lagMes1 + lagMes2 + lagMes3) / 3;
      
      // Patrón de consumo más realista
      double factorDiario = 1.0;
      if (hora >= 6 && hora <= 9) factorDiario = 1.4; // Mañana
      else if (hora >= 18 && hora <= 22) factorDiario = 1.6; // Tarde-noche
      else if (hora >= 23 || hora <= 5) factorDiario = 0.6; // Madrugada
      
      final consumo = promedioLags * factorHora * factorVivienda * factorPersonas * factorTemperatura * factorDiario;
      
      // Clasificar tipo de tarifa según la documentación
      String tipoTarifa;
      if (hora >= 22 || hora < 8) {
        tipoTarifa = 'Valle';
      } else if (hora >= 8 && hora < 18) {
        tipoTarifa = 'Normal';
      } else {
        tipoTarifa = 'Punta';
      }
      
      predicciones.add({
        'fecha_hora': currentTime.toIso8601String(),
        'consumo_kwh': double.parse(consumo.abs().toStringAsFixed(3)),
        'tipo_tarifa': tipoTarifa,
      });
      
      currentTime = currentTime.add(Duration(hours: intervalos));
    }
    
    // Calcular estadísticas
    if (predicciones.isEmpty) return null;
    
    final totalConsumo = predicciones.fold<double>(0, (sum, p) => sum + p['consumo_kwh']);
    final promedioConsumo = totalConsumo / predicciones.length;
    final consumos = predicciones.map((p) => p['consumo_kwh'] as double).toList();
    final maxConsumo = consumos.reduce((a, b) => a > b ? a : b);
    final minConsumo = consumos.reduce((a, b) => a < b ? a : b);
    
    // Estadísticas por tarifa
    final Map<String, Map<String, dynamic>> estadisticasTarifa = {};
    for (final pred in predicciones) {
      final tarifa = pred['tipo_tarifa'] as String;
      if (!estadisticasTarifa.containsKey(tarifa)) {
        estadisticasTarifa[tarifa] = {
          'periodos': 0,
          'consumo_total': 0.0,
          'consumo_promedio': 0.0,
        };
      }
      estadisticasTarifa[tarifa]!['periodos']++;
      estadisticasTarifa[tarifa]!['consumo_total'] += pred['consumo_kwh'];
    }
    
    // Calcular promedios por tarifa
    estadisticasTarifa.forEach((tarifa, stats) {
      stats['consumo_promedio'] = stats['consumo_total'] / stats['periodos'];
    });
    
    return {
      'predicciones': predicciones,
      'resumen': {
        'fecha_inicio': fechaInicio.toIso8601String(),
        'fecha_fin': fechaFin.toIso8601String(),
        'total_periodos': predicciones.length,
        'consumo_total_kwh': double.parse(totalConsumo.toStringAsFixed(3)),
        'consumo_promedio_kwh': double.parse(promedioConsumo.toStringAsFixed(3)),
        'consumo_maximo_kwh': maxConsumo,
        'consumo_minimo_kwh': minConsumo,
        'estadisticas_por_tarifa': estadisticasTarifa,
        'modelo_info': {
          'algoritmo': 'LightGBM',
          'version': 'v3_optimizada',
          'caracteristicas': 11,
        }
      }
    };
  }

  Future<void> _cargarPrediccionesComoRegistros(List<dynamic> predicciones) async {
    // Convertir predicciones a formato CSV y usar el endpoint existente
    final buffer = StringBuffer();
    buffer.writeln('timestamp,consumoEnergia');
    
    for (final pred in predicciones) {
      buffer.writeln('${pred['fecha_hora']},${pred['consumo_kwh']}');
    }
    
    final contenidoCSV = buffer.toString();
    
    // Usar el servicio de carga CSV existente
    final resultado = await ref.read(datosConsumoProvider.notifier)
        .cargarDatosCSVBytes(contenidoCSV.codeUnits, widget.idParticipante);

    if (resultado != null && mounted) {
      final mensaje = 'IA completada: ${resultado.registrosValidos} registros de ${predicciones.length} predicciones';
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: resultado.registrosInvalidos == 0 ? Colors.green : Colors.orange,
          duration: const Duration(seconds: 4),
        ),
      );
      
      widget.onDatosCargados?.call();
    }
  }

  Future<void> _verificarEstadoModelo() async {
    setState(() {
      _verificandoModelo = true;
    });

    try {
      const baseUrl = 'http://localhost:8000';
      const endpoint = '/registros-consumo/modelo/estado';
      final url = Uri.parse('$baseUrl$endpoint');
      
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final estadoData = json.decode(response.body) as Map<String, dynamic>;
        setState(() {
          _estadoModelo = estadoData;
        });
      } else {
        // Si no se puede verificar el estado, asumir que está disponible
        setState(() {
          _estadoModelo = {
            'modelo_disponible': false,
            'error': 'No se pudo verificar el estado del modelo',
            'mensaje': 'Usando simulación local como fallback'
          };
        });
      }
    } catch (e) {
      // Error de conexión, usar simulación
      setState(() {
        _estadoModelo = {
          'modelo_disponible': false,
          'error': 'Sin conexión al servidor',
          'mensaje': 'Usando simulación local como fallback'
        };
      });
    } finally {
      setState(() {
        _verificandoModelo = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.center,            
            tabs: const [
              Tab(text: 'Manual', icon: Icon(Icons.edit)),
              Tab(text: 'Generación', icon: Icon(Icons.auto_awesome)),
              Tab(text: 'Archivo CSV', icon: Icon(Icons.upload_file)),
              Tab(text: 'Predicción IA', icon: Icon(Icons.psychology)),
            ],
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCargaManual(),
                _buildGeneracionDatos(),
                _buildCargaArchivo(),
                _buildPrediccionIA(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCargaManual() {
    return ListView(
      padding: EdgeInsets.all(8.w),
      children: [
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.border),
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
              Text('Registro Manual', style: AppTextStyles.cardTitle),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _fechaController,
                      style: AppTextStyles.bodyMedium,
                      inputFormatters: [DateInputFormatter()],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Fecha',
                        labelStyle: AppTextStyles.bodyMedium,
                        hintText: 'dd/mm/yyyy',
                        hintStyle: AppTextStyles.bodySecondary,
                        prefixIcon: Icon(
                          Icons.calendar_today,
                          color: AppColors.textSecondary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: const BorderSide(color: AppColors.primary, width: 2),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingrese la fecha';
                        }
                        if (value.length != 10) {
                          return 'Formato: dd/mm/yyyy';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: TextFormField(
                      controller: _horaController,
                      style: AppTextStyles.bodyMedium,
                      decoration: InputDecoration(
                        labelText: 'Hora',
                        labelStyle: AppTextStyles.bodyMedium,
                        hintText: 'HH:MM',
                        hintStyle: AppTextStyles.bodySecondary,
                        prefixIcon: Icon(
                          Icons.access_time,
                          color: AppColors.textSecondary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: const BorderSide(color: AppColors.primary, width: 2),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                      ),
                      onTap: _seleccionarHora,
                      readOnly: true,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _consumoController,
                style: AppTextStyles.bodyMedium,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Consumo de Energía',
                  labelStyle: AppTextStyles.bodyMedium,
                  suffixText: 'kWh',
                  hintText: '1.50',
                  hintStyle: AppTextStyles.bodySecondary,
                  prefixIcon: Icon(
                    Icons.bolt,
                    color: AppColors.textSecondary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese el consumo';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Ingrese un número válido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _guardarRegistroManual,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: _isLoading
                      ? const ButtonLoadingSpinner()
                      : Text(
                          'Guardar Registro',
                          style: AppTextStyles.button.copyWith(color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
        if (_error != null) ...[
          SizedBox(height: 16.h),
          _buildErrorCard(),
        ],
      ],
    );
  }

  Widget _buildGeneracionDatos() {
    return ListView(
      padding: EdgeInsets.all(8.w),
      children: [
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.border),
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
              Text('Generación Automática', style: AppTextStyles.cardTitle),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _rangoFechaInicioController,
                      style: AppTextStyles.bodyMedium,
                      inputFormatters: [DateInputFormatter()],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Fecha Inicio',
                        labelStyle: AppTextStyles.bodyMedium,
                        hintText: 'dd/mm/yyyy',
                        hintStyle: AppTextStyles.bodySecondary,
                        prefixIcon: Icon(
                          Icons.calendar_today,
                          color: AppColors.textSecondary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: const BorderSide(color: AppColors.primary, width: 2),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: TextFormField(
                      controller: _rangoFechaFinController,
                      style: AppTextStyles.bodyMedium,
                      inputFormatters: [DateInputFormatter()],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Fecha Fin',
                        labelStyle: AppTextStyles.bodyMedium,
                        hintText: 'dd/mm/yyyy',
                        hintStyle: AppTextStyles.bodySecondary,
                        prefixIcon: Icon(
                          Icons.calendar_today,
                          color: AppColors.textSecondary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: const BorderSide(color: AppColors.primary, width: 2),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _consumoBaseController,
                      style: AppTextStyles.bodyMedium,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Consumo Base',
                        labelStyle: AppTextStyles.bodyMedium,
                        suffixText: 'kWh',
                        hintText: '1.0',
                        hintStyle: AppTextStyles.bodySecondary,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: const BorderSide(color: AppColors.primary, width: 2),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: TextFormField(
                      controller: _variacionController,
                      style: AppTextStyles.bodyMedium,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Factor de Variación',
                        labelStyle: AppTextStyles.bodyMedium,
                        hintText: '0.2',
                        hintStyle: AppTextStyles.bodySecondary,
                        helperText: 'Variación aleatoria (0.0 - 1.0)',
                        helperStyle: AppTextStyles.caption,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: const BorderSide(color: AppColors.primary, width: 2),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.info, size: 8.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Se generarán automáticamente 24 registros por día (1 por hora)',
                        style: AppTextStyles.caption.copyWith(color: AppColors.info),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _generarDatosTemporales,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        'Generar Datos',
                        style: AppTextStyles.button.copyWith(color: AppColors.primary),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _datosTemporales.isEmpty || _isLoading ? null : _cargarDatosGenerados,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: _isLoading
                          ? const ButtonLoadingSpinner()
                          : Text(
                              'Cargar a BD',
                              style: AppTextStyles.button.copyWith(color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
              if (_datosTemporales.isNotEmpty) ...[
                SizedBox(height: 16.h),
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: AppColors.success, size: 20.sp),
                      SizedBox(width: 8.w),
                      Text(
                        '${_datosTemporales.length} registros generados',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.success),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        if (_error != null) ...[
          SizedBox(height: 16.h),
          _buildErrorCard(),
        ],
      ],
    );
  }

  Widget _buildCargaArchivo() {
    return ListView(
      padding: EdgeInsets.all(8.w),
      children: [
        CustomCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Carga desde Archivo CSV', style: AppTextStyles.cardTitle),
              SizedBox(height: 16.h),
            
              
              SizedBox(height: 20.h),
              
              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Seleccionar Archivo',
                      type: ButtonType.outline,
                      onPressed: _seleccionarArchivoCSV,
                      icon: Icons.folder_open,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: CustomButton(
                      text: 'Cargar CSV',
                      onPressed: _nombreArchivoCSV != null ? _cargarArchivoCSV : null,
                      icon: Icons.cloud_upload,
                    ),
                  ),
                  if (_nombreArchivoCSV != null) ...[
                    SizedBox(width: 8.w),
                    IconButton(
                      onPressed: _limpiarSeleccionCSV,
                      icon: const Icon(Icons.clear),
                      tooltip: 'Limpiar selección',
                    ),
                  ],
                ],
              ),
              
              SizedBox(height: 20.h),
              
              // Resultado de la carga
              if (_resultadoCargaCSV != null) ...[
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: _resultadoCargaCSV!.registrosInvalidos == 0 
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: _resultadoCargaCSV!.registrosInvalidos == 0 
                          ? Colors.green.withValues(alpha: 0.3)
                          : Colors.orange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _resultadoCargaCSV!.registrosInvalidos == 0 
                                ? Icons.check_circle 
                                : Icons.warning,
                            color: _resultadoCargaCSV!.registrosInvalidos == 0 
                                ? Colors.green 
                                : Colors.orange,
                            size: 24.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Resultado de la Carga',
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _resultadoCargaCSV!.registrosInvalidos == 0 
                                  ? Colors.green 
                                  : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      _buildEstadisticaCarga('Registros procesados', _resultadoCargaCSV!.registrosProcesados, Icons.list_alt),
                      _buildEstadisticaCarga('Registros válidos', _resultadoCargaCSV!.registrosValidos, Icons.check, Colors.green),
                      if (_resultadoCargaCSV!.registrosInvalidos > 0)
                        _buildEstadisticaCarga('Registros inválidos', _resultadoCargaCSV!.registrosInvalidos, Icons.error, Colors.red),
                      if (_resultadoCargaCSV!.errores.isNotEmpty) ...[
                        SizedBox(height: 8.h),
                        Text(
                          'Errores encontrados:',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        ...(_resultadoCargaCSV!.errores.take(3).map((error) => 
                          Padding(
                            padding: EdgeInsets.only(left: 8.w, top: 4.h),
                            child: Text(
                              '• $error',
                              style: AppTextStyles.caption.copyWith(color: Colors.red),
                            ),
                          )
                        )),
                        if (_resultadoCargaCSV!.errores.length > 3)
                          Padding(
                            padding: EdgeInsets.only(left: 8.w, top: 4.h),
                            child: Text(
                              '... y ${_resultadoCargaCSV!.errores.length - 3} errores más',
                              style: AppTextStyles.caption.copyWith(color: Colors.red),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
              ],
              
              // Información del formato CSV
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue, size: 20.sp),
                        SizedBox(width: 8.w),
                        Text(
                          'Formato CSV requerido:',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Columnas requeridas:',
                            style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '• timestamp: Fecha y hora (YYYY-MM-DDTHH:MM:SS o YYYY-MM-DD HH:MM:SS)\n'
                            '• consumoEnergia: Valor numérico en kWh',
                            style: AppTextStyles.caption,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Ejemplo:',
                            style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'timestamp,consumoEnergia\n'
                            '2023-01-01T00:00:00,1.48\n'
                            '2023-01-01 01:00:00,1.52\n'
                            '2023-01-01T02:00:00,1.36',
                            style: AppTextStyles.caption.copyWith(
                              fontFamily: 'monospace',
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_error != null) ...[
          SizedBox(height: 16.h),
          _buildErrorCard(),
        ],
      ],
    );
  }

  Widget _buildPrediccionIA() {
    return ListView(
      padding: EdgeInsets.all(8.w),
      children: [
        CustomCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.psychology, color: Colors.purple, size: 24.sp),
                  SizedBox(width: 8.w),
                  Text('Predicción con IA', style: AppTextStyles.cardTitle),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                'Modelo Socioeconómico v3 - LightGBM con 11 características',
                style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[600]),
              ),
              SizedBox(height: 16.h),
              
              // Rango de fechas
              Text(
                'Período de Predicción',
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _prediccionFechaInicioController,
                      decoration: const InputDecoration(
                        labelText: 'Fecha y Hora Inicio',
                        prefixIcon: Icon(Icons.schedule),
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                      onTap: () => _seleccionarFechaPrediccion(true),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: TextFormField(
                      controller: _prediccionFechaFinController,
                      decoration: const InputDecoration(
                        labelText: 'Fecha y Hora Fin',
                        prefixIcon: Icon(Icons.schedule),
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                      onTap: () => _seleccionarFechaPrediccion(false),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              
              // Características socioeconómicas
              Text(
                'Perfil del Hogar',
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h),
              
              DropdownButtonFormField<int>(
                value: _tipoViviendaSeleccionada,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Vivienda',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('🏠 Casa pequeña')),
                  DropdownMenuItem(value: 2, child: Text('🏢 Apartamento')),
                  DropdownMenuItem(value: 3, child: Text('🏡 Casa mediana')),
                  DropdownMenuItem(value: 4, child: Text('🏘️ Casa grande')),
                ],
                onChanged: (value) {
                  setState(() {
                    _tipoViviendaSeleccionada = value!;
                  });
                },
              ),
              SizedBox(height: 16.h),
              
              TextFormField(
                controller: _numPersonasController,
                decoration: const InputDecoration(
                  labelText: 'Número de Personas',
                  hintText: '3',
                  suffixText: 'personas',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20.h),
              
              // Datos históricos con texto actualizado
              Text(
                'Consumo Histórico (media horaria del mes)',
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _lagMes1Controller,
                      decoration: const InputDecoration(
                        labelText: 'Mes Anterior',
                        hintText: '0.45',
                        suffixText: 'kWh/h',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: TextFormField(
                      controller: _lagMes2Controller,
                      decoration: const InputDecoration(
                        labelText: 'Hace 2 Meses',
                        hintText: '0.48',
                        suffixText: 'kWh/h',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: TextFormField(
                      controller: _lagMes3Controller,
                      decoration: const InputDecoration(
                        labelText: 'Hace 3 Meses',
                        hintText: '0.52',
                        suffixText: 'kWh/h',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              
              // Botón de generar
              CustomButton(
                text: _generandoConIA ? 'Generando con IA...' : 'Generar con IA',
                onPressed: _generandoConIA || _isLoading ? null : _generarDatosConIA,
                fullWidth: true,
                isLoading: _generandoConIA || _isLoading,
                icon: Icons.psychology,
              ),
              
              // Resultado de la predicción
              if (_resultadoPrediccion != null) ...[
                SizedBox(height: 20.h),
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.analytics, color: Colors.purple, size: 24.sp),
                          SizedBox(width: 8.w),
                          Text(
                            'Resultado de Predicción IA',
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      
                      () {
                        final resumen = _resultadoPrediccion!['resumen'] as Map<String, dynamic>;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildEstadisticaPrediccion('Período', '${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(resumen['fecha_inicio']))} - ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(resumen['fecha_fin']))}', Icons.calendar_today),
                            _buildEstadisticaPrediccion('Predicciones', '${resumen['total_periodos']} horas', Icons.schedule),
                            _buildEstadisticaPrediccion('Consumo Total', '${resumen['consumo_total_kwh']} kWh', Icons.bolt, Colors.orange),
                            _buildEstadisticaPrediccion('Promedio', '${resumen['consumo_promedio_kwh']} kWh/h', Icons.trending_up, Colors.green),
                            _buildEstadisticaPrediccion('Máximo', '${resumen['consumo_maximo_kwh']} kWh', Icons.keyboard_arrow_up, Colors.red),
                            _buildEstadisticaPrediccion('Mínimo', '${resumen['consumo_minimo_kwh']} kWh', Icons.keyboard_arrow_down, Colors.blue),
                            
                            SizedBox(height: 12.h),
                            Text(
                              'Distribución por Tarifa:',
                              style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4.h),
                            
                            () {
                              final estadisticasTarifa = resumen['estadisticas_por_tarifa'] as Map<String, dynamic>;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: estadisticasTarifa.entries.map((entry) {
                                  final tarifa = entry.key;
                                  final stats = entry.value as Map<String, dynamic>;
                                  final iconoTarifa = {"Valle": "🌙", "Normal": "☀️", "Punta": "🔥"}[tarifa] ?? "⚡";
                                  return Padding(
                                    padding: EdgeInsets.symmetric(vertical: 2.h),
                                    child: Text(
                                      '$iconoTarifa $tarifa: ${stats['periodos']} horas, ${stats['consumo_total'].toStringAsFixed(3)} kWh',
                                      style: AppTextStyles.caption.copyWith(color: Colors.grey[700]),
                                    ),
                                  );
                                }).toList(),
                              );
                            }(),
                          ],
                        );
                      }(),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        
        // Información del modelo
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info, color: Colors.blue, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'Modelo Socioeconómico v3',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (_verificandoModelo)
                    LoadingSpinner()
                  else
                    IconButton(
                      onPressed: _verificarEstadoModelo,
                      icon: Icon(Icons.refresh, size: 18.sp, color: Colors.blue),
                      tooltip: 'Verificar estado del modelo',
                    ),
                ],
              ),
              SizedBox(height: 12.h),
              
              // Estado del modelo
              if (_estadoModelo != null) ...[
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: (_estadoModelo!['modelo_disponible'] == true ? Colors.green : Colors.orange).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: (_estadoModelo!['modelo_disponible'] == true ? Colors.green : Colors.orange).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _estadoModelo!['modelo_disponible'] == true ? Icons.check_circle : Icons.warning,
                        color: _estadoModelo!['modelo_disponible'] == true ? Colors.green : Colors.orange,
                        size: 16.sp,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          _estadoModelo!['modelo_disponible'] == true 
                              ? 'Modelo IA disponible y funcionando' 
                              : 'Modelo IA no disponible - usando simulación',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: _estadoModelo!['modelo_disponible'] == true ? Colors.green : Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8.h),
              ],
              
              Text(
                '🧠 Algoritmo: LightGBM optimizado\n'
                '🔧 Características: 11 (2 socioeconómicas + 5 temporales + 3 lags + 1 climática)\n'
                '📊 Precisión: R² ~0.85, MAE ~0.15 kWh\n'
                '⚡ Clasificación automática de tarifas (Valle/Normal/Punta)\n'
                '🎯 Predicciones horarias automáticas (intervalo fijo: 1 hora)\n'
                '🌡️ Temperatura: 20°C por defecto (valor optimizado)',
                style: AppTextStyles.bodySmall.copyWith(color: Colors.blue[700]),
              ),
              
              if (_estadoModelo != null && _estadoModelo!['modelo_disponible'] == true) ...[
                SizedBox(height: 8.h),
                Text(
                  '✅ Versión: ${_estadoModelo!['version'] ?? 'v3_optimizada'}\n'
                  '📁 Ubicación: ${_estadoModelo!['ubicacion'] ?? 'app/ml/'}\n'
                  '📄 Archivos: modelo_lightgbm_optimizado.pkl, metadata.pkl',
                  style: AppTextStyles.caption.copyWith(color: Colors.green[700]),
                ),
              ] else if (_estadoModelo != null) ...[
                SizedBox(height: 8.h),
                Text(
                  '⚠️ ${_estadoModelo!['mensaje'] ?? 'Usando simulación como fallback'}\n'
                  '🔄 Las predicciones se generarán con un modelo simulado\n'
                  '📊 Resultados aproximados basados en patrones típicos',
                  style: AppTextStyles.caption.copyWith(color: Colors.orange[700]),
                ),
              ],
            ],
          ),
        ),
        
        if (_error != null) ...[
          SizedBox(height: 16.h),
          _buildErrorCard(),
        ],
      ],
    );
  }

  Widget _buildEstadisticaPrediccion(String label, String valor, IconData icono, [Color? color]) {
    final colorFinal = color ?? Colors.grey[700]!;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Icon(icono, size: 16.sp, color: colorFinal),
          SizedBox(width: 8.w),
          Text(
            '$label: ',
            style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[600]),
          ),
          Expanded(
            child: Text(
              valor,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.bold,
                color: colorFinal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.error.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 24.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Error',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _error!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadisticaCarga(String label, int valor, IconData icono, [Color? color]) {
    final colorFinal = color ?? Colors.grey[700]!;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Icon(icono, size: 16.sp, color: colorFinal),
          SizedBox(width: 8.w),
          Text(
            '$label: ',
            style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[600]),
          ),
          Text(
            valor.toString(),
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.bold,
              color: colorFinal,
            ),
          ),
        ],
      ),
    );
  }

} 