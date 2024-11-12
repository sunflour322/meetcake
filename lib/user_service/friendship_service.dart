import 'package:cloud_firestore/cloud_firestore.dart';

class FriendshipService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Метод для отправки запроса на дружбу
  Future<void> sendFriendRequest(String userId, String targetUserId) async {
    DocumentReference targetUserDoc =
        _firestore.collection('users').doc(targetUserId);
    await targetUserDoc.update({
      'friendRequests': FieldValue.arrayUnion([userId])
    });
  }

  // Метод для принятия запроса на дружбу
  Future<void> acceptFriendRequest(String userId, String requesterId) async {
    DocumentReference userDoc = _firestore.collection('users').doc(userId);
    DocumentReference requesterDoc =
        _firestore.collection('users').doc(requesterId);

    await _firestore.runTransaction((transaction) async {
      // Добавляем друг друга в списки друзей
      transaction.update(userDoc, {
        'friends': FieldValue.arrayUnion([requesterId]),
        'friendRequests': FieldValue.arrayRemove([requesterId]),
      });

      transaction.update(requesterDoc, {
        'friends': FieldValue.arrayUnion([userId]),
      });
    });
  }

  // Метод для отклонения запроса на дружбу
  Future<void> rejectFriendRequest(String userId, String requesterId) async {
    DocumentReference userDoc = _firestore.collection('users').doc(userId);
    await userDoc.update({
      'friendRequests': FieldValue.arrayRemove([requesterId]),
    });
  }

  // Метод для удаления из друзей
  Future<void> removeFriend(String userId, String friendId) async {
    DocumentReference userDoc = _firestore.collection('users').doc(userId);
    DocumentReference friendDoc = _firestore.collection('users').doc(friendId);

    await _firestore.runTransaction((transaction) async {
      transaction.update(userDoc, {
        'friends': FieldValue.arrayRemove([friendId]),
      });
      transaction.update(friendDoc, {
        'friends': FieldValue.arrayRemove([userId]),
      });
    });
  }
}
