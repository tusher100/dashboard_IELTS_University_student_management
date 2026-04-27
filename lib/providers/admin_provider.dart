import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';
import '../services/database_service.dart';

final adminProvider = Provider<DatabaseService>((ref) => DatabaseService());

class PublicViewNotifier extends Notifier<bool> {
  @override
  bool build() {
    // Check URL for mode=admission
    try {
      final uri = Uri.base;
      return uri.queryParameters['mode'] == 'admission';
    } catch (_) {
      return false;
    }
  }
  void update(bool value) => state = value;
}

final publicViewProvider = NotifierProvider<PublicViewNotifier, bool>(PublicViewNotifier.new);

final adminActionProvider = NotifierProvider<AdminNotifier, void>(AdminNotifier.new);

class AdminNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> addStudent(StudentModel student) async {
    await FirebaseFirestore.instance.collection('students').add(student.toFirestore());
  }

  Future<void> updateStudent(StudentModel student) async {
    if (student.id == null) return;
    await FirebaseFirestore.instance.collection('students').doc(student.id).update(student.toFirestore());
  }

  Future<void> deleteStudent(String id) async {
    await FirebaseFirestore.instance.collection('students').doc(id).delete();
  }

  Future<void> approveStudent(StudentModel student) async {
    if (student.id == null) return;
    await FirebaseFirestore.instance.collection('students').doc(student.id).update({'isApproved': true});
  }
}

final studentsStreamProvider = StreamProvider<List<StudentModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('students')
      .where('isApproved', isEqualTo: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => StudentModel.fromFirestore(doc)).toList());
});

final pendingStudentsStreamProvider = StreamProvider<List<StudentModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('students')
      .where('isApproved', isEqualTo: false)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => StudentModel.fromFirestore(doc)).toList());
});

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void update(String value) => state = value;
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
  void update(StudentModel? student) => state = student;
}

final selectedStudentProvider = NotifierProvider<SelectedStudentNotifier, StudentModel?>(SelectedStudentNotifier.new);

class PdfGeneratingNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void update(bool value) => state = value;
}

final isPdfGeneratingProvider = NotifierProvider<PdfGeneratingNotifier, bool>(PdfGeneratingNotifier.new);
