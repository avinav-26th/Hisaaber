import 'package:hive/hive.dart';
import 'bill_item_model.dart'; // Import the item model

// This line is new
part 'saved_bill_model.g.dart';

@HiveType(typeId: 0) // Unique ID for this class
class SavedBillModel {
  @HiveField(0)
  final String customerName;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final double totalAmount;

  @HiveField(3)
  final List<BillItemModel> items; // Hive can store lists of custom objects!

  SavedBillModel({
    required this.customerName,
    required this.date,
    required this.totalAmount,
    required this.items,
  });
}