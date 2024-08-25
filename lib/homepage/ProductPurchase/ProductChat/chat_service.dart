import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<DocumentSnapshot> getChatStream(String chatPath) {
    return _firestore.doc(chatPath).snapshots();
  }

  Future<void> sendMessage(String chatPath, String userId, Map<String, dynamic> messageData) async {
    var chatRef = _firestore.doc(chatPath);
    var snapshot = await chatRef.get();

    if (!snapshot.exists) {
      await chatRef.set({userId: {}});
    }

    var userMessages = snapshot.data()? [userId] as Map<String, dynamic>? ?? {};
    var messageCount = userMessages.length;
    userMessages[(messageCount + 1).toString()] = messageData;

    await chatRef.update({userId: userMessages});
  }
}
