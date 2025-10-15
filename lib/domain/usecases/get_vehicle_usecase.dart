import '../models/vehicle.dart';
import '../repositories/vehicle_repository.dart';

class GetVehicleUseCase {
  final VehicleRepository repository;

  GetVehicleUseCase(this.repository);

  Future<Vehicle?> execute(String id) async {
    return repository.getVehicle(id);
  }
}

class GetAllVehiclesUseCase {
  final VehicleRepository repository;

  GetAllVehiclesUseCase(this.repository);

  Future<List<Vehicle>> execute() async {
    return repository.getAllVehicles();
  }
}
