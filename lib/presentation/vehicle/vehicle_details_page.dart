import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/vehicle.dart';
import '../providers.dart';
import 'vehicle_form_page.dart';

class VehicleDetailsPage extends ConsumerStatefulWidget {
  const VehicleDetailsPage({super.key});

  @override
  VehicleDetailsPageState createState() => VehicleDetailsPageState();
}

class VehicleDetailsPageState extends ConsumerState<VehicleDetailsPage> {
  List<Vehicle> _vehicles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    setState(() => _isLoading = true);
    final getAllVehiclesUseCase = ref.read(getAllVehiclesUseCaseProvider);
    final vehicles = await getAllVehiclesUseCase.execute();
    setState(() {
      _vehicles = vehicles;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Vehículos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadVehicles,
            tooltip: 'Actualizar lista',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _vehicles.isEmpty
              ? _buildEmptyState()
              : _buildVehicleList(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFA8DADC),
        foregroundColor: Colors.black,
        onPressed: () => _navigateToForm(null),
        tooltip: 'Agregar vehículo',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF7C4DFF).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.directions_car_outlined,
              size: 80,
              color: Color(0xFF7C4DFF),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No tienes vehículos registrados',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFFE8E8E8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega tu primer vehículo tocando el botón +',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _vehicles.length,
      itemBuilder: (context, index) {
        final vehicle = _vehicles[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF00D9FF).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Card(
            margin: EdgeInsets.zero,
            child: InkWell(
              onTap: () => _showVehicleDetails(vehicle),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00D9FF).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          vehicle.make[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF00D9FF),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${vehicle.make} ${vehicle.model}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Color(0xFFE8E8E8),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF7C4DFF).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  vehicle.licensePlate,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF7C4DFF),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${vehicle.year} • ${vehicle.color}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                          if (vehicle.synced == true)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.cloud_done_rounded,
                                    size: 14,
                                    color: Colors.green[400],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Sincronizado',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.green[400],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF00D9FF)),
                      onSelected: (value) {
                        if (value == 'edit') {
                          _navigateToForm(vehicle);
                        } else if (value == 'delete') {
                          _confirmDelete(vehicle);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_rounded, size: 20, color: Color(0xFF00D9FF)),
                              SizedBox(width: 12),
                              Text('Editar'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_rounded, size: 20, color: Color(0xFFFF5252)),
                              SizedBox(width: 12),
                              Text('Eliminar', style: TextStyle(color: Color(0xFFFF5252))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateToForm(Vehicle? vehicle) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VehicleFormPage(vehicle: vehicle),
      ),
    );
    if (result == true) {
      _loadVehicles();
    }
  }

  void _confirmDelete(Vehicle vehicle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFFF5252), size: 28),
            SizedBox(width: 12),
            Text('Eliminar Vehículo', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar ${vehicle.make} ${vehicle.model} (${vehicle.licensePlate})?\n\nEsta acción no se puede deshacer.',
          style: TextStyle(color: Colors.grey[400], height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteVehicle(vehicle);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5252),
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteVehicle(Vehicle vehicle) async {
    final deleteUseCase = ref.read(deleteVehicleUseCaseProvider);
    await deleteUseCase.execute(vehicle.id!);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehículo eliminado')),
      );
      _loadVehicles();
    }
  }

  void _showVehicleDetails(Vehicle vehicle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF00D9FF).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.directions_car_rounded,
                color: Color(0xFF00D9FF),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${vehicle.make} ${vehicle.model}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailSection(
                'Información del Vehículo',
                [
                  _buildDetailRow('Placa', vehicle.licensePlate),
                  _buildDetailRow('Año', vehicle.year),
                  _buildDetailRow('Color', vehicle.color),
                  _buildDetailRow('VIN', vehicle.vin),
                ],
              ),
              const SizedBox(height: 16),
              _buildDetailSection(
                'Propietario',
                [
                  _buildDetailRow('Nombre', vehicle.ownerName),
                  _buildDetailRow('Teléfono', vehicle.ownerPhone),
                ],
              ),
              if (vehicle.insuranceCompany != null && vehicle.insuranceCompany!.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildDetailSection(
                  'Seguro',
                  [
                    _buildDetailRow('Aseguradora', vehicle.insuranceCompany!),
                    if (vehicle.insurancePolicy != null && vehicle.insurancePolicy!.isNotEmpty)
                      _buildDetailRow('Póliza', vehicle.insurancePolicy!),
                  ],
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToForm(vehicle);
            },
            icon: const Icon(Icons.edit_rounded, size: 18),
            label: const Text('Editar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF00D9FF),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.grey[500],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFFE8E8E8),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
