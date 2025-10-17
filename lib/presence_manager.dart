import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PresenceManager {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  // Store last update time to avoid frequent writes
  static DateTime? _lastUpdate;

  static void setupPresence() {
    final user = _auth.currentUser;
    if (user == null) return;

    // Ensure the user document exists
    _initializeUserDocument(user.uid);

    // Immediately set user online
    _setUserStatus(true);

    // Observe app lifecycle to update status
    WidgetsBinding.instance.addObserver(
      _LifecycleEventHandler(
        onResume: () => _setUserStatus(true),
        onPause: () => _setUserStatus(false),
      ),
    );
  }

  static Future<void> _initializeUserDocument(String uid) async {
    final doc = _firestore.collection('users').doc(uid);
    final snapshot = await doc.get();
    if (!snapshot.exists) {
      await doc.set({
        'isOnline': true,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    }
  }

  static Future<void> _setUserStatus(bool isOnline) async {
    final now = DateTime.now();

    // Throttle updates to avoid spamming Firestore
    if (_lastUpdate != null && now.difference(_lastUpdate!).inSeconds < 5) return;
    _lastUpdate = now;

    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).update({
        'isOnline': isOnline,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error updating presence: $e");
    }
  }
}

class _LifecycleEventHandler extends WidgetsBindingObserver {
  final Future<void> Function()? onResume;
  final Future<void> Function()? onPause;

  _LifecycleEventHandler({this.onResume, this.onPause});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (onResume != null) onResume!();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        if (onPause != null) onPause!();
        break;
      default:
        break;
    }
  }
}
