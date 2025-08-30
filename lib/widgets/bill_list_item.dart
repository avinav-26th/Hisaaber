// In lib/widgets/bill_list_item.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hisaaber_v1/models/saved_bill_model.dart';
import 'package:hisaaber_v1/utils/app_colors.dart';
import 'package:intl/intl.dart';

class BillListItem extends StatelessWidget {
  final SavedBillModel bill;
  final VoidCallback? onTap;
  final bool isPinned;
  final VoidCallback? onPinToggle;

  const BillListItem({
    Key? key,
    required this.bill,
    this.onTap,
    this.isPinned = false,
    this.onPinToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd-MM-yy').format(bill.date);
    final formattedTime = DateFormat('hh:mm a').format(bill.date);

    // The Stack widget allows us to layer widgets on top of each other.
    return Stack(
      clipBehavior: Clip.none, // Allows the pin to stick out of the card's bounds
      children: [
        // This is our main bill card from before
        GestureDetector(
          onTap: onTap,
          onLongPress: onPinToggle,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            padding: const EdgeInsets.fromLTRB(24, 16, 16, 16),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bill.customerName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$formattedDate $formattedTime',
                      style: TextStyle(
                        color: Colors.black.withAlpha((255 * 0.6).round()),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Text(
                  '₹ ${bill.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
        ),

        // This is the new Pin IconButton, positioned on top
        Positioned(
          top: 8,
          right: 12,
          child: IconButton(
            icon: Transform.rotate(
              angle: pi / 4,
              child: Icon(
                // The ICON changes based on the 'isPinned' status
                isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                // The COLOR also changes
                color: isPinned ? Colors.blueAccent : Colors.black54,
              ),
            ),
            onPressed: onPinToggle,
          ),
        ),
      ],
    );
  }
}