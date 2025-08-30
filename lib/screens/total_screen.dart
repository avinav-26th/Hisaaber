// In lib/screens/total_screen.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hisaaber_v1/providers/bill_provider.dart';
import 'package:hisaaber_v1/screens/home_screen.dart';
import 'package:hisaaber_v1/utils/constants.dart';
import 'package:hisaaber_v1/widgets/price_table.dart';
import 'package:hisaaber_v1/widgets/primary_button.dart';
import 'package:provider/provider.dart';

import '../providers/history_provider.dart';
import '../providers/profile_provider.dart';

// TotalScreen is now a StatelessWidget again!
class TotalScreen extends StatelessWidget {
  const TotalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final billProvider = context.watch<BillProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.total),
      ),
      body: Stack(
        children: [
          // Main content area
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    '${AppConstants.total}: ₹${billProvider.totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Text(
                  'Hisaab List',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: PriceTable(items: billProvider.items),
                ),
                const SizedBox(height: 150),
              ],
            ),
          ),

          // We now use our new, dedicated stateful widget here
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ConfirmAndNameBox(),
          ),
        ],
      ),
    );
  }
}


// This is our new, dedicated StatefulWidget for the bottom section
class ConfirmAndNameBox extends StatefulWidget {
  const ConfirmAndNameBox({super.key});

  @override
  State<ConfirmAndNameBox> createState() => _ConfirmAndNameBoxState();
}

class _ConfirmAndNameBoxState extends State<ConfirmAndNameBox> {
  bool _isNamingStage = false;
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white,
              ],
              stops: const [0.0, 0.5],
            ),
          ),
          child: _isNamingStage ? _buildNamingUI() : _buildConfirmUI(),
        ),
      ),
    );
  }

  Widget _buildConfirmUI() {
    return PrimaryButton(
      text: AppConstants.confirm,
      onPressed: () {
        setState(() {
          _isNamingStage = true;
        });
      },
    );
  }

  Widget _buildNamingUI() {
    return Column(
      children: [
        TextField(
          controller: _nameController,
          autofocus: true,
          decoration: InputDecoration(
            labelText: AppConstants.name,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 16),

        PrimaryButton(
          text: AppConstants.done,
          onPressed: () async { // Make onPressed async
            final customerName = _nameController.text.trim();
            if (customerName.isNotEmpty) {
              final billProvider = context.read<BillProvider>();
              final historyProvider = context.read<HistoryProvider>();
              final profileProvider = context.read<ProfileProvider>();

              // Show a loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(child: CircularProgressIndicator()),
              );

              await billProvider.saveBill(customerName);
              await historyProvider.fetchBills();
              await profileProvider.loadProfile(); // Also refresh profile in case of first bill

              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                      (Route<dynamic> route) => false,
                );
              }
            }
          },
        ),
      ],
    );
  }
}