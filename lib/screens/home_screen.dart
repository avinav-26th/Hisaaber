// In lib/screens/home_screen.dart

// import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider; // <-- FIX 1: Hide the conflicting class
import 'package:flutter/material.dart';
// import 'package:hisaaber_v1/api_services/database_service.dart';
import 'package:hisaaber_v1/models/saved_bill_model.dart';
import 'package:hisaaber_v1/providers/auth_provider.dart';
import 'package:hisaaber_v1/providers/history_provider.dart';
import 'package:hisaaber_v1/providers/profile_provider.dart';
import 'package:hisaaber_v1/screens/goodbye_screen.dart';
import 'package:hisaaber_v1/screens/history_screen.dart';
import 'package:hisaaber_v1/screens/scanner_screen.dart';
import 'package:hisaaber_v1/utils/constants.dart';
import 'package:hisaaber_v1/widgets/bill_list_item.dart';
import 'package:hisaaber_v1/widgets/price_table.dart';
import 'package:hisaaber_v1/widgets/primary_button.dart';
import 'package:hisaaber_v1/widgets/profile/edit_profile_modal.dart';
import 'package:provider/provider.dart';

import '../api_services/database_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});


  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<SavedBillModel> _visibleRecentBills;
  final ScrollController _scrollController = ScrollController();
  bool _showScrollIndicator = false;
  SavedBillModel? _lastDismissedBill;
  int? _lastDismissedIndex;
  final DatabaseService _databaseService = DatabaseService();
  List<String> _pinnedBillIds = [];

  @override
  void initState() {
    super.initState();
    _loadPinnedBillsAndInitialize();
    _initializeVisibleBills();


    // This checks if the list is scrollable AFTER it has been built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ADD THIS CHECK: Only access the controller if it's attached to a list
      if (_scrollController.hasClients && _scrollController.position.maxScrollExtent > 0) {
        if (mounted) {
          setState(() {
            _showScrollIndicator = true;
          });
        }
      }
    });

    // This listener will hide the arrow as soon as the user scrolls
    _scrollController.addListener(() {
      // Check if the current scroll position is less than the maximum
      final bool shouldShow = _scrollController.position.pixels < _scrollController.position.maxScrollExtent;

      // Only call setState if the visibility needs to change
      if (shouldShow != _showScrollIndicator) {
        setState(() {
          _showScrollIndicator = shouldShow;
        });
      }
    });
  }

  @override
  void dispose() {
    // Always dispose of controllers to prevent memory leaks
    _scrollController.dispose();
    super.dispose();
  }

  // New method to load pinned IDs
  Future<void> _loadPinnedBillsAndInitialize() async {
    _pinnedBillIds = await _databaseService.getPinnedBillIds();
    _initializeVisibleBills();
    setState(() {}); // Update UI after loading
  }

// New method to handle the pin toggle action
  void _togglePinStatus(String billId) {
    setState(() {
      if (_pinnedBillIds.contains(billId)) {
        _pinnedBillIds.remove(billId);
        _databaseService.removePinnedBillId(billId);
      } else {
        if (_pinnedBillIds.length < 5) {
          _pinnedBillIds.add(billId);
          _databaseService.addPinnedBillId(billId);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You can only pin up to 5 bills.')),
          );
        }
      }
      _initializeVisibleBills(); // Re-sort the list
    });
  }

  void _initializeVisibleBills() {
    final allBills = context.read<HistoryProvider>().bills;

    final pinnedBills = _pinnedBillIds.map((id) {
      return allBills.firstWhere((bill) => bill.date.toIso8601String() == id);
    }).toList();

    final recentUnpinnedBills = allBills.where((bill) {
      return !_pinnedBillIds.contains(bill.date.toIso8601String());
    }).toList();

    _visibleRecentBills = [...pinnedBills, ...recentUnpinnedBills.take(20 - pinnedBills.length)];
  }

  // --- Helper Methods for Modals ---

  // void _showProfileMenu(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (context) {
  //       return Wrap(
  //         children: <Widget>[
  //           ListTile(
  //             leading: const Icon(Icons.edit_outlined),
  //             title: const Text('Edit Profile'),
  //             onTap: () {
  //               Navigator.pop(context);
  //               _showEditProfileModal(context);
  //             },
  //           ),
  //           ListTile(
  //             leading: const Icon(Icons.logout, color: Colors.red),
  //             title: const Text(
  //               'Sign Out',
  //               style: TextStyle(color: Colors.red),
  //             ),
  //             onTap: () {
  //               Navigator.pop(context);
  //               context.read<AuthProvider>().signOut();
  //               Navigator.of(context).pushAndRemoveUntil(
  //                 MaterialPageRoute(
  //                   builder: (context) => const GoodByeScreen(),
  //                 ),
  //                     (_) => false,
  //               );
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  void _showEditProfileModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const EditProfileModal(),
      ),
    );
  }

  void _showBillDetailsModal(BuildContext context, SavedBillModel bill) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bill.customerName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${AppConstants.total}: ₹${bill.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                  const Divider(height: 24),
                  Expanded(child: PriceTable(items: bill.items)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- Helper for Greeting Message ---
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    }
    if (hour < 17) {
      return 'Good Afternoon';
    }
    if (hour < 21) {
      return 'Good Evening';
    }
    return 'Good Night';
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Builder(
            builder: (context) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'हिसाबer',
                    style: TextStyle(
                      fontSize: 26, // Larger font size
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).appBarTheme.titleTextStyle?.color,
                    ),
                  ),
                  Text(
                    'do your हिसाब in seconds',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              );
            }
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_outlined, size: 30,),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            },
          ),
          // IconButton(
          //   icon: const Icon(Icons.sync),
          //   onPressed: () async {
          //     final scaffoldMessenger = ScaffoldMessenger.of(context);
          //     final dbService = DatabaseService();
          //
          //     await dbService.syncAllBillsToFirestore();
          //
          //     scaffoldMessenger.showSnackBar(
          //       const SnackBar(content: Text('Data synced to cloud!')),
          //     );
          //   },
          // ),
          // In lib/screens/home_screen.dart -> build method -> AppBar -> actions

          Consumer<ProfileProvider>(
            builder: (context, profileProvider, child) {
              final profile = profileProvider.userProfile;
              return PopupMenuButton<String>(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                // 1. Make the onSelected callback async
                onSelected: (value) async {
                  if (value == 'edit_profile') {
                    _showEditProfileModal(context);
                  } else if (value == 'sign_out') {
                    // 2. Capture the Navigator before the await
                    final navigator = Navigator.of(context);
                    final authProvider = context.read<AuthProvider>();

                    // 3. Await the sign out process to ensure it completes
                    await authProvider.signOut();

                    // 4. Use the captured navigator to navigate
                    navigator.pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const GoodByeScreen()),
                          (_) => false,
                    );
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'edit_profile',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, color: Colors.black),
                        SizedBox(width: 8),
                        Text('Edit Profile'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem<String>(
                    value: 'sign_out',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Sign Out', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: (profile != null)
                      ? CircleAvatar(
                    radius: 18,
                    backgroundImage:
                    AssetImage('assets/avatars/${profile.avatarId}.png'),
                  )
                      : const Icon(Icons.person_outline, size: 30),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Consumer<ProfileProvider>(
              builder: (context, profileProvider, child) {
                if (profileProvider.isLoading) {
                  return const SizedBox(height: 28);
                }
                if (profileProvider.userProfile != null) {
                  final userName = profileProvider.userProfile!.name;
                  return Text(
                    '${_getGreeting()}, $userName!',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }
                return const SizedBox(height: 28);
              },
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: PrimaryButton(
              text: AppConstants.scanButton,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ScannerScreen(),
                  ),
                );
              },
              borderRadius: 20,      // More rounded corners
              verticalPadding: 22,   // Taller button
              fontSize: 24,          // Bigger text
              width: MediaQuery.of(context).size.width * 0.6, // Shorter width
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(
              AppConstants.recentHisaab,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _visibleRecentBills.isEmpty
                ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Text(
                  "Scan to get your first ${AppConstants.recentHisaab}!",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black.withAlpha((255 * 0.6).round()),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
                : RefreshIndicator(
              onRefresh: () async {
                await context.read<HistoryProvider>().fetchBills();
                setState(() {
                  _initializeVisibleBills();
                });
              },
              // FIX 1: The Stack widget needs to be the child of RefreshIndicator
              child: Stack(
                children: [
                  ListView.builder(
                    // FIX 2: Connect the controller to the ListView
                    controller: _scrollController,
                    itemCount: _visibleRecentBills.length,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final bill = _visibleRecentBills[index];
                      final billId = bill.date.toIso8601String();
                      final isPinned = _pinnedBillIds.contains(billId);
                      return Dismissible(
                        key: Key(bill.date.toIso8601String()),
                        direction: DismissDirection.startToEnd,
                        // In _HomeScreenState -> build method -> ListView.builder -> Dismissible

                        onDismissed: (direction) {
                          // Store the bill and its index before removing
                          _lastDismissedIndex = index;
                          _lastDismissedBill = _visibleRecentBills[index];

                          // Remove the item from the list to update the UI
                          setState(() {
                            _visibleRecentBills.removeAt(index);
                          });

                          // Clear any previous SnackBars
                          ScaffoldMessenger.of(context).clearSnackBars();

                          // Show a new SnackBar with an Undo button
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${_lastDismissedBill!.customerName}\'s bill hidden'),
                              action: SnackBarAction(
                                label: 'Undo',
                                onPressed: () {
                                  // If Undo is pressed, re-insert the bill at its original position
                                  if (_lastDismissedBill != null && _lastDismissedIndex != null) {
                                    setState(() {
                                      _visibleRecentBills.insert(_lastDismissedIndex!, _lastDismissedBill!);
                                    });
                                  }
                                },
                              ),
                            ),
                          );
                        },
                        background: Container(
                          color: Colors.grey.shade400,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.visibility_off_outlined,
                              color: Colors.white),
                        ),
                        child: BillListItem(
                          bill: bill,
                          onTap: () => _showBillDetailsModal(context, bill),
                          isPinned: isPinned, // <-- PASS PIN STATUS
                          onPinToggle: () => _togglePinStatus(billId), // <-- PASS TOGGLE FUNCTION
                        ),
                      );
                    },
                  ),
                  // This is the smart indicator logic we built before
                  if (_showScrollIndicator)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: IgnorePointer(
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withAlpha(0),
                                Colors.white,
                              ],
                              stops: const [0.0, 0.9],
                            ),
                          ),
                          child: const Icon(
                            Icons.keyboard_arrow_down,
                            size: 40,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}




// import 'package:flutter/material.dart';
// import 'package:hisaaber_v1/api_services/database_service.dart';
// import 'package:hisaaber_v1/models/saved_bill_model.dart';
// import 'package:hisaaber_v1/providers/auth_provider.dart';
// import 'package:hisaaber_v1/providers/history_provider.dart';
// import 'package:hisaaber_v1/screens/goodbye_screen.dart';
// import 'package:hisaaber_v1/screens/history_screen.dart';
// import 'package:hisaaber_v1/screens/scanner_screen.dart';
// import 'package:hisaaber_v1/utils/constants.dart';
// import 'package:hisaaber_v1/widgets/bill_list_item.dart';
// import 'package:hisaaber_v1/widgets/price_table.dart';
// import 'package:hisaaber_v1/widgets/primary_button.dart';
// import 'package:hisaaber_v1/widgets/profile/edit_profile_modal.dart';
// import 'package:provider/provider.dart';
//
// import '../providers/profile_provider.dart';
//
// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});
//
//   // --- Helper Methods for Modals ---
//
//   void _showProfileMenu(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) {
//         return Wrap(
//           children: <Widget>[
//             ListTile(
//               leading: const Icon(Icons.edit_outlined),
//               title: const Text('Edit Profile'),
//               onTap: () {
//                 Navigator.pop(context);
//                 _showEditProfileModal(context);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.logout, color: Colors.red),
//               title: const Text(
//                 'Sign Out',
//                 style: TextStyle(color: Colors.red),
//               ),
//               onTap: () {
//                 Navigator.pop(context);
//                 context.read<AuthProvider>().signOut();
//                 Navigator.of(context).pushAndRemoveUntil(
//                   MaterialPageRoute(
//                     builder: (context) => const GoodByeScreen(),
//                   ),
//                   (_) => false,
//                 );
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _showEditProfileModal(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Padding(
//         padding: EdgeInsets.only(
//           bottom: MediaQuery.of(context).viewInsets.bottom,
//         ),
//         child: const EditProfileModal(),
//       ),
//     );
//   }
//
//   void _showBillDetailsModal(BuildContext context, SavedBillModel bill) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return DraggableScrollableSheet(
//           expand: false,
//           initialChildSize: 0.6,
//           minChildSize: 0.4,
//           maxChildSize: 0.9,
//           builder: (context, scrollController) {
//             return Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     bill.customerName,
//                     style: const TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     '${AppConstants.total}: ₹${bill.totalAmount.toStringAsFixed(2)}',
//                     style: const TextStyle(fontSize: 18, color: Colors.black54),
//                   ),
//                   const Divider(height: 24),
//                   Expanded(child: PriceTable(items: bill.items)),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
//
//   // --- Helper for Greeting Message ---
//
//   String _getGreeting() {
//     final hour = DateTime.now().hour;
//     if (hour < 12) {
//       return 'Good Morning';
//     }
//     if (hour < 17) {
//       return 'Good Afternoon';
//     }
//     if (hour < 21) {
//       return 'Good Evening';
//     }
//     return 'Good Night';
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final historyProvider = context.watch<HistoryProvider>();
//     final bills = historyProvider.bills;
//     final ScrollController scrollController = ScrollController();
//     final bool isScrollable = bills.length > 5;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           AppConstants.appName,
//           style: Theme.of(context).appBarTheme.titleTextStyle,
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.history_outlined),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => const HistoryScreen()),
//               );
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.sync),
//             onPressed: () async {
//               // Capture the ScaffoldMessenger BEFORE the await
//               final scaffoldMessenger = ScaffoldMessenger.of(context);
//               final dbService = DatabaseService();
//
//               // The async gap
//               await dbService.syncAllBillsToFirestore();
//
//               // Use the captured variable AFTER the await
//               scaffoldMessenger.showSnackBar(
//                 const SnackBar(content: Text('Data synced to cloud!')),
//               );
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.person_outline),
//             onPressed: () => _showProfileMenu(context),
//           ),
//         ],
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Greeting Message Widget
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0),
//             child: Consumer<ProfileProvider>(
//               builder: (context, profileProvider, child) {
//                 if (profileProvider.isLoading) {
//                   return const SizedBox(height: 28); // Placeholder while loading
//                 }
//                 if (profileProvider.userProfile != null) {
//                   final userName = profileProvider.userProfile!.name;
//                   return Text(
//                     '${_getGreeting()}, $userName!',
//                     style: const TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   );
//                 }
//                 return const SizedBox(height: 28); // Return empty if no profile
//               },
//             ),
//           ),
//           const SizedBox(height: 16),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0),
//             child: PrimaryButton(
//               text: AppConstants.scanButton,
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => const ScannerScreen(),
//                   ),
//                 );
//               },
//             ),
//           ),
//           const SizedBox(height: 24),
//           Padding(
//             padding: const EdgeInsets.only(left: 16.0),
//             child: Text(
//               AppConstants.recentHisaab,
//               style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//           ),
//           const SizedBox(height: 12),
//           Expanded(
//             child: bills.isEmpty
//                 ? Center(
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 40.0),
//                       child: Text(
//                         "Scan to get your first ${AppConstants.recentHisaab}!",
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: Colors.black.withAlpha((255 * 0.6).round()),
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                   )
//                 : RefreshIndicator(
//               onRefresh: () => context.read<HistoryProvider>().fetchBills(),
//                   child: Stack(
//                       children: [
//                         ListView.builder(
//                           controller: scrollController,
//                           itemCount: bills.length > 5 ? 5 : bills.length,
//                           itemBuilder: (context, index) {
//                             final bill = bills[index];
//                             return BillListItem(
//                               bill: bill,
//                               onTap: () => _showBillDetailsModal(context, bill),
//                             );
//                           },
//                         ),
//                         if (isScrollable)
//                           Positioned(
//                             bottom: 0,
//                             left: 0,
//                             right: 0,
//                             child: IgnorePointer(
//                               child: Container(
//                                 height: 60,
//                                 decoration: BoxDecoration(
//                                   gradient: LinearGradient(
//                                     begin: Alignment.topCenter,
//                                     end: Alignment.bottomCenter,
//                                     colors: [
//                                       Colors.white.withAlpha(0),
//                                       Colors.white,
//                                     ],
//                                     stops: const [0.0, 0.9],
//                                   ),
//                                 ),
//                                 child: const Icon(
//                                   Icons.keyboard_arrow_down,
//                                   size: 40,
//                                   color: Colors.black54,
//                                 ),
//                               ),
//                             ),
//                           ),
//                       ],
//                     ),
//                 ),
//           ),
//         ],
//       ),
//     );
//   }
// }
