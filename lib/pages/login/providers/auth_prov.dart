import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProv {
  static Future<bool> login(String user, String password) async {
    final result = await FirebaseFirestore.instance
        .collection('admins')
        .where('name', isEqualTo: user)
        .where('password', isEqualTo: password)
        .get();

    return result.size > 0;
  }
}
