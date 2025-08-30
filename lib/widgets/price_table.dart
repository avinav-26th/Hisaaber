// In lib/widgets/price_table.dart

import 'package:flutter/material.dart';
import 'package:hisaaber_v1/models/bill_item_model.dart';
import 'package:hisaaber_v1/utils/app_colors.dart';
import 'package:hisaaber_v1/utils/constants.dart';

class PriceTable extends StatelessWidget {
  final List<BillItemModel> items;

  const PriceTable({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primaryGrey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Header Row
          _buildRow(
            context,
            leftText: AppConstants.items,
            rightText: AppConstants.price,
            isHeader: true,
          ),
          // Divider
          const Divider(height: 1, color: AppColors.primaryGrey),
          
          // Item List
          Expanded(
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.primaryGrey),
              itemBuilder: (context, index) {
                final item = items[index];
                return _buildRow(
                  context,
                  leftText: item.name,
                  rightText: '₹ ${item.price.toStringAsFixed(2)}',
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget to build a consistent row for the table
  Widget _buildRow(BuildContext context, {required String leftText, required String rightText, bool isHeader = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3, // Give more space to the item name
            child: Text(
              leftText,
              style: TextStyle(
                fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Expanded(
            flex: 1, // Give less space to the price
            child: Text(
              rightText,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}