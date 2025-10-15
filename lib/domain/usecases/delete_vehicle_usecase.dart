import '../repositories/vehicle_repository.dart';

class DeleteVehicleUseCase {
  final VehicleRepository _repository;

  DeleteVehicleUseCase(this._repository);

  Future<void> execute(String id) async {
    return await _repository.deleteVehicle(id);
  }
}
