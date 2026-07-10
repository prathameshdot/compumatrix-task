import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user.dart';
import '../utils/app_exception.dart';
import 'auth_service.dart';

class UserRepository {
  final FirebaseFirestore _firestore;
  UserRepository({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;
  DocumentReference<Map<String, dynamic>> _userRef(String uid) => _firestore.collection('users').doc(uid);
  Stream<UserModel?> watchUser(String uid) {
    return _userRef(uid).snapshots().map((doc) => doc.exists ? UserModel.fromDoc(doc) : null);
  }

  Future<void> ensureUserDoc(User user) async {
    final ref = _userRef(user.uid);
    final snapshot = await ref.get();
    if (snapshot.exists) return;
    try {
      await ref.set({
        'email': (user.email ?? '').toLowerCase(),
        'displayName': user.displayName ?? '',
        'prefs': UserModel.defaultPrefs,
      });
    } catch (e) {
      throw const AppException('Could not set up your profile. Please try again.');
    }
  }

  Future<void> updateDisplayName(String uid, String name) async {
    try {
      await _userRef(uid).set({'displayName': name.trim()}, SetOptions(merge: true));
    } catch (e) {
      throw const AppException('Could not update your name. Please try again.');
    }
  }

  Future<void> updatePrefs(String uid, Map<String, dynamic> updates) async {
    try {
      await _userRef(uid).set(
        {'prefs': updates},
        SetOptions(mergeFields: [for (final key in updates.keys) 'prefs.$key']),
      );
    } catch (e) {
      throw const AppException('Could not update your preferences. Please try again.');
    }
  }
}

final userRepositoryProvider = Provider<UserRepository>((ref) => UserRepository());
final currentUserProfileProvider = StreamProvider<UserModel?>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return Stream.value(null);
  return ref.watch(userRepositoryProvider).watchUser(user.uid);
});
