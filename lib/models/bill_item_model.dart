// lib/models/bill_item_model.dart

import 'package:hive/hive.dart';

part 'bill_item_model.g.dart'; // We'll generate this file in the next step

@HiveType(typeId: 1)
class BillItemModel {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final double price;

  BillItemModel({required this.name, required this.price});
}