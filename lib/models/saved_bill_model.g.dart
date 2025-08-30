// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_bill_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SavedBillModelAdapter extends TypeAdapter<SavedBillModel> {
  @override
  final int typeId = 0;

  @override
  SavedBillModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavedBillModel(
      customerName: fields[0] as String,
      date: fields[1] as DateTime,
      totalAmount: fields[2] as double,
      items: (fields[3] as List).cast<BillItemModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, SavedBillModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.customerName)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.totalAmount)
      ..writeByte(3)
      ..write(obj.items);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedBillModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
