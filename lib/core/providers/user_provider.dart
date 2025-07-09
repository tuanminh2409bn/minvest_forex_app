import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProvider with ChangeNotifier {
  String? _userTier;
  String? get userTier => _userTier;

  UserProvider() {
    _listenToUserChanges();
  }

  void _listenToUserChanges() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots()
            .listen((snapshot) {
          if (snapshot.exists && snapshot.data()!.containsKey('subscriptionTier')) {
            _userTier = snapshot.data()!['subscriptionTier'];
          } else {
            _userTier = null; // hoặc 'demo'
          }
          notifyListeners();
        });
      } else {
        _userTier = null;
        notifyListeners();
      }
    });
  }
}