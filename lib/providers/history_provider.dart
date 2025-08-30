// In lib/providers/history_provider.dart

import 'package:flutter/material.dart';
import 'package:hisaaber_v1/api_services/database_service.dart';
import 'package:hisaaber_v1/models/saved_bill_model.dart';

class HistoryProvider with ChangeNotifier {
  // --- SERVICE ---
  final DatabaseService _databaseService = DatabaseService();

  // --- PRIVATE STATE VARIABLES ---
  List<SavedBillModel> _bills = [];
  bool _isLoading = false;

  // --- GETTERS ---
  List<SavedBillModel> get bills => _bills;
  bool get isLoading => _isLoading;

  // --- CONSTRUCTOR ---
  HistoryProvider() {
    // Fetch bills as soon as the provider is created
    fetchBills();
  }

  // --- PUBLIC METHODS ---

  /// Fetches all saved bills from the local database.
  Future<void> fetchBills() async {
    _isLoading = true;
    notifyListeners();

    // Get the list of bills from our database service
    _bills = await _databaseService.getBills();

    // Sort the bills to show the most recent one first
    _bills.sort((a, b) => b.date.compareTo(a.date));

    _isLoading = false;
    notifyListeners();
  }

  /// Deletes a specific bill and refreshes the list.
  Future<void> deleteBill(String billId) async {
    await _databaseService.deleteBill(billId);
    
    // After deleting, fetch the updated list to refresh the UI
    await fetchBills();
  }
}