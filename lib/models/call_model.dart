import 'package:cloud_firestore/cloud_firestore.dart';

enum CallType { voice, video }
enum CallStatus { incoming, outgoing, answered, rejected, missed, ended }

class CallModel {
  final String id;
  final String callerId;
  final String receiverId;
  final CallType type;
  final CallStatus status;
  final DateTime startTime;
  final DateTime? endTime;
  final Duration? duration;
  final String? sessionId;

  CallModel({
    required this.id,
    required this.callerId,
    required this.receiverId,
    required this.type,
    required this.status,
    required this.startTime,
    this.endTime,
    this.duration,
    this.sessionId,
  });

  factory CallModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CallModel(
      id: doc.id,
      callerId: data['callerId'] ?? '',
      receiverId: data['receiverId'] ?? '',
      type: CallType.values.firstWhere(
        (e) => e.toString() == 'CallType.${data['type']}',
        orElse: () => CallType.voice,
      ),
      status: CallStatus.values.firstWhere(
        (e) => e.toString() == 'CallStatus.${data['status']}',
        orElse: () => CallStatus.missed,
      ),
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: data['endTime'] != null 
          ? (data['endTime'] as Timestamp).toDate() 
          : null,
      duration: data['duration'] != null 
          ? Duration(seconds: data['duration']) 
          : null,
      sessionId: data['sessionId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'callerId': callerId,
      'receiverId': receiverId,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'duration': duration?.inSeconds,
      'sessionId': sessionId,
    };
  }

  CallModel copyWith({
    String? id,
    String? callerId,
    String? receiverId,
    CallType? type,
    CallStatus? status,
    DateTime? startTime,
    DateTime? endTime,
    Duration? duration,
    String? sessionId,
  }) {
    return CallModel(
      id: id ?? this.id,
      callerId: callerId ?? this.callerId,
      receiverId: receiverId ?? this.receiverId,
      type: type ?? this.type,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      sessionId: sessionId ?? this.sessionId,
    );
  }
} 