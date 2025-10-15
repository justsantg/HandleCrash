import 'package:hive/hive.dart';

part 'vehicle.g.dart';

@HiveType(typeId: 0)
class Vehicle {
  @HiveField(0)
  final String? id;
  @HiveField(1)
  final String make;
  @HiveField(2)
  final String model;
  @HiveField(3)
  final String year;
  @HiveField(4)
  final String licensePlate;
  @HiveField(5)
  final String color;
  @HiveField(6)
  final String vin;
  @HiveField(7)
  final String ownerName;
  @HiveField(8)
  final String ownerPhone;
  @HiveField(9)
  final String? insuranceCompany;
  @HiveField(10)
  final String? insurancePolicy;
  @HiveField(11)
  final DateTime? createdAt;
  @HiveField(12)
  final DateTime? updatedAt;
  @HiveField(13)
  final bool synced;
  @HiveField(14)
  final String? userId; // ID del usuario propietario

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
    this.synced = false,
    this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'make': make,
      'model': model,
      'year': year,
      'license_plate': licensePlate,
      'color': color,
      'vin': vin,
      'owner_name': ownerName,
      'owner_phone': ownerPhone,
      if (insuranceCompany != null) 'insurance_company': insuranceCompany,
      if (insurancePolicy != null) 'insurance_policy': insurancePolicy,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      'synced': synced,
      if (userId != null) 'user_id': userId,
    };
  }

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'],
      make: json['make'] ?? '',
      model: json['model'] ?? '',
      year: json['year'] ?? '',
      licensePlate: json['license_plate'] ?? '',
      color: json['color'] ?? '',
      vin: json['vin'] ?? '',
      ownerName: json['owner_name'] ?? '',
      ownerPhone: json['owner_phone'] ?? '',
      insuranceCompany: json['insurance_company'],
      insurancePolicy: json['insurance_policy'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      synced: json['synced'] ?? false,
      userId: json['user_id'],
    );
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
    String? userId,
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
      userId: userId ?? this.userId,
    );
  }
}