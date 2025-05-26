import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/comunidad_energetica.dart';
import 'package:frontend/models/enums/tipo_estrategia_excedentes.dart';
import 'package:frontend/providers/comunidad_energetica_provider.dart';

class DetalleComunidadView extends ConsumerStatefulWidget {
  final int idComunidad;
  
  const DetalleComunidadView({
    required this.idComunidad,
    super.key,
  });

  @override
  ConsumerState<DetalleComunidadView> createState() => _DetalleComunidadViewState();
}

class _DetalleComunidadViewState extends ConsumerState<DetalleComunidadView> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nombreController;
  late TextEditingController _latitudController;
  late TextEditingController _longitudController;
  late TipoEstrategiaExcedentes _tipoEstrategia;
  
  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController();
    _latitudController = TextEditingController();
    _longitudController = TextEditingController();
    _tipoEstrategia = TipoEstrategiaExcedentes.INDIVIDUAL_SIN_EXCEDENTES;
  }
  
  @override
  void dispose() {
    _nombreController.dispose();
    _latitudController.dispose();
    _longitudController.dispose();
    super.dispose();
  }
  
  void _initializeControllers(ComunidadEnergetica comunidad) {
    _nombreController.text = comunidad.nombre;
    _latitudController.text = comunidad.latitud.toString();
    _longitudController.text = comunidad.longitud.toString();
    _tipoEstrategia = comunidad.tipoEstrategiaExcedentes;
  }
  
  @override
  Widget build(BuildContext context) {
    // Obtener detalles de la comunidad
    final comunidadAsyncValue = ref.watch(comunidadDetalleProvider(widget.idComunidad));
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles de Comunidad'),
        actions: [
          comunidadAsyncValue.when(
            data: (comunidad) => Row(
              children: [
                if (!_isEditing)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      setState(() {
                        _isEditing = true;
                        _initializeControllers(comunidad);
                      });
                    },
                  ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _showDeleteConfirmationDialog(comunidad),
                ),
              ],
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: comunidadAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Error al cargar la comunidad: $error'),
        ),
        data: (comunidad) {
          if (_isEditing) {
            return _buildEditForm(comunidad);
          } else {
            return _buildDetailsView(comunidad);
          }
        },
      ),
    );
  }
  
  Widget _buildDetailsView(ComunidadEnergetica comunidad) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Información general',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),
                  _buildInfoRow('Nombre', comunidad.nombre),
                  _buildInfoRow('ID', comunidad.idComunidadEnergetica.toString()),
                  _buildInfoRow('Latitud', comunidad.latitud.toString()),
                  _buildInfoRow('Longitud', comunidad.longitud.toString()),
                  _buildInfoRow(
                    'Estrategia de excedentes', 
                    _getEstrategiaExcedentesString(comunidad.tipoEstrategiaExcedentes)
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Aquí podemos añadir más secciones como participantes, activos, etc.
          _buildActionButtons(),
        ],
      ),
    );
  }
  
  Widget _buildEditForm(ComunidadEnergetica comunidad) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre de la comunidad',
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
            DropdownButtonFormField<TipoEstrategiaExcedentes>(
              value: _tipoEstrategia,
              decoration: const InputDecoration(
                labelText: 'Estrategia para excedentes',
                border: OutlineInputBorder(),
              ),
              items: TipoEstrategiaExcedentes.values.map((estrategia) {
                return DropdownMenuItem<TipoEstrategiaExcedentes>(
                  value: estrategia,
                  child: Text(_getEstrategiaExcedentesString(estrategia)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _tipoEstrategia = value;
                  });
                }
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = false;
                    });
                  },
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => _updateComunidad(comunidad),
                  child: const Text('Guardar cambios'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButtons() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Acciones',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Ver participantes'),
              onTap: () {
                // Aquí iría la navegación a la vista de participantes
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Funcionalidad en desarrollo')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.flash_on),
              title: const Text('Ver activos de generación'),
              onTap: () {
                // Aquí iría la navegación a la vista de activos de generación
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Funcionalidad en desarrollo')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.battery_charging_full),
              title: const Text('Ver activos de almacenamiento'),
              onTap: () {
                // Aquí iría la navegación a la vista de activos de almacenamiento
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Funcionalidad en desarrollo')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.assessment),
              title: const Text('Ejecutar simulación'),
              onTap: () {
                // Aquí iría la navegación a la vista de simulación
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Funcionalidad en desarrollo')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _updateComunidad(ComunidadEnergetica comunidad) async {
    if (_formKey.currentState!.validate()) {
      try {
        final comunidadActualizada = ComunidadEnergetica(
          idComunidadEnergetica: comunidad.idComunidadEnergetica,
          nombre: _nombreController.text,
          latitud: double.parse(_latitudController.text),
          longitud: double.parse(_longitudController.text),
          tipoEstrategiaExcedentes: _tipoEstrategia,
          idUsuario: comunidad.idUsuario,
        );
        
        // Actualizar la comunidad
        final notifier = ref.read(comunidadesNotifierProvider.notifier);
        await notifier.updateComunidad(comunidad.idComunidadEnergetica, comunidadActualizada);
        
        if (!mounted) return;
        
        // Salir del modo edición
        setState(() {
          _isEditing = false;
        });
        
        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comunidad actualizada con éxito')),
        );
        
        // Refrescar detalles
        ref.invalidate(comunidadDetalleProvider(widget.idComunidad));
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar la comunidad: $e')),
        );
      }
    }
  }
  
  Future<void> _showDeleteConfirmationDialog(ComunidadEnergetica comunidad) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar comunidad'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('¿Estás seguro que deseas eliminar la comunidad ${comunidad.nombre}?'),
                const SizedBox(height: 10),
                const Text(
                  'Esta acción no se puede deshacer y eliminará todos los datos asociados a esta comunidad.',
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteComunidad(comunidad);
              },
            ),
          ],
        );
      },
    );
  }
  
  Future<void> _deleteComunidad(ComunidadEnergetica comunidad) async {
    try {
      final notifier = ref.read(comunidadesNotifierProvider.notifier);
      await notifier.deleteComunidad(comunidad.idComunidadEnergetica);
      
      if (!mounted) return;
      
      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comunidad eliminada con éxito')),
      );
      
      // Volver a la lista de comunidades
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar la comunidad: $e')),
      );
    }
  }
  
  String _getEstrategiaExcedentesString(TipoEstrategiaExcedentes estrategia) {
    switch (estrategia) {
      case TipoEstrategiaExcedentes.INDIVIDUAL_SIN_EXCEDENTES:
        return 'Individual sin excedentes';
      case TipoEstrategiaExcedentes.COLECTIVO_SIN_EXCEDENTES:
        return 'Colectivo sin excedentes';
      case TipoEstrategiaExcedentes.INDIVIDUAL_EXCEDENTES_COMPENSACION:
        return 'Individual con excedentes y compensación';
      case TipoEstrategiaExcedentes.COLECTIVO_EXCEDENTES_COMPENSACION_RED_EXTERNA:
        return 'Colectivo con excedentes y compensación externa';
    }
  }
}
