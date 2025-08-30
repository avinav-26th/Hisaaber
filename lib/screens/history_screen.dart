// In lib/screens/history_screen.dart

import 'package:flutter/material.dart';
import 'package:hisaaber_v1/models/saved_bill_model.dart';
import 'package:hisaaber_v1/providers/history_provider.dart';
import 'package:hisaaber_v1/utils/constants.dart';
import 'package:hisaaber_v1/widgets/bill_list_item.dart';
import 'package:hisaaber_v1/widgets/price_table.dart';
import 'package:provider/provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final historyProvider = context.watch<HistoryProvider>();
    final bills = historyProvider.bills;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.history),
      ),
      body: _buildBody(context, historyProvider, bills),
    );
  }

  Widget _buildBody(BuildContext context, HistoryProvider provider, List<SavedBillModel> bills) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Point 2: Show a sweet message if history is empty
    if (bills.isEmpty) {
      return const Center(
        child: Text(
          'No history yet. Start by scanning a bill!',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    // Point 1: Scrollable list
    return ListView.builder(
      itemCount: bills.length,
      itemBuilder: (context, index) {
        final bill = bills[index];
        // Point 3: Each tile is clickable
        return BillListItem(
          bill: bill,
          onTap: () => _showBillDetailsModal(context, bill),
        );
      },
    );
  }

  // This function shows the popup modal with the bill details
  void _showBillDetailsModal(BuildContext context, SavedBillModel bill) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows the sheet to take up more screen height
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6, // Start at 60% of screen height
          minChildSize: 0.4,   // Can shrink to 40%
          maxChildSize: 0.9,   // Can expand to 90%
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header of the modal
                  Text(
                    bill.customerName,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${AppConstants.total}: ₹${bill.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                  const Divider(height: 24),

                  // The list of items using our reusable widget
                  Expanded(
                    child: PriceTable(items: bill.items),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}