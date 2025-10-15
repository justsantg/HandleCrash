// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle.dart';

// **************************************************************************
/// TypeAdapterGenerator
// **************************************************************************

class VehicleAdapter extends TypeAdapter<Vehicle> {
  @override
  final int typeId = 0;

  @override
  Vehicle read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Vehicle(
      id: fields[0] as String?,
      make: fields[1] as String,
      model: fields[2] as String,
      year: fields[3] as String,
      licensePlate: fields[4] as String,
      color: fields[5] as String,
      vin: fields[6] as String,
      ownerName: fields[7] as String,
      ownerPhone: fields[8] as String,
      insuranceCompany: fields[9] as String?,
      insurancePolicy: fields[10] as String?,
      createdAt: fields[11] as DateTime?,
      updatedAt: fields[12] as DateTime?,
      synced: fields[13] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Vehicle obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.make)
      ..writeByte(2)
      ..write(obj.model)
      ..writeByte(3)
      ..write(obj.year)
      ..writeByte(4)
      ..write(obj.licensePlate)
      ..writeByte(5)
      ..write(obj.color)
      ..writeByte(6)
      ..write(obj.vin)
      ..writeByte(7)
      ..write(obj.ownerName)
      ..writeByte(8)
      ..write(obj.ownerPhone)
      ..writeByte(9)
      ..write(obj.insuranceCompany)
      ..writeByte(10)
      ..write(obj.insurancePolicy)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.updatedAt)
      ..writeByte(13)
      ..write(obj.synced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VehicleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
