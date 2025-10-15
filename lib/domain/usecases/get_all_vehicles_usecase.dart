import '../models/vehicle.dart';
import '../repositories/vehicle_repository.dart';

class GetAllVehiclesUseCase {
  final VehicleRepository repository;

  GetAllVehiclesUseCase(this.repository);

  Future<List<Vehicle>> execute() async {
    return await repository.getAllVehicles();
  }
}
