import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_colors.dart';
import '../core/widgets/loading_indicators.dart';
import '../models/comunidad_energetica.dart';
import '../models/enums/tipo_estrategia_excedentes.dart';
import '../providers/user_provider.dart';
import '../providers/comunidad_energetica_provider.dart';

class CrearComunidadDialog extends ConsumerStatefulWidget {
  const CrearComunidadDialog({super.key});

  @override
  ConsumerState<CrearComunidadDialog> createState() => _CrearComunidadDialogState();
}

class _CrearComunidadDialogState extends ConsumerState<CrearComunidadDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _latitudController = TextEditingController();
  final _longitudController = TextEditingController();
  TipoEstrategiaExcedentes _tipoEstrategia = TipoEstrategiaExcedentes.INDIVIDUAL_SIN_EXCEDENTES;
  bool _isLoading = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _latitudController.dispose();
    _longitudController.dispose();
    super.dispose();
  }

  Future<void> _createComunidad() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        // Obtener el usuario actual desde el auth provider
        final authState = ref.read(authProvider);
        
        if (!authState.isLoggedIn || authState.usuario == null) {
          throw Exception('Debe iniciar sesión para crear una comunidad');
        }
        
        final usuario = authState.usuario!;
        
        // Crear comunidad
        final nuevaComunidad = ComunidadEnergetica(
          idComunidadEnergetica: 0, // Se asignará en el servidor
          nombre: _nombreController.text,
          latitud: double.parse(_latitudController.text),
          longitud: double.parse(_longitudController.text),
          tipoEstrategiaExcedentes: _tipoEstrategia,
          idUsuario: usuario.idUsuario,
        );
        
        // Usar el StateNotifierProvider para crear la comunidad
        final comunidadesNotifier = ref.read(comunidadesNotifierProvider.notifier);
        await comunidadesNotifier.addComunidad(nuevaComunidad);
        
        if (!mounted) return;
        
        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comunidad creada con éxito'),
            backgroundColor: AppColors.success,
          ),
        );
        
        // Cerrar el dialog
        Navigator.of(context).pop(true); // Retornar true para indicar éxito
        
        // Recargar la lista de comunidades
        await ref.read(comunidadesNotifierProvider.notifier).loadComunidadesUsuario(usuario.idUsuario);
        
        // Auto-seleccionar la nueva comunidad
        final comunidades = ref.read(comunidadesNotifierProvider);
        if (comunidades.isNotEmpty) {
          final nuevaComunidadCreada = comunidades.firstWhere(
            (c) => c.nombre == _nombreController.text,
            orElse: () => comunidades.last,
          );
          ref.read(comunidadSeleccionadaProvider.notifier).seleccionarComunidad(nuevaComunidadCreada);
        }
        
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  String _getEstrategiaLabel(TipoEstrategiaExcedentes estrategia) {
    switch (estrategia) {
      case TipoEstrategiaExcedentes.INDIVIDUAL_SIN_EXCEDENTES:
        return 'Individual sin excedentes';
      case TipoEstrategiaExcedentes.INDIVIDUAL_EXCEDENTES_COMPENSACION:
        return 'Individual con excedentes y compensación';
      case TipoEstrategiaExcedentes.COLECTIVO_SIN_EXCEDENTES:
        return 'Colectivo sin excedentes';
      case TipoEstrategiaExcedentes.COLECTIVO_EXCEDENTES_COMPENSACION_RED_EXTERNA:
        return 'Colectivo con excedentes y compensación externa';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.add_business, color: AppColors.primary),
          SizedBox(width: 8),
          Text('Crear Nueva Comunidad'),
        ],
      ),
      contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 0.0),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.5,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de la comunidad',
                    hintText: 'Ejemplo: Comunidad Solar Madrid Centro',
                    prefixIcon: Icon(Icons.group),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa un nombre';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _latitudController,
                  decoration: const InputDecoration(
                    labelText: 'Latitud',
                    hintText: 'Ejemplo: 40.416775',
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa la latitud';
                    }
                    try {
                      final lat = double.parse(value);
                      if (lat < -90 || lat > 90) {
                        return 'La latitud debe estar entre -90 y 90';
                      }
                    } catch (e) {
                      return 'Ingresa un número válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _longitudController,
                  decoration: const InputDecoration(
                    labelText: 'Longitud',
                    hintText: 'Ejemplo: -3.703790',
                    prefixIcon: Icon(Icons.explore),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa la longitud';
                    }
                    try {
                      final lon = double.parse(value);
                      if (lon < -180 || lon > 180) {
                        return 'La longitud debe estar entre -180 y 180';
                      }
                    } catch (e) {
                      return 'Ingresa un número válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Estrategia para excedentes de energía:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<TipoEstrategiaExcedentes>(
                  value: _tipoEstrategia,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.flash_on),
                    border: OutlineInputBorder(),
                  ),
                  items: TipoEstrategiaExcedentes.values.map((estrategia) {
                    return DropdownMenuItem<TipoEstrategiaExcedentes>(
                      value: estrategia,
                      child: Text(_getEstrategiaLabel(estrategia)),
                    );
                  }).toList(),
                  onChanged: (TipoEstrategiaExcedentes? value) {
                    setState(() {
                      if (value != null) {
                        _tipoEstrategia = value;
                      }
                    });
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _createComunidad,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const ButtonLoadingSpinner()
              : const Text('Crear'),
        ),
      ],
    );
  }
} 