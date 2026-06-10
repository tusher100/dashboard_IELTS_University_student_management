import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';
import '../services/database_service.dart';

final adminProvider = Provider<DatabaseService>((ref) => DatabaseService());

class CoachingCenterNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void update(String? value) => state = value;
}

final coachingCenterProvider = NotifierProvider<CoachingCenterNotifier, String?>(CoachingCenterNotifier.new);

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

  Future<void> addCourse(CourseModel course) async {
    await FirebaseFirestore.instance.collection('courses').add(course.toMap());
  }

  Future<void> updateCourse(CourseModel course) async {
    if (course.id == null) return;
    await FirebaseFirestore.instance.collection('courses').doc(course.id).update(course.toMap());
  }

  Future<void> deleteCourse(String id) async {
    await FirebaseFirestore.instance.collection('courses').doc(id).delete();
  }
}

final coursesStreamProvider = StreamProvider<List<CourseModel>>((ref) {
  final center = ref.watch(coachingCenterProvider);
  if (center == null) return const Stream.empty();

  return FirebaseFirestore.instance
      .collection('courses')
      .where('coachingCenter', isEqualTo: center)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => CourseModel.fromFirestore(doc)).toList());
});

final studentsStreamProvider = StreamProvider<List<StudentModel>>((ref) {
  final center = ref.watch(coachingCenterProvider);
  if (center == null) return const Stream.empty();

  return FirebaseFirestore.instance
      .collection('students')
      .where('isApproved', isEqualTo: true)
      .where('coachingCenter', isEqualTo: center)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => StudentModel.fromFirestore(doc)).toList());
});

final pendingStudentsStreamProvider = StreamProvider<List<StudentModel>>((ref) {
  final center = ref.watch(coachingCenterProvider);
  if (center == null) return const Stream.empty();

  return FirebaseFirestore.instance
      .collection('students')
      .where('isApproved', isEqualTo: false)
      .where('coachingCenter', isEqualTo: center)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => StudentModel.fromFirestore(doc)).toList());
});

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void update(String value) => state = value;
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

class BatchFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void update(String? value) => state = value;
}

final batchFilterProvider = NotifierProvider<BatchFilterNotifier, String?>(BatchFilterNotifier.new);

class LevelFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void update(String? value) => state = value;
}

final levelFilterProvider = NotifierProvider<LevelFilterNotifier, String?>(LevelFilterNotifier.new);

class CourseFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void update(String? value) => state = value;
}

final courseFilterProvider = NotifierProvider<CourseFilterNotifier, String?>(CourseFilterNotifier.new);

final filteredStudentsProvider = Provider<AsyncValue<List<StudentModel>>>((ref) {
  final studentsAsync = ref.watch(studentsStreamProvider);
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase();
  final batchFilter = ref.watch(batchFilterProvider);
  final levelFilter = ref.watch(levelFilterProvider);
  final courseFilter = ref.watch(courseFilterProvider);

  return studentsAsync.whenData((students) {
    var filtered = students;
    if (levelFilter != null && levelFilter.isNotEmpty) {
      filtered = filtered.where((s) => s.level == levelFilter).toList();
    }
    if (courseFilter != null && courseFilter.isNotEmpty) {
      filtered = filtered.where((s) => s.course == courseFilter).toList();
    }
    if (batchFilter != null && batchFilter.isNotEmpty) {
      filtered = filtered.where((s) => s.displayBatch == batchFilter).toList();
    }
    if (searchQuery.isEmpty) return filtered;
    return filtered.where((student) {
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
