import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import '../models/status_model.dart';

class StatusService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Uuid _uuid = const Uuid();
  final ImagePicker _imagePicker = ImagePicker();

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Create text status
  Future<void> createTextStatus(String text) async {
    try {
      final currentUserId = this.currentUserId;
      if (currentUserId == null) throw Exception('User not authenticated');

      final statusId = _uuid.v4();
      final now = DateTime.now();
      final expiresAt = now.add(const Duration(hours: 24));

      final status = StatusModel(
        id: statusId,
        userId: currentUserId,
        content: text,
        type: StatusType.text,
        createdAt: now,
        expiresAt: expiresAt,
      );

      await _firestore
          .collection('status')
          .doc(statusId)
          .set(status.toFirestore());
    } catch (e) {
      throw Exception('Failed to create text status: $e');
    }
  }

  // Create image status
  Future<void> createImageStatus() async {
    try {
      final currentUserId = this.currentUserId;
      if (currentUserId == null) throw Exception('User not authenticated');

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1920,
        imageQuality: 80,
      );

      if (image == null) return;

      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);

      final statusId = _uuid.v4();
      final now = DateTime.now();
      final expiresAt = now.add(const Duration(hours: 24));

      final status = StatusModel(
        id: statusId,
        userId: currentUserId,
        content: base64Image,
        type: StatusType.image,
        createdAt: now,
        expiresAt: expiresAt,
      );

      await _firestore
          .collection('status')
          .doc(statusId)
          .set(status.toFirestore());
    } catch (e) {
      throw Exception('Failed to create image status: $e');
    }
  }

  // Get user's own statuses
  Stream<List<StatusModel>> getUserStatuses(String userId) {
    return _firestore
        .collection('status')
        .where('userId', isEqualTo: userId)
        .where('expiresAt', isGreaterThan: Timestamp.fromDate(DateTime.now()))
        .where('isDeleted', isEqualTo: false)
        .orderBy('expiresAt', descending: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StatusModel.fromFirestore(doc))
            .toList());
  }

  // Get all active statuses from contacts
  Stream<List<StatusModel>> getAllActiveStatuses() {
    return _firestore
        .collection('status')
        .where('expiresAt', isGreaterThan: Timestamp.fromDate(DateTime.now()))
        .where('isDeleted', isEqualTo: false)
        .orderBy('expiresAt', descending: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StatusModel.fromFirestore(doc))
            .toList());
  }

  // Mark status as viewed
  Future<void> markStatusAsViewed(String statusId) async {
    try {
      final currentUserId = this.currentUserId;
      if (currentUserId == null) throw Exception('User not authenticated');

      await _firestore.collection('status').doc(statusId).update({
        'viewedBy': FieldValue.arrayUnion([currentUserId]),
      });
    } catch (e) {
      throw Exception('Failed to mark status as viewed: $e');
    }
  }

  // Delete status
  Future<void> deleteStatus(String statusId) async {
    try {
      final currentUserId = this.currentUserId;
      if (currentUserId == null) throw Exception('User not authenticated');

      await _firestore.collection('status').doc(statusId).update({
        'isDeleted': true,
      });
    } catch (e) {
      throw Exception('Failed to delete status: $e');
    }
  }

  // Get status by ID
  Future<StatusModel?> getStatusById(String statusId) async {
    try {
      final doc = await _firestore.collection('status').doc(statusId).get();
      if (doc.exists) {
        return StatusModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get status: $e');
    }
  }

  // Get statuses by user ID
  Future<List<StatusModel>> getStatusesByUserId(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('status')
          .where('userId', isEqualTo: userId)
          .where('expiresAt', isGreaterThan: Timestamp.fromDate(DateTime.now()))
          .where('isDeleted', isEqualTo: false)
          .orderBy('expiresAt', descending: true)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => StatusModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user statuses: $e');
    }
  }

  // Clean up expired statuses (can be called periodically)
  Future<void> cleanupExpiredStatuses() async {
    try {
      final expiredStatuses = await _firestore
          .collection('status')
          .where('expiresAt', isLessThan: Timestamp.fromDate(DateTime.now()))
          .get();

      final batch = _firestore.batch();
      for (var doc in expiredStatuses.docs) {
        batch.update(doc.reference, {'isDeleted': true});
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to cleanup expired statuses: $e');
    }
  }
} 