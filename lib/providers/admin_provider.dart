import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';
import '../services/database_service.dart';

final adminProvider = Provider<DatabaseService>((ref) => DatabaseService());

final studentsStreamProvider = StreamProvider<List<StudentModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('students')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => StudentModel.fromFirestore(doc)).toList());
});

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  set state(String value) => state = value;
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

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

class SelectedStudentNotifier extends Notifier<StudentModel?> {
  @override
  StudentModel? build() => null;
  void select(StudentModel? student) => state = student;
}

final selectedStudentProvider = NotifierProvider<SelectedStudentNotifier, StudentModel?>(SelectedStudentNotifier.new);

class PdfGeneratingNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  set state(bool value) => state = value;
}

final isPdfGeneratingProvider = NotifierProvider<PdfGeneratingNotifier, bool>(PdfGeneratingNotifier.new);
