import 'package:frontend/services/api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final  apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});