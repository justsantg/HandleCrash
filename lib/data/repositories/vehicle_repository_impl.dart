import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/vehicle.dart';
import '../../domain/repositories/vehicle_repository.dart';

class VehicleRepositoryImpl implements VehicleRepository {
  final Box<Vehicle> _localBox;
  final SupabaseClient _supabaseClient;
  final Connectivity _connectivity;

  VehicleRepositoryImpl(this._localBox, this._supabaseClient, this._connectivity);

  @override
  Future<void> saveVehicle(Vehicle vehicle) async {
    // Get current user ID
    final userId = _supabaseClient.auth.currentUser?.id;
    
    // Add user_id to vehicle if not already set
    final vehicleToSave = vehicle.userId == null && userId != null
        ? vehicle.copyWith(userId: userId)
        : vehicle;
    
    // Save locally first
    await _localBox.put(vehicleToSave.id ?? vehicleToSave.vin, vehicleToSave);

    // Try to sync if online
    final connectivityResults = await _connectivity.checkConnectivity();
    if (connectivityResults != ConnectivityResult.none) {
      await _syncVehicleToSupabase(vehicleToSave);
    }
  }
  
  @override
  Future<Vehicle?> getVehicle(String id) async {
    return _localBox.get(id);
  }

  @override
  Future<List<Vehicle>> getAllVehicles() async {
    // Primero intenta sincronizar desde Supabase si hay conexión
    final connectivityResults = await _connectivity.checkConnectivity();
    if (connectivityResults != ConnectivityResult.none) {
      try {
        // Get current user ID
        final userId = _supabaseClient.auth.currentUser?.id;
        
        if (userId != null) {
          // Fetch only vehicles for the current user
          final response = await _supabaseClient
              .from('vehicles')
              .select()
              .eq('user_id', userId)
              .order('created_at', ascending: false);
          
          // Guardar vehículos de Supabase en Hive
          for (final vehicleJson in response) {
            final vehicle = Vehicle.fromJson(vehicleJson).copyWith(synced: true);
            await _localBox.put(vehicle.id ?? vehicle.vin, vehicle);
          }
        }
      } catch (e) {
        print('Error fetching vehicles from Supabase: $e');
        // Continuar con los vehículos locales si falla
      }
    }
    
    // Retornar todos los vehículos de Hive (que ahora incluyen los de Supabase)
    // Filtrar por user_id si existe
    final userId = _supabaseClient.auth.currentUser?.id;
    if (userId != null) {
      return _localBox.values.where((v) => v.userId == userId).toList();
    }
    return _localBox.values.toList();
  }

  @override
  Future<void> deleteVehicle(String id) async {
    await _localBox.delete(id);

    // Try to delete from Supabase if online
    final connectivityResults = await _connectivity.checkConnectivity();
    if (connectivityResults != ConnectivityResult.none) {
      try {
        await _supabaseClient.from('vehicles').delete().eq('id', id);
      } catch (e) {
        print('Error deleting vehicle from Supabase: $e');
        // TODO: Implement proper logging
      }
    }
  }

  @override
  Future<void> syncVehicles() async {
    final connectivityResults = await _connectivity.checkConnectivity();
    if (connectivityResults == ConnectivityResult.none) return;

    final unsyncedVehicles = _localBox.values.where((v) => v.synced != true).toList();

    for (final vehicle in unsyncedVehicles) {
      await _syncVehicleToSupabase(vehicle);
    }
  }

  Future<void> _syncVehicleToSupabase(Vehicle vehicle) async {
    try {
      final vehicleData = vehicle.toJson();
      // Remove null id for insert operations
      if (vehicleData['id'] == null) {
        vehicleData.remove('id');
      }
      
      final response = await _supabaseClient
          .from('vehicles')
          .upsert(vehicleData)
          .select()
          .single();
      
      final updatedVehicle = Vehicle.fromJson(response).copyWith(synced: true);
      await _localBox.put(updatedVehicle.id ?? vehicle.vin, updatedVehicle);
    } catch (e) {
      print('Error syncing vehicle to Supabase: $e');
      // TODO: Implement proper logging and retry mechanism
    }
  }
}
