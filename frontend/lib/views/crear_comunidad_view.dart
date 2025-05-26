import 'package:flutter/material.dart';
import 'package:frontend/models/comunidad_energetica.dart';
import 'package:frontend/models/enums/tipo_estrategia_excedentes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/providers/comunidad_energetica_provider.dart';

class CrearComunidadView extends ConsumerStatefulWidget {
  const CrearComunidadView({super.key});

  @override
  ConsumerState<CrearComunidadView> createState() => _CrearComunidadViewState();
}

class _CrearComunidadViewState extends ConsumerState<CrearComunidadView> {
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
  }  Future<void> _createComunidad() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        // Obtener el usuario actual desde el provider
        final usuario = ref.read(userProvider);
        
        if (usuario == null) {
          throw Exception('Debe iniciar sesión para crear una comunidad');
        }
        
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
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comunidad creada con éxito')),
        );
        
        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Comunidad Energética'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de la comunidad',
                    hintText: 'Ejemplo: Comunidad Solar Madrid Centro',
                    prefixIcon: Icon(Icons.group),
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
                const SizedBox(height: 24),
                const Text(
                  'Estrategia para excedentes de energía:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _createComunidad,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('CREAR COMUNIDAD'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
}
