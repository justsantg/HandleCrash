
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show Provider, StreamProvider;
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/repositories/vehicle_repository_impl.dart';
import '../data/supabase_client.dart';
import '../domain/models/vehicle.dart';
import '../domain/repositories/vehicle_repository.dart';
import '../domain/usecases/get_vehicle_usecase.dart';
import '../domain/usecases/save_vehicle_usecase.dart';
import '../domain/usecases/delete_vehicle_usecase.dart';
import '../services/auth_service.dart';

// ==================== AUTH PROVIDERS ====================

final supabaseClientProvider = Provider<SupabaseClientManager>((ref) {
  return SupabaseClientManager();
});

// Auth Service Provider
final authServiceProvider = Provider<AuthService>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider).client;
  return AuthService(supabaseClient);
});

// Auth State Provider (stream)
final authStateProvider = StreamProvider<AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// Current User Provider
final currentUserProvider = Provider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.currentUser;
});

// ==================== VEHICLE PROVIDERS ====================

final connectivityProvider = Provider<Connectivity>((ref) {
  return Connectivity();
});

final vehicleBoxProvider = Provider<Box<Vehicle>>((ref) {
  throw UnimplementedError('Vehicle box must be initialized in main');
});

final vehicleRepositoryProvider = Provider<VehicleRepository>((ref) {
  final box = ref.watch(vehicleBoxProvider);
  final supabaseClient = ref.watch(supabaseClientProvider).client;
  final connectivity = ref.watch(connectivityProvider);
  return VehicleRepositoryImpl(box, supabaseClient, connectivity);
});

final saveVehicleUseCaseProvider = Provider<SaveVehicleUseCase>((ref) {
  final repository = ref.watch(vehicleRepositoryProvider);
  return SaveVehicleUseCase(repository);
});

final getVehicleUseCaseProvider = Provider<GetVehicleUseCase>((ref) {
  final repository = ref.watch(vehicleRepositoryProvider);
  return GetVehicleUseCase(repository);
});

final getAllVehiclesUseCaseProvider = Provider<GetAllVehiclesUseCase>((ref) {
  final repository = ref.watch(vehicleRepositoryProvider);
  return GetAllVehiclesUseCase(repository);
});

final deleteVehicleUseCaseProvider = Provider<DeleteVehicleUseCase>((ref) {
  final repository = ref.watch(vehicleRepositoryProvider);
  return DeleteVehicleUseCase(repository);
});

// Add other providers here for global state management, e.g., camera state, user auth, etc.
