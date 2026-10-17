class UserModel {
  final String uid;
  final String displayName;
  final String email;
  final String photoURL;

  UserModel({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.photoURL,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      displayName: data['displayName'] ?? 'مستخدم',
      email: data['email'] ?? '',
      photoURL: data['photoURL'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'photoURL': photoURL,
    };
  }
}
