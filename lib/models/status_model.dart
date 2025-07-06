import 'package:cloud_firestore/cloud_firestore.dart';

enum StatusType { text, image, video }

class StatusModel {
  final String id;
  final String userId;
  final String content;
  final StatusType type;
  final DateTime createdAt;
  final DateTime expiresAt;
  final List<String> viewedBy;
  final bool isDeleted;

  StatusModel({
    required this.id,
    required this.userId,
    required this.content,
    required this.type,
    required this.createdAt,
    required this.expiresAt,
    this.viewedBy = const [],
    this.isDeleted = false,
  });

  factory StatusModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StatusModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      content: data['content'] ?? '',
      type: StatusType.values.firstWhere(
        (e) => e.toString() == 'StatusType.${data['type']}',
        orElse: () => StatusType.text,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      expiresAt: (data['expiresAt'] as Timestamp).toDate(),
      viewedBy: List<String>.from(data['viewedBy'] ?? []),
      isDeleted: data['isDeleted'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'content': content,
      'type': type.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'viewedBy': viewedBy,
      'isDeleted': isDeleted,
    };
  }

  StatusModel copyWith({
    String? id,
    String? userId,
    String? content,
    StatusType? type,
    DateTime? createdAt,
    DateTime? expiresAt,
    List<String>? viewedBy,
    bool? isDeleted,
  }) {
    return StatusModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      viewedBy: viewedBy ?? this.viewedBy,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
} 