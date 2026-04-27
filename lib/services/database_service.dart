import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addPendingStudent(StudentModel student) async {
    await _db.collection('pending_registrations').add(student.toFirestore());
  }

  Stream<List<StudentModel>> getPendingStudentsStream() {
    return _db.collection('pending_registrations').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => StudentModel.fromFirestore(doc)).toList();
    });
  }

  Future<void> approveStudent(StudentModel student) async {
    if (student.id == null) return;
    
    final batch = _db.batch();
    
    // Add to main collection
    final newStudentRef = _db.collection('students').doc();
    batch.set(newStudentRef, student.toFirestore());
    
    // Delete from pending
    final pendingRef = _db.collection('pending_registrations').doc(student.id);
    batch.delete(pendingRef);
    
    await batch.commit();
  }

  Future<void> addStudent(StudentModel student) async {
    await _db.collection('students').add(student.toFirestore());
  }

  Future<void> deleteStudent(String id) async {
    await _db.collection('students').doc(id).delete();
  }

  // Add other operations as needed
}
