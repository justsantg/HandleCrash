class Vehicle {
  final String? id;
  final String make;
  final String model;
  final String year;
  final String licensePlate;
  final String color;
  final String vin;
  final String ownerName;
  final String ownerPhone;
  final String? insuranceCompany;
  final String? insurancePolicy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? synced;

  Vehicle({
    this.id,
    required this.make,
    required this.model,
    required this.year,
    required this.licensePlate,
    required this.color,
    required this.vin,
    required this.ownerName,
    required this.ownerPhone,
    this.insuranceCompany,
    this.insurancePolicy,
    this.createdAt,
    this.updatedAt,
    this.synced,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'],
      make: json['make'],
      model: json['model'],
      year: json['year'],
      licensePlate: json['license_plate'],
      color: json['color'],
      vin: json['vin'],
      ownerName: json['owner_name'],
      ownerPhone: json['owner_phone'],
      insuranceCompany: json['insurance_company'],
      insurancePolicy: json['insurance_policy'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      synced: json['synced'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'make': make,
      'model': model,
      'year': year,
      'license_plate': licensePlate,
      'color': color,
      'vin': vin,
      'owner_name': ownerName,
      'owner_phone': ownerPhone,
      'insurance_company': insuranceCompany,
      'insurance_policy': insurancePolicy,
      'synced': synced,
    };
  }

  Vehicle copyWith({
    String? id,
    String? make,
    String? model,
    String? year,
    String? licensePlate,
    String? color,
    String? vin,
    String? ownerName,
    String? ownerPhone,
    String? insuranceCompany,
    String? insurancePolicy,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? synced,
  }) {
    return Vehicle(
      id: id ?? this.id,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      licensePlate: licensePlate ?? this.licensePlate,
      color: color ?? this.color,
      vin: vin ?? this.vin,
      ownerName: ownerName ?? this.ownerName,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      insuranceCompany: insuranceCompany ?? this.insuranceCompany,
      insurancePolicy: insurancePolicy ?? this.insurancePolicy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      synced: synced ?? this.synced,
    );
  }
}
