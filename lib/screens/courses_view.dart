import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/admin_provider.dart';
import '../models/models.dart';

class CoursesView extends ConsumerWidget {
  const CoursesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(coursesStreamProvider);
    final coachingCenter = ref.watch(coachingCenterProvider) ?? 'IELTS University';
    final isIelts = coachingCenter == 'IELTS University';
    final primaryColor = isIelts ? const Color(0xFFE4284C) : const Color(0xFF38A169);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 800;

        return Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Manage Courses',
                    style: GoogleFonts.montserrat(fontSize: isMobile ? 20 : 24, fontWeight: FontWeight.bold, color: const Color(0xFF1A202C)),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showCourseDialog(context, ref, null),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Course'),
                    style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white),
                  )
                ],
              ),
              const SizedBox(height: 32),
              Expanded(
                child: coursesAsync.when(
                  data: (courses) {
                    if (courses.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('No courses found.'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => _migrateLegacyCourses(ref, coachingCenter),
                              child: const Text('Import Default Courses'),
                            )
                          ],
                        ),
                      );
                    }
                    return ListView.separated(
                      itemCount: courses.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final course = courses[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: primaryColor.withOpacity(0.1),
                            child: Icon(Icons.book, color: primaryColor),
                          ),
                          title: Text(course.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Fee: Tk ${course.price} | Admission: Tk ${course.admissionFee} | Duration: ${course.duration} | Level: ${course.level}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _showCourseDialog(context, ref, course),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Course'),
                                      content: const Text('Are you sure you want to delete this course?'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                                        TextButton(
                                          onPressed: () {
                                            ref.read(adminActionProvider.notifier).deleteCourse(course.id!);
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(child: Text('Error: $err')),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCourseDialog(BuildContext context, WidgetRef ref, CourseModel? courseToEdit) {
    final titleController = TextEditingController(text: courseToEdit?.title ?? '');
    final priceController = TextEditingController(text: courseToEdit?.price.toString() ?? '');
    final admissionFeeController = TextEditingController(text: courseToEdit?.admissionFee.toString() ?? '');
    final durationController = TextEditingController(text: courseToEdit?.duration ?? '');
    String selectedLevel = courseToEdit?.level ?? 'None';
    final coachingCenter = ref.read(coachingCenterProvider) ?? 'IELTS University';
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(courseToEdit == null ? 'Add Course' : 'Edit Course'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Course Name')),
                  const SizedBox(height: 16),
                  TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Course Fee (Tk)'), keyboardType: TextInputType.number),
                  const SizedBox(height: 16),
                  TextField(controller: admissionFeeController, decoration: const InputDecoration(labelText: 'Admission Fee (Tk)'), keyboardType: TextInputType.number),
                  const SizedBox(height: 16),
                  TextField(controller: durationController, decoration: const InputDecoration(labelText: 'Duration (e.g. Monthly, 3 month)')),
                  const SizedBox(height: 16),
                  if (coachingCenter == 'Ignite Academic')
                    DropdownButtonFormField<String>(
                      value: selectedLevel,
                      decoration: const InputDecoration(labelText: 'Level'),
                      items: ['None', 'SSC', 'HSC'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (val) => setState(() => selectedLevel = val!),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final newCourse = CourseModel(
                  id: courseToEdit?.id,
                  title: titleController.text,
                  price: int.tryParse(priceController.text) ?? 0,
                  admissionFee: int.tryParse(admissionFeeController.text) ?? 0,
                  duration: durationController.text,
                  coachingCenter: coachingCenter,
                  level: coachingCenter == 'IELTS University' ? 'None' : selectedLevel,
                );
                
                if (courseToEdit == null) {
                  ref.read(adminActionProvider.notifier).addCourse(newCourse);
                } else {
                  ref.read(adminActionProvider.notifier).updateCourse(newCourse);
                }
                Navigator.pop(context);
              },
              child: const Text('Save'),
            )
          ],
        ),
      ),
    );
  }

  void _migrateLegacyCourses(WidgetRef ref, String center) {
    if (center == 'IELTS University') {
      const ieltsCourses = {
        'Pre-IELTS Care': {'price': 12900, 'duration': '3.5 month'},
        'Spoken+Computer Basic': {'price': 3900, 'duration': ''},
        'Spoken': {'price': 2000, 'duration': ''},
        'Computer Basic': {'price': 2000, 'duration': ''},
        'IELTS Pre': {'price': 8900, 'duration': '3 month'},
        'IELTS Rapid': {'price': 7900, 'duration': '45 days'},
        'ICT+English': {'price': 3900, 'duration': ''},
        'ICT': {'price': 3000, 'duration': ''},
        'English': {'price': 3000, 'duration': ''},
        'Mock Test': {'price': 500, 'duration': ''},
        'IELTS Exam Batch': {'price': 2000, 'duration': '4 mock test'},
        'One to One': {'price': 12000, 'duration': 'monthly'},
        'Kids Spoken': {'price': 1000, 'duration': 'admission fee'},
        'Kids Spoken Monthly': {'price': 1500, 'duration': 'monthly fee'},
      };
      
      ieltsCourses.forEach((title, data) {
        ref.read(adminActionProvider.notifier).addCourse(CourseModel(
          title: title,
          price: data['price'] as int,
          duration: data['duration'] as String,
          coachingCenter: center,
          level: 'None'
        ));
      });
    } else {
      const hscCourses = {
        'Exam Batch': {'price': 2000, 'duration': 'Monthly', 'admissionFee': 1000},
        'Monthly Care': {'price': 1500, 'duration': 'Monthly', 'admissionFee': 1000},
        'Combo Course (ICT + English)': {'price': 3000, 'duration': 'Monthly', 'admissionFee': 1000},
      };
      
      const sscCourses = {
        'Exam Batch': {'price': 1500, 'duration': 'Monthly', 'admissionFee': 1000},
        'Monthly Care': {'price': 1000, 'duration': 'Monthly', 'admissionFee': 1000},
      };
      
      hscCourses.forEach((title, data) {
        ref.read(adminActionProvider.notifier).addCourse(CourseModel(
          title: title,
          price: data['price'] as int,
          admissionFee: data['admissionFee'] as int,
          duration: data['duration'] as String,
          coachingCenter: center,
          level: 'HSC'
        ));
      });
      
      sscCourses.forEach((title, data) {
        ref.read(adminActionProvider.notifier).addCourse(CourseModel(
          title: title,
          price: data['price'] as int,
          admissionFee: data['admissionFee'] as int,
          duration: data['duration'] as String,
          coachingCenter: center,
          level: 'SSC'
        ));
      });
    }
  }
}
