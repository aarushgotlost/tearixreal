import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String displayName;
  final String email;
  final String phoneNumber;
  final String? profilePicture;
  final bool isOnline;
  final DateTime? lastSeen;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, bool> blockedUsers;
  final Map<String, dynamic> privacySettings;

  UserModel({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.phoneNumber,
    this.profilePicture,
    this.isOnline = false,
    this.lastSeen,
    required this.createdAt,
    required this.updatedAt,
    this.blockedUsers = const {},
    this.privacySettings = const {
      'lastSeen': true,
      'profilePicture': true,
      'status': true,
    },
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      displayName: data['displayName'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      profilePicture: data['profilePicture'],
      isOnline: data['isOnline'] ?? false,
      lastSeen: data['lastSeen'] != null 
          ? (data['lastSeen'] as Timestamp).toDate() 
          : null,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      blockedUsers: Map<String, bool>.from(data['blockedUsers'] ?? {}),
      privacySettings: Map<String, dynamic>.from(data['privacySettings'] ?? {
        'lastSeen': true,
        'profilePicture': true,
        'status': true,
      }),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      'email': email,
      'phoneNumber': phoneNumber,
      'profilePicture': profilePicture,
      'isOnline': isOnline,
      'lastSeen': lastSeen != null ? Timestamp.fromDate(lastSeen!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'blockedUsers': blockedUsers,
      'privacySettings': privacySettings,
    };
  }

  UserModel copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? phoneNumber,
    String? profilePicture,
    bool? isOnline,
    DateTime? lastSeen,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, bool>? blockedUsers,
    Map<String, dynamic>? privacySettings,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePicture: profilePicture ?? this.profilePicture,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      blockedUsers: blockedUsers ?? this.blockedUsers,
      privacySettings: privacySettings ?? this.privacySettings,
    );
  }
} 