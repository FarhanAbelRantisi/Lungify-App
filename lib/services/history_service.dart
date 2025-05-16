import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:healthbot_app/models/chat_message.dart';

class HistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> addChatMessage(ChatMessage message) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("ERROR: ${DateTime.now()}: No authenticated user found");
        return false;
      }

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('chat_history')
          .add(message.toMap());
      print("INFO: ${DateTime.now()}: Successfully saved message to Firestore");
      return true;
    } catch (e) {
      print("ERROR: ${DateTime.now()}: Failed to save message to Firestore: $e");
      return false;
    }
  }

  Stream<List<Map<String, ChatMessage>>> getChatHistoryPairs() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('chat_history')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      List<Map<String, ChatMessage>> pairs = [];
      ChatMessage? lastUserMessage;

      for (var doc in snapshot.docs) {
        final message = ChatMessage.fromMap(doc.data());
        if (message.isUser) {
          lastUserMessage = message;
        } else if (lastUserMessage != null) {
          pairs.add({
            'question': lastUserMessage,
            'answer': message,
          });
          lastUserMessage = null; // Reset after pairing
        }
      }

      return pairs;
    });
  }
}