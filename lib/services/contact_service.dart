import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class ContactService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Request contacts permission
  Future<bool> requestContactsPermission() async {
    final status = await Permission.contacts.request();
    return status.isGranted;
  }

  // Get device contacts
  Future<List<Contact>> getDeviceContacts() async {
    try {
      final hasPermission = await requestContactsPermission();
      if (!hasPermission) {
        throw Exception('Contacts permission not granted');
      }

      final contacts = await ContactsService.getContacts();
      return contacts.toList();
    } catch (e) {
      throw Exception('Failed to get device contacts: $e');
    }
  }

  // Extract phone numbers from contacts
  List<String> extractPhoneNumbers(List<Contact> contacts) {
    final phoneNumbers = <String>[];
    
    for (final contact in contacts) {
      if (contact.phones != null) {
        for (final phone in contact.phones!) {
          // Clean phone number (remove spaces, dashes, etc.)
          final cleanNumber = phone.value?.replaceAll(RegExp(r'[^\d+]'), '');
          if (cleanNumber != null && cleanNumber.isNotEmpty) {
            phoneNumbers.add(cleanNumber);
          }
        }
      }
    }
    
    return phoneNumbers;
  }

  // Find app users by phone numbers
  Future<List<UserModel>> findAppUsersByPhoneNumbers(List<String> phoneNumbers) async {
    try {
      if (phoneNumbers.isEmpty) return [];

      final users = <UserModel>[];
      
      // Firestore doesn't support 'in' queries with more than 10 values
      // So we need to batch the queries
      const batchSize = 10;
      
      for (int i = 0; i < phoneNumbers.length; i += batchSize) {
        final batch = phoneNumbers.skip(i).take(batchSize).toList();
        
        final snapshot = await _firestore
            .collection('users')
            .where('phoneNumber', whereIn: batch)
            .get();

        for (final doc in snapshot.docs) {
          users.add(UserModel.fromFirestore(doc));
        }
      }
      
      return users;
    } catch (e) {
      throw Exception('Failed to find app users: $e');
    }
  }

  // Get matched contacts (device contacts who are app users)
  Future<List<UserModel>> getMatchedContacts() async {
    try {
      final deviceContacts = await getDeviceContacts();
      final phoneNumbers = extractPhoneNumbers(deviceContacts);
      final appUsers = await findAppUsersByPhoneNumbers(phoneNumbers);
      
      return appUsers;
    } catch (e) {
      throw Exception('Failed to get matched contacts: $e');
    }
  }

  // Search users by name or phone number
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      if (query.isEmpty) return [];

      // Search by phone number (exact match)
      final phoneSnapshot = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: query)
          .get();

      final users = <UserModel>[];
      
      for (final doc in phoneSnapshot.docs) {
        users.add(UserModel.fromFirestore(doc));
      }

      // Search by display name (contains)
      final nameSnapshot = await _firestore
          .collection('users')
          .where('displayName', isGreaterThanOrEqualTo: query)
          .where('displayName', isLessThan: query + '\uf8ff')
          .get();

      for (final doc in nameSnapshot.docs) {
        final user = UserModel.fromFirestore(doc);
        if (!users.any((u) => u.uid == user.uid)) {
          users.add(user);
        }
      }

      return users;
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }

  // Get user by phone number
  Future<UserModel?> getUserByPhoneNumber(String phoneNumber) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return UserModel.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user by phone number: $e');
    }
  }

  // Get all app users (for admin purposes)
  Future<List<UserModel>> getAllAppUsers() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .orderBy('displayName')
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get all app users: $e');
    }
  }

  // Check if phone number exists in app
  Future<bool> isPhoneNumberRegistered(String phoneNumber) async {
    try {
      final user = await getUserByPhoneNumber(phoneNumber);
      return user != null;
    } catch (e) {
      return false;
    }
  }
} 