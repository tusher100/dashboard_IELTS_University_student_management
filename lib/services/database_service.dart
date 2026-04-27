import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addStudent(StudentModel student) async {
    await _db.collection('students').add(student.toFirestore());
  }

  // Add other operations as needed
}
