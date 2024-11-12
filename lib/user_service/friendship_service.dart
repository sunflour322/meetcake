import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meetcake/user_service/model.dart';

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
  Future<void> acceptFriendRequest(
      String currentUserId, String requesterId) async {
    try {
      DocumentSnapshot requesterSnapshot =
          await _firestore.collection('users').doc(requesterId).get();
      DocumentSnapshot currentUserSnapshot =
          await _firestore.collection('users').doc(currentUserId).get();

      String requesterName = requesterSnapshot['username'];
      String currentUserName = currentUserSnapshot['username'];

      if (currentUserId != requesterId) {
        // Добавляем пользователей в друзья
        await _firestore.collection('users').doc(currentUserId).update({
          'friends': FieldValue.arrayUnion([requesterName]),
          'friendRequests': FieldValue.arrayRemove([requesterId]),
        });
        await _firestore.collection('users').doc(requesterId).update({
          'friends': FieldValue.arrayUnion([currentUserName])
        });
      }
    } catch (e) {
      print("Ошибка при принятии заявки в друзья: $e");
    }
  }

  // Метод для отклонения запроса на дружбу
  Future<void> rejectFriendRequest(String userId, String requesterId) async {
    DocumentReference userDoc = _firestore.collection('users').doc(userId);
    await userDoc.update({
      'friendRequests': FieldValue.arrayRemove([requesterId]),
    });
  }

  Future<List<Map<String, dynamic>>> fetchPotentialFriends(
      String currentUserId) async {
    DocumentSnapshot userSnapshot =
        await _firestore.collection('users').doc(currentUserId).get();
    List<dynamic> friendsList = userSnapshot['friends'] ?? [];
    List<dynamic> friendRequests = userSnapshot['friendRequests'] ?? [];

    QuerySnapshot allUsersSnapshot = await _firestore.collection('users').get();
    List<Map<String, dynamic>> potentialFriends = [];

    for (var doc in allUsersSnapshot.docs) {
      if (doc.id != currentUserId && !friendsList.contains(doc['username'])) {
        potentialFriends.add({
          'id': doc.id,
          'username': doc['username'],
          'email': doc['email'],
        });
      }
    }
    return potentialFriends;
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
