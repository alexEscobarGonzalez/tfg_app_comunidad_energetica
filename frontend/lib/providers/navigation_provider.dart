import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sidebarx/sidebarx.dart';

/// Provider para el controlador del sidebar
final sidebarControllerProvider = Provider<SidebarXController>((ref) {
  return SidebarXController(selectedIndex: 0, extended: true);
});

/// Provider para el índice seleccionado del sidebar
final selectedIndexProvider = StateProvider<int>((ref) => 0); 