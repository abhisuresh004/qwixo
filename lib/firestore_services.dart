import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveusertofirestore(User user) async {
    try {
      final userDoc = _firestore.collection('users').doc(user.uid);

      await userDoc.set({
        "uid": user.uid,
        "name": user.displayName,
        "email": user.email,
        "photourl": user.photoURL,
        "lastseen": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print("Error saving user to Firestore: $e");
    }
  }

  Future<DocumentSnapshot> getuser(String uid) async {
    return await _firestore.collection('users').doc(uid).get();
  }

  Stream<QuerySnapshot> getAllUsers() {
    return _firestore.collection('users').snapshots();
  }
}
