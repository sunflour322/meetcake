import 'package:cloud_firestore/cloud_firestore.dart';

class FriendshipService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendFriendRequest(String userId, String targetUserId) async {
    // Получаем имена пользователей (username)
    String userUsername = await _getUsernameById(userId);
    String targetUserUsername = await _getUsernameById(targetUserId);

    DocumentReference userDoc = _firestore.collection('users').doc(userId);
    DocumentReference targetUserDoc =
        _firestore.collection('users').doc(targetUserId);

    await _firestore.runTransaction((transaction) async {
      transaction.update(targetUserDoc, {
        'friendRequests': FieldValue.arrayUnion([userUsername]),
      });
      transaction.update(userDoc, {
        'outgoingFriendRequests': FieldValue.arrayUnion([targetUserUsername]),
      });
    });
  }

  Future<void> acceptFriendRequest(
      String currentUserId, String requesterId) async {
    try {
      String currentUserUsername = await _getUsernameById(currentUserId);
      String requesterUsername = await _getUsernameById(requesterId);

      DocumentReference currentUserDoc =
          _firestore.collection('users').doc(currentUserId);
      DocumentReference requesterDoc =
          _firestore.collection('users').doc(requesterId);

      await _firestore.runTransaction((transaction) async {
        transaction.update(currentUserDoc, {
          'friends': FieldValue.arrayUnion([requesterUsername]),
          'friendRequests': FieldValue.arrayRemove([requesterUsername]),
          'outgoingFriendRequests': FieldValue.arrayRemove([requesterUsername]),
        });
        transaction.update(requesterDoc, {
          'friends': FieldValue.arrayUnion([currentUserUsername]),
          'outgoingFriendRequests':
              FieldValue.arrayRemove([currentUserUsername]),
        });
      });
    } catch (e) {
      print("Ошибка при принятии заявки в друзья: $e");
    }
  }

  Future<void> rejectFriendRequest(String userId, String requesterId) async {
    String userUsername = await _getUsernameById(userId);
    String requesterUsername = await _getUsernameById(requesterId);

    DocumentReference userDoc = _firestore.collection('users').doc(userId);
    DocumentReference requesterDoc =
        _firestore.collection('users').doc(requesterId);

    await _firestore.runTransaction((transaction) async {
      transaction.update(userDoc, {
        'friendRequests': FieldValue.arrayRemove([requesterUsername]),
      });
      transaction.update(requesterDoc, {
        'outgoingFriendRequests': FieldValue.arrayRemove([userUsername]),
      });
    });
  }

  Future<void> removeFriend(
      String userId, String username, String friendName) async {
    try {
      // Получаем username друга
      String friendUsername = await _getUsernameById(friendName);

      DocumentReference userDoc = _firestore.collection('users').doc(userId);
      DocumentReference friendDoc =
          _firestore.collection('users').doc(friendName);

      await _firestore.runTransaction((transaction) async {
        transaction.update(userDoc, {
          'friends': FieldValue.arrayRemove([friendUsername]),
        });
        transaction.update(friendDoc, {
          'friends': FieldValue.arrayRemove([username]),
        });
      });
    } catch (e) {
      print("Ошибка при удалении друга: $e");
    }
  }

  Future<String> _getUsernameById(String userId) async {
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(userId).get();

    if (!userDoc.exists) {
      throw Exception("User not found for ID: $userId");
    }

    return userDoc['username'];
  }

  // Для получения потенциальных друзей
  Future<List<Map<String, dynamic>>> fetchPotentialFriends(
      String currentUserId) async {
    DocumentSnapshot userSnapshot =
        await _firestore.collection('users').doc(currentUserId).get();
    List<String> friendsList = List<String>.from(userSnapshot['friends'] ?? []);
    List<String> friendRequests =
        List<String>.from(userSnapshot['friendRequests'] ?? []);
    List<String> outgoingFriendRequests =
        List<String>.from(userSnapshot['outgoingFriendRequests'] ?? []);

    QuerySnapshot allUsersSnapshot = await _firestore.collection('users').get();

    List<Map<String, dynamic>> potentialFriends = [];
    for (var doc in allUsersSnapshot.docs) {
      if (doc.id != currentUserId &&
          !friendsList.contains(doc['username']) &&
          !friendRequests.contains(doc['username']) &&
          !outgoingFriendRequests.contains(doc['username'])) {
        potentialFriends.add({
          'id': doc.id,
          'username': doc['username'],
          'email': doc['email'],
        });
      }
    }
    return potentialFriends;
  }

  Future<String?> fetchUserImageUrl(String username) async {
    try {
      QuerySnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (userDoc.docs.isNotEmpty) {
        var friendImageUrl = userDoc.docs.first;
        return friendImageUrl['profileImageUrl'];
      }
      return null;
    } catch (e) {
      print("Error fetching user image URL: $e");
      return null;
    }
  }
}
