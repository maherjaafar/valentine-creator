import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../data/repositories/firestore_invite_repository.dart';
import '../../data/repositories/in_memory_invite_repository.dart';
import '../../domain/repositories/invite_repository.dart';
import 'firebase_options.dart';

class FirebaseBootstrapResult {
  const FirebaseBootstrapResult({required this.repository});

  final InviteRepository repository;
}

class FirebaseBootstrap {
  static Future<FirebaseBootstrapResult> initialize() async {
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      return FirebaseBootstrapResult(
        repository: FirestoreInviteRepository(FirebaseFirestore.instance),
      );
    } catch (error) {
      debugPrint('Firebase init failed: $error');
      return FirebaseBootstrapResult(repository: InMemoryInviteRepository());
    }
  }
}
