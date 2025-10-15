import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/vehicle.dart';
import '../providers.dart';

class VehicleFormPage extends ConsumerStatefulWidget {
  final Vehicle? vehicle; // null for new vehicle, populated for editing

  const VehicleFormPage({super.key, this.vehicle});

  @override
  VehicleFormPageState createState() => VehicleFormPageState();
}

class VehicleFormPageState extends ConsumerState<VehicleFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _colorController = TextEditingController();
  final _vinController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _ownerPhoneController = TextEditingController();
  final _insuranceCompanyController = TextEditingController();
  final _insurancePolicyController = TextEditingController();

  // Common Colombian car brands
  final List<String> _colombianCarBrands = [
    'Chevrolet',
    'Renault',
    'Mazda',
    'Kia',
    'Hyundai',
    'Toyota',
    'Nissan',
    'Volkswagen',
    'Ford',
    'BMW',
    'Mercedes-Benz',
    'Audi',
    'Honda',
    'Suzuki',
    'Otro'
  ];

  // Common Colombian insurance companies
  final List<String> _colombianInsuranceCompanies = [
    'Sura',
    'Mapfre',
    'Liberty Seguros',
    'Allianz',
    'Bolívar',
    'Colpatria',
    'Aseguradora Solidaria',
    'AXA Colpatria',
    'Seguros del Estado',
    'Otro'
  ];

  String? _selectedMake;
  String? _selectedInsuranceCompany;

  @override
  void initState() {
    super.initState();
    if (widget.vehicle != null) {
      _populateForm(widget.vehicle!);
    }
  }

  void _populateForm(Vehicle vehicle) {
    _makeController.text = vehicle.make;
    _modelController.text = vehicle.model;
    _yearController.text = vehicle.year;
    _licensePlateController.text = vehicle.licensePlate;
    _colorController.text = vehicle.color;
    _vinController.text = vehicle.vin;
    _ownerNameController.text = vehicle.ownerName;
    _ownerPhoneController.text = vehicle.ownerPhone;
    _insuranceCompanyController.text = vehicle.insuranceCompany ?? '';
    _insurancePolicyController.text = vehicle.insurancePolicy ?? '';

    _selectedMake = vehicle.make;
    _selectedInsuranceCompany = vehicle.insuranceCompany;
  }

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _licensePlateController.dispose();
    _colorController.dispose();
    _vinController.dispose();
    _ownerNameController.dispose();
    _ownerPhoneController.dispose();
    _insuranceCompanyController.dispose();
    _insurancePolicyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.vehicle != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Vehículo' : 'Agregar Vehículo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                initialValue: _selectedMake,
                decoration: const InputDecoration(labelText: 'Marca'),
                items: _colombianCarBrands.map((String brand) {
                  return DropdownMenuItem<String>(
                    value: brand,
                    child: Text(brand),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedMake = newValue;
                    _makeController.text = newValue ?? '';
                  });
                },
                validator: (value) => (value == null || value.isEmpty) ? 'Requerido' : null,
              ),
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(labelText: 'Modelo'),
                validator: (value) => (value == null || value.isEmpty) ? 'Requerido' : null,
              ),
              TextFormField(
                controller: _yearController,
                decoration: const InputDecoration(labelText: 'Año'),
                keyboardType: TextInputType.number,
                validator: (value) => (value == null || value.isEmpty) ? 'Requerido' : null,
              ),
              TextFormField(
                controller: _licensePlateController,
                decoration: const InputDecoration(labelText: 'Placa'),
                validator: (value) => (value == null || value.isEmpty) ? 'Requerido' : null,
              ),
              TextFormField(
                controller: _colorController,
                decoration: const InputDecoration(labelText: 'Color'),
                validator: (value) => (value == null || value.isEmpty) ? 'Requerido' : null,
              ),
              TextFormField(
                controller: _vinController,
                decoration: const InputDecoration(labelText: 'Número de Serie (VIN)'),
                validator: (value) => (value == null || value.isEmpty) ? 'Requerido' : null,
              ),
              TextFormField(
                controller: _ownerNameController,
                decoration: const InputDecoration(labelText: 'Nombre del Propietario'),
                validator: (value) => (value == null || value.isEmpty) ? 'Requerido' : null,
              ),
              TextFormField(
                controller: _ownerPhoneController,
                decoration: const InputDecoration(labelText: 'Teléfono del Propietario'),
                keyboardType: TextInputType.phone,
                validator: (value) => (value == null || value.isEmpty) ? 'Requerido' : null,
              ),
              DropdownButtonFormField<String>(
                initialValue: _selectedInsuranceCompany,
                decoration: const InputDecoration(labelText: 'Compañía de Seguros'),
                items: _colombianInsuranceCompanies.map((String company) {
                  return DropdownMenuItem<String>(
                    value: company,
                    child: Text(company),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedInsuranceCompany = newValue;
                    _insuranceCompanyController.text = newValue ?? '';
                  });
                },
              ),
              TextFormField(
                controller: _insurancePolicyController,
                decoration: const InputDecoration(labelText: 'Póliza de Seguro'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveVehicle,
                child: Text(isEditing ? 'Actualizar Vehículo' : 'Guardar Vehículo'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveVehicle() async {
    if (_formKey.currentState?.validate() ?? false) {
      final vehicle = Vehicle(
        id: widget.vehicle?.id ?? _uuid.v4(),
        make: _makeController.text,
        model: _modelController.text,
        year: _yearController.text,
        licensePlate: _licensePlateController.text,
        color: _colorController.text,
        vin: _vinController.text,
        ownerName: _ownerNameController.text,
        ownerPhone: _ownerPhoneController.text,
        insuranceCompany: _insuranceCompanyController.text,
        insurancePolicy: _insurancePolicyController.text,
        createdAt: widget.vehicle?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final saveUseCase = ref.read(saveVehicleUseCaseProvider);
      await saveUseCase.execute(vehicle);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.vehicle != null 
                ? 'Vehículo actualizado exitosamente'
                : 'Vehículo guardado exitosamente'
            ),
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    }
  }
}
