import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/models.dart';

final studentsStreamProvider = StreamProvider<List<StudentModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('students')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => StudentModel.fromFirestore(doc)).toList());
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredStudentsProvider = Provider<AsyncValue<List<StudentModel>>>((ref) {
  final studentsAsync = ref.watch(studentsStreamProvider);
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase();

  return studentsAsync.whenData((students) {
    if (searchQuery.isEmpty) return students;
    return students.where((student) {
      return student.fullName.toLowerCase().contains(searchQuery) ||
             student.mobileNumber.contains(searchQuery);
    }).toList();
  });
});

final selectedStudentProvider = StateProvider<StudentModel?>((ref) => null);
