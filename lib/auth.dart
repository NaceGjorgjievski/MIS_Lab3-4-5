
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'exam.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);

    User? user = _firebaseAuth.currentUser;

    if(user != null){
      await _firestore.collection('users').doc(user.uid).set({
        'email': email,
        'password': password
      });
    }
  }

  Future<void> createExam({
    required String name,
    required DateTime dateTime,
    required double latitude,
    required double longitude,
  }) async{
    try{
      User? user = _firebaseAuth.currentUser;

      if(user != null){
        await _firestore.collection('exams').add({
          'userId': user.uid,
          'name': name,
          'dateTime': dateTime,
          'latitude': latitude,
          'longitude': longitude,
        });
      }
    } on FirebaseAuthException catch (e){
      rethrow;
    }
  }

  Stream<List<Exam>> getExams(){
    User? user = _firebaseAuth.currentUser;

    if(user != null){
      return _firestore
          .collection('exams')
          .where('userId', isEqualTo: user.uid)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              return Exam(
                name: data['name'],
                dateTime: (data['dateTime'] as Timestamp).toDate(),
                latitude: data['latitude'],
                longitude: data['longitude'],
              );
            }).toList();
      });
    } else{
      return Stream.value([]);
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
