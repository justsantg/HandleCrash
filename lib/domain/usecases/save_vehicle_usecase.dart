import '../models/vehicle.dart';
import '../repositories/vehicle_repository.dart';

class SaveVehicleUseCase {
  final VehicleRepository repository;

  SaveVehicleUseCase(this.repository);

  Future<void> execute(Vehicle vehicle) async {
    return repository.saveVehicle(vehicle);
  }
}
