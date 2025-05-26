# Gestión de Participantes

Este módulo permite la gestión de participantes en comunidades energéticas dentro de la aplicación.

## Funcionalidades implementadas

- **Crear participantes**: Permite agregar nuevos miembros a una comunidad energética, asignándoles opcionalmente el rol de administrador.
- **Listar participantes**: Muestra todos los participantes en una comunidad energética específica.

## Estructura de archivos

- `models/participante.dart`: Modelo de datos para representar un participante.
- `services/participante_service.dart`: Servicio para interactuar con la API de participantes.
- `providers/participante_provider.dart`: Proveedor Riverpod para la gestión del estado de los participantes.
- `views/crear_participante_view.dart`: Vista para crear nuevos participantes.
- `views/lista_participantes_view.dart`: Vista para listar participantes por comunidad.

## Uso del servicio y el provider

### Servicio de Participantes

El servicio facilita la comunicación con la API REST para operaciones relacionadas con los participantes:

```dart
// Crear un participante
final participante = await participanteService.crearParticipante(
  usuario: usuario,
  comunidadEnergetica: comunidad,
  esAdministrador: true,
);

// Obtener participantes de una comunidad
final participantes = await participanteService.obtenerParticipantesPorComunidad(idComunidad);

// Obtener un participante específico
final participante = await participanteService.obtenerParticipante(idParticipante);
```

### Provider de Participantes

El provider utiliza Riverpod para gestionar el estado de los participantes:

```dart
// Crear un participante
final participante = await ref.read(participantesProvider.notifier).crearParticipante(
  usuario: usuario,
  comunidadEnergetica: comunidad,
  esAdministrador: true,
);

// Cargar participantes de una comunidad
await ref.read(participantesProvider.notifier).cargarParticipantesPorComunidad(idComunidad);

// Acceder al estado actual de los participantes
final participantesState = ref.watch(participantesProvider);
final participantes = participantesState.participantes;
final isLoading = participantesState.isLoading;
final error = participantesState.error;
```

## Navegación

- La pantalla de creación de participantes está disponible en `/crear-participante`
- La lista de participantes por comunidad está disponible en `/participantes/comunidad/{id}` donde `{id}` es el ID de la comunidad
