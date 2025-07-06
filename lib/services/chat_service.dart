import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Uuid _uuid = const Uuid();

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Create or get existing chat
  Future<String> createOrGetChat(String otherUserId) async {
    try {
      final currentUserId = this.currentUserId;
      if (currentUserId == null) throw Exception('User not authenticated');

      // Check if chat already exists
      final existingChat = await _firestore
          .collection('chats')
          .where('participants', arrayContains: currentUserId)
          .get();

      for (var doc in existingChat.docs) {
        final participants = List<String>.from(doc.data()['participants']);
        if (participants.contains(otherUserId)) {
          return doc.id;
        }
      }

      // Create new chat
      final chatId = _uuid.v4();
      final chat = ChatModel(
        id: chatId,
        participants: [currentUserId, otherUserId],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('chats')
          .doc(chatId)
          .set(chat.toFirestore());

      return chatId;
    } catch (e) {
      throw Exception('Failed to create chat: $e');
    }
  }

  // Send message
  Future<void> sendMessage({
    required String chatId,
    required String receiverId,
    required String content,
    required MessageType type,
  }) async {
    try {
      final currentUserId = this.currentUserId;
      if (currentUserId == null) throw Exception('User not authenticated');

      final messageId = _uuid.v4();
      final message = MessageModel(
        id: messageId,
        chatId: chatId,
        senderId: currentUserId,
        receiverId: receiverId,
        content: content,
        type: type,
        timestamp: DateTime.now(),
      );

      // Add message to Firestore
      await _firestore
          .collection('messages')
          .doc(messageId)
          .set(message.toFirestore());

      // Update chat with last message
      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': content,
        'lastMessageTime': Timestamp.fromDate(DateTime.now()),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      // Update typing status
      await _firestore.collection('chats').doc(chatId).update({
        'typingStatus.$currentUserId': false,
      });
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  // Get messages for a chat
  Stream<List<MessageModel>> getMessages(String chatId) {
    return _firestore
        .collection('messages')
        .where('chatId', isEqualTo: chatId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromFirestore(doc))
            .toList());
  }

  // Get user chats
  Stream<List<ChatModel>> getUserChats() {
    final currentUserId = this.currentUserId;
    if (currentUserId == null) return Stream.value([]);

    return _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatModel.fromFirestore(doc))
            .toList());
  }

  // Update message status
  Future<void> updateMessageStatus(String messageId, MessageStatus status) async {
    try {
      await _firestore.collection('messages').doc(messageId).update({
        'status': status.toString().split('.').last,
      });
    } catch (e) {
      throw Exception('Failed to update message status: $e');
    }
  }

  // Mark messages as seen
  Future<void> markMessagesAsSeen(String chatId) async {
    try {
      final currentUserId = this.currentUserId;
      if (currentUserId == null) throw Exception('User not authenticated');

      final messages = await _firestore
          .collection('messages')
          .where('chatId', isEqualTo: chatId)
          .where('receiverId', isEqualTo: currentUserId)
          .where('status', whereIn: ['sent', 'delivered'])
          .get();

      final batch = _firestore.batch();
      for (var doc in messages.docs) {
        batch.update(doc.reference, {
          'status': 'seen',
        });
      }
      await batch.commit();

      // Update chat last seen
      await _firestore.collection('chats').doc(chatId).update({
        'lastSeen.$currentUserId': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to mark messages as seen: $e');
    }
  }

  // Set typing status
  Future<void> setTypingStatus(String chatId, bool isTyping) async {
    try {
      final currentUserId = this.currentUserId;
      if (currentUserId == null) throw Exception('User not authenticated');

      await _firestore.collection('chats').doc(chatId).update({
        'typingStatus.$currentUserId': isTyping,
      });
    } catch (e) {
      throw Exception('Failed to set typing status: $e');
    }
  }

  // Get typing status
  Stream<Map<String, bool>> getTypingStatus(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return {};
      final data = doc.data() as Map<String, dynamic>;
      return Map<String, bool>.from(data['typingStatus'] ?? {});
    });
  }

  // Delete message
  Future<void> deleteMessage(String messageId) async {
    try {
      await _firestore.collection('messages').doc(messageId).update({
        'isDeleted': true,
      });
    } catch (e) {
      throw Exception('Failed to delete message: $e');
    }
  }

  // Get chat participants
  Future<List<UserModel>> getChatParticipants(String chatId) async {
    try {
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();
      if (!chatDoc.exists) return [];

      final participants = List<String>.from(chatDoc.data()!['participants']);
      final users = <UserModel>[];

      for (final userId in participants) {
        final userDoc = await _firestore.collection('users').doc(userId).get();
        if (userDoc.exists) {
          users.add(UserModel.fromFirestore(userDoc));
        }
      }

      return users;
    } catch (e) {
      throw Exception('Failed to get chat participants: $e');
    }
  }
} 