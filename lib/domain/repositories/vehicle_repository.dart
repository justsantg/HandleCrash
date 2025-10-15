import '../models/vehicle.dart';

abstract class VehicleRepository {
  Future<void> saveVehicle(Vehicle vehicle);
  Future<Vehicle?> getVehicle(String id);
  Future<List<Vehicle>> getAllVehicles();
  Future<void> deleteVehicle(String id);
  Future<void> syncVehicles();
}
