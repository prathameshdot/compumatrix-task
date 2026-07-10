import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String uid;
  final String email;
  final String displayName;
  final String? fcmToken;
  final Map<String, dynamic> prefs;

  const UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.fcmToken,
    this.prefs = const {},
  });

  static const Map<String, dynamic> defaultPrefs = {
    'dueReminderEnabled': true,
    'reminderLeadMinutes': 0,
  };

  bool get dueReminderEnabled => prefs['dueReminderEnabled'] as bool? ?? true;
  int get reminderLeadMinutes => prefs['reminderLeadMinutes'] as int? ?? 0;

  factory UserModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return UserModel(
      uid: doc.id,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      fcmToken: data['fcmToken'] as String?,
      prefs: {...defaultPrefs, ...?(data['prefs'] as Map?)?.cast<String, dynamic>()},
    );
  }

  @override
  List<Object?> get props => [uid, email, displayName, fcmToken, prefs];
}
