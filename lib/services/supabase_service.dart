import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/vehicle.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Get all vehicles
  static Future<List<Vehicle>> getVehicles() async {
    try {
      final response = await _client
          .from('vehicles')
          .select()
          .order('created_at', ascending: false);
      
      return (response as List)
          .map((json) => Vehicle.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error fetching vehicles: $e');
    }
  }

  // Add a new vehicle
  static Future<Vehicle> addVehicle(Vehicle vehicle) async {
    try {
      final response = await _client
          .from('vehicles')
          .insert(vehicle.toJson())
          .select()
          .single();
      
      return Vehicle.fromJson(response);
    } catch (e) {
      throw Exception('Error adding vehicle: $e');
    }
  }

  // Update a vehicle
  static Future<Vehicle> updateVehicle(Vehicle vehicle) async {
    try {
      final response = await _client
          .from('vehicles')
          .update(vehicle.toJson())
          .eq('id', vehicle.id!)
          .select()
          .single();
      
      return Vehicle.fromJson(response);
    } catch (e) {
      throw Exception('Error updating vehicle: $e');
    }
  }

  // Delete a vehicle
  static Future<void> deleteVehicle(String id) async {
    try {
      await _client
          .from('vehicles')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Error deleting vehicle: $e');
    }
  }

  // Get vehicle by VIN
  static Future<Vehicle?> getVehicleByVin(String vin) async {
    try {
      final response = await _client
          .from('vehicles')
          .select()
          .eq('vin', vin)
          .maybeSingle();
      
      return response != null ? Vehicle.fromJson(response) : null;
    } catch (e) {
      throw Exception('Error fetching vehicle by VIN: $e');
    }
  }
}
