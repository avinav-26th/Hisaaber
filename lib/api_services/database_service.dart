import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:hisaaber_v1/models/saved_bill_model.dart';
import 'package:hisaaber_v1/models/user_profile_model.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- Private Helper to get the current user's phone number ---
  Future<String?> _getLoggedInUserPhone() async {
    // Ensure the session box is open before trying to read from it.
    if (!Hive.isBoxOpen('session')) {
      await Hive.openBox('session');
    }
    final box = Hive.box('session');
    return box.get('phoneNumber');
  }

  // --- Box Closing Method ---
  // This is useful for the sign-out process to close user-specific boxes.
  Future<void> closeUserBoxes() async {
    final phoneNumber = await _getLoggedInUserPhone();
    if (phoneNumber == null) return;

    final billsBoxName = 'saved_bills_$phoneNumber';
    final profileBoxName = 'user_profile_$phoneNumber';
    final pinnedBoxName = 'pinned_bills_$phoneNumber';

    if (Hive.isBoxOpen(billsBoxName)) await Hive.box(billsBoxName).close();
    if (Hive.isBoxOpen(profileBoxName)) await Hive.box(profileBoxName).close();
    if (Hive.isBoxOpen(pinnedBoxName)) await Hive.box(pinnedBoxName).close();
  }

  // --- Bill Methods ---
  Future<void> saveBill(SavedBillModel bill) async {
    final phoneNumber = await _getLoggedInUserPhone();
    if (phoneNumber == null) return;

    // Open the user-specific box for bills
    final box = await Hive.openBox<SavedBillModel>('saved_bills_$phoneNumber');
    final billId = bill.date.toIso8601String();
    await box.put(billId, bill);

    // Sync to Firestore under the user's document
    await _syncBillToFirestore(bill, billId, phoneNumber);
  }

  Future<List<SavedBillModel>> getBills() async {
    final phoneNumber = await _getLoggedInUserPhone();
    if (phoneNumber == null) return []; // Return empty list if no user

    // Open the user-specific box for bills
    final box = await Hive.openBox<SavedBillModel>('saved_bills_$phoneNumber');
    return box.values.toList();
  }

  Future<void> deleteBill(String billId) async {
    final phoneNumber = await _getLoggedInUserPhone();
    if (phoneNumber == null) return;

    // Delete from the user-specific Hive box
    final box = await Hive.openBox<SavedBillModel>('saved_bills_$phoneNumber');
    await box.delete(billId);

    // Also delete from Firestore
    await _firestore
        .collection('users')
        .doc(phoneNumber)
        .collection('bills')
        .doc(billId)
        .delete();
  }

  // --- Sync Methods ---
  Future<void> syncAllBillsToFirestore() async {
    final phoneNumber = await _getLoggedInUserPhone();
    if (phoneNumber == null) return;

    final box = await Hive.openBox<SavedBillModel>('saved_bills_$phoneNumber');
    for (var bill in box.values) {
      await _syncBillToFirestore(bill, bill.date.toIso8601String(), phoneNumber);
    }
  }

  Future<void> _syncBillToFirestore(
      SavedBillModel bill, String billId, String phoneNumber) async {
    final billData = {
      'customerName': bill.customerName,
      'date': bill.date,
      'totalAmount': bill.totalAmount,
      'items': bill.items.map((item) => {'name': item.name, 'price': item.price}).toList(),
    };
    await _firestore
        .collection('users')
        .doc(phoneNumber)
        .collection('bills')
        .doc(billId)
        .set(billData);
  }

  // --- User Profile Methods ---
  Future<void> saveUserProfile(UserProfileModel profile) async {
    final phoneNumber = await _getLoggedInUserPhone();
    if (phoneNumber == null) return;

    // Save to the user-specific profile box
    final box = await Hive.openBox<UserProfileModel>('user_profile_$phoneNumber');
    await box.put('profile', profile);

    final profileData = {'name': profile.name, 'avatarId': profile.avatarId};
    await _firestore.collection('users').doc(phoneNumber).set(profileData);
  }

  Future<UserProfileModel?> getUserProfile() async {
    final phoneNumber = await _getLoggedInUserPhone();
    if (phoneNumber == null) return null;

    // Get from the user-specific profile box
    final box = await Hive.openBox<UserProfileModel>('user_profile_$phoneNumber');
    return box.get('profile');
  }

  // --- Pinned Bill Methods ---
  Future<List<String>> getPinnedBillIds() async {
    final phoneNumber = await _getLoggedInUserPhone();
    if (phoneNumber == null) return [];

    final box = await Hive.openBox<String>('pinned_bills_$phoneNumber');
    return box.values.toList();
  }

  Future<void> addPinnedBillId(String billId) async {
    final phoneNumber = await _getLoggedInUserPhone();
    if (phoneNumber == null) return;

    final box = await Hive.openBox<String>('pinned_bills_$phoneNumber');
    await box.put(billId, billId);
  }

  Future<void> removePinnedBillId(String billId) async {
    final phoneNumber = await _getLoggedInUserPhone();
    if (phoneNumber == null) return;

    final box = await Hive.openBox<String>('pinned_bills_$phoneNumber');
    await box.delete(billId);
  }

  // --- Dummy Session Methods ---
  Future<void> createDummySession(String phoneNumber) async {
    final box = await Hive.openBox('session');
    await box.put('isLoggedIn', true);
    await box.put('phoneNumber', phoneNumber);
  }

  Future<bool> hasDummySession() async {
    final box = await Hive.openBox('session');
    return box.get('isLoggedIn') ?? false;
  }

  Future<void> clearDummySession() async {
    final box = await Hive.openBox('session');
    await box.clear();
  }

  Future<String?> getLoggedInUserPhone() async {
    final box = await Hive.openBox('session');
    return box.get('phoneNumber');
  }
}


// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:hive/hive.dart';
// import 'package:hisaaber_v1/models/saved_bill_model.dart';
// import 'package:hisaaber_v1/models/user_profile_model.dart';
//
// class DatabaseService {
//   // Get an instance of Cloud Firestore
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   // --- Bill Methods ---
//
//   /// Saves a new bill to the Hive database and syncs it to Firestore.
//   Future<void> saveBill(SavedBillModel bill) async {
//     final hiveBox = await Hive.openBox<SavedBillModel>('saved_bills');
//     final billId = bill.date.toIso8601String();
//     await hiveBox.put(billId, bill);
//
//     // Sync to Firestore
//     await _syncBillToFirestore(bill, billId);
//   }
//
//   /// Retrieves a list of all saved bills from the database.
//   Future<List<SavedBillModel>> getBills() async {
//     final box = await Hive.openBox<SavedBillModel>('saved_bills');
//     return box.values.toList();
//   }
//
//   /// Deletes a bill from the database using its key.
//   Future<void> deleteBill(String billId) async {
//     final box = await Hive.openBox<SavedBillModel>('saved_bills');
//     await box.delete(billId);
//
//     // Also delete from Firestore
//     await _firestore.collection('bills').doc(billId).delete();
//   }
//
//   /// Syncs all local bills to Firestore
//   Future<void> syncAllBillsToFirestore() async {
//     final box = await Hive.openBox<SavedBillModel>('saved_bills');
//     for (var bill in box.values) {
//       await _syncBillToFirestore(bill, bill.date.toIso8601String());
//     }
//   }
//
//   // --- Private Firestore Helper ---
//   Future<void> _syncBillToFirestore(SavedBillModel bill, String billId) async {
//     final billData = {
//       'customerName': bill.customerName,
//       'date': bill.date,
//       'totalAmount': bill.totalAmount,
//       'items': bill.items.map((item) => {'name': item.name, 'price': item.price}).toList(),
//     };
//     await _firestore.collection('bills').doc(billId).set(billData);
//   }
//
//   // --- User Profile Methods ---
//
//   /// Saves the user's profile data.
//   Future<void> saveUserProfile(UserProfileModel profile) async {
//     final box = await Hive.openBox<UserProfileModel>('user_profile');
//     await box.put('currentUserProfile', profile);
//
//     // Sync to Firestore as well
//     final profileData = {'name': profile.name, 'avatarId': profile.avatarId};
//     await _firestore.collection('users').doc('currentUserProfile').set(profileData);
//   }
//
//   /// Retrieves the saved user profile.
//   Future<UserProfileModel?> getUserProfile() async {
//     final box = await Hive.openBox<UserProfileModel>('user_profile');
//     return box.get('currentUserProfile');
//   }
//
//   // --- Dummy Session Methods ---
//
//   Future<void> createDummySession(String phoneNumber) async {
//     final box = await Hive.openBox('session');
//     // We just save a simple boolean to know the user is "logged in"
//     await box.put('isLoggedIn', true);
//     await box.put('phoneNumber', phoneNumber); // Store the phone number
//   }
//
//   Future<bool> hasDummySession() async {
//     final box = await Hive.openBox('session');
//     // Check if the isLoggedIn key exists and is true. Defaults to false.
//     return box.get('isLoggedIn') ?? false;
//   }
//
//   Future<void> clearDummySession() async {
//     final box = await Hive.openBox('session');
//     await box.clear(); // Clears all data in the session box
//   }
//   Future<String?> getLoggedInUserPhone() async {
//     final box = await Hive.openBox('session');
//     return box.get('phoneNumber');
//   }
// }