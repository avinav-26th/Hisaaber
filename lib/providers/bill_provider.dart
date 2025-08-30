// In lib/providers/bill_provider.dart

import 'package:flutter/material.dart';
import 'package:hisaaber_v1/api_services/database_service.dart';
import 'package:hisaaber_v1/api_services/ocr_service.dart';
import 'package:hisaaber_v1/models/bill_item_model.dart';
import 'package:hisaaber_v1/models/saved_bill_model.dart';

class BillProvider with ChangeNotifier {
  // --- SERVICES ---
  final OcrService _ocrService = OcrService();
  final DatabaseService _databaseService = DatabaseService();

  // --- PRIVATE STATE VARIABLES ---
  List<BillItemModel> _items = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _customerName = '';

  // --- GETTERS ---
  List<BillItemModel> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get customerName => _customerName;

  // Calculated getter for the total price
  double get totalPrice {
    double total = 0.0;
    for (var item in _items) {
      total += item.price;
    }
    return total;
  }

  // --- PUBLIC METHODS ---

  /// Processes the image, parses the text, and updates the bill items.
  Future<void> processImageAndParse(String imagePath) async {
    _setLoading(true);
    _clearBill(); // Clear previous bill data

    final rawText = await _ocrService.processImage(imagePath);

    if (rawText != null && rawText.isNotEmpty) {
      _parseOcrText(rawText);
    } else {
      _errorMessage = "Could not read any text from the image. Please try again.";
    }

    _setLoading(false);
  }

  /// Manually adds an item to the current bill.
  void addItem(BillItemModel item) {
    _items.add(item);
    notifyListeners();
  }

  /// Manually removes an item from the current bill.
  void removeItem(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  /// Saves the current bill to the database.
  Future<void> saveBill(String customerName) async {
    if (customerName.isEmpty || _items.isEmpty) {
      _errorMessage = "Customer name or items cannot be empty.";
      notifyListeners();
      return;
    }

    final newBill = SavedBillModel(
      customerName: customerName,
      date: DateTime.now(),
      totalAmount: totalPrice,
      items: _items,
    );

    await _databaseService.saveBill(newBill);
    _clearBill(); // Reset for the next customer
  }

  /// Clears the current bill state.
  void _clearBill() {
    _items = [];
    _errorMessage = null;
    _customerName = '';
    notifyListeners();
  }

  // --- PRIVATE HELPER METHODS ---

  /// Parses the raw text from OCR into a list of BillItemModel.
  void _parseOcrText(String rawText) {
    final List<BillItemModel> parsedItems = [];
    final lines = rawText.split('\n');

    // Regex to find numbers (including decimals) in a string.
    final RegExp priceRegex = RegExp(r'(\d+\.?\d*)\s*$');

    for (var line in lines) {
      if (line.trim().isEmpty) continue;

      final match = priceRegex.firstMatch(line);

      if (match != null) {
        try {
          final String priceString = match.group(1)!;
          final double price = double.parse(priceString);

          // The item name is everything before the price.
          final String name = line.substring(0, match.start).trim();

          if (name.isNotEmpty) {
            parsedItems.add(BillItemModel(name: name, price: price));
          }
        } catch (e) {
          debugPrint("Could not parse line: $line");
        }
      }
    }

    _items = parsedItems;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}