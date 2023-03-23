import 'package:ridesafe_core/repositories/user_repository.dart';
import 'package:ridesafe_core/user/user.dart';

class UserRepositoryServerInteractor implements UserRepository {
  final _usersCollection = FirebaseFirestore.instance.collection('users');

  @override
  Future<User> create(String username) async {
    final user = User(username);
    final userDoc = await _usersCollection.add(user.toJson());
    final userId = userDoc.id;
    user.id = userId;
    return user;
  }

  @override
  Future<void> delete(String uid) async {
    try {
      await _usersCollection.doc(uid).delete();
    } catch (e) {
      throw RepositoryException('Failed to delete user: $e');
    }
  }

  @override
  Future<User?> getById(String id) async {
    try {
      final userDoc = await _usersCollection.doc(id).get();
      if (!userDoc.exists) return null;
      final userData = userDoc.data()!;
      final user = User.fromJson(userData);
      user.id = userDoc.id;
      return user;
    } catch (e) {
      throw RepositoryException('Failed to get user by ID: $e');
    }
  }

  @override
  Future<User?> getByUsername(String username) async {
    try {
      final query = await _usersCollection
          .where('username', isEqualTo: username)
          .limit(1)
          .get();
      if (query.docs.isEmpty) return null;
      final userData = query.docs.first.data();
      final user = User.fromJson(userData);
      user.id = query.docs.first.id;
      return user;
    } catch (e) {
      throw RepositoryException('Failed to get user by username: $e');
    }
  }

  @override
  Future<void> update(String uid, User user) async {
    try {
      await _usersCollection.doc(uid).update(user.toJson());
    } catch (e) {
      throw RepositoryException('Failed to update user: $e');
    }
  }
}
