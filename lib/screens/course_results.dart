import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/admin_provider.dart';
import '../models/models.dart';

class CourseResultsView extends ConsumerWidget {
  const CourseResultsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(studentsStreamProvider);

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Results by Course',
            style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF1A202C)),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: studentsAsync.when(
              data: (students) {
                final grouped = <String, List<StudentModel>>{};
                for (var s in students) {
                  grouped.putIfAbsent(s.course, () => []).add(s);
                }

                return ListView.builder(
                  itemCount: grouped.length,
                  itemBuilder: (context, index) {
                    final course = grouped.keys.elementAt(index);
                    final courseStudents = grouped[course]!;
                    return _buildCourseSection(course, courseStudents);
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
  }

  Widget _buildCourseSection(String course, List<StudentModel> students) {
    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      child: ExpansionTile(
        title: Text(course, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Text('${students.length} Students enrolled'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Table(
              border: TableBorder.symmetric(inside: const BorderSide(color: Colors.grey, width: 0.1)),
              children: [
                const TableRow(
                  children: [
                    Padding(padding: EdgeInsets.all(8), child: Text('NAME', style: TextStyle(fontWeight: FontWeight.bold))),
                    Padding(padding: EdgeInsets.all(8), child: Text('BATCH', style: TextStyle(fontWeight: FontWeight.bold))),
                    Padding(padding: EdgeInsets.all(8), child: Text('STATUS', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                ),
                ...students.map((s) => TableRow(
                  children: [
                    Padding(padding: EdgeInsets.all(8), child: Text(s.fullName)),
                    Padding(padding: EdgeInsets.all(8), child: Text(s.batchName)),
                    Padding(padding: EdgeInsets.all(8), child: Text(s.dueAmount > 0 ? 'Payment Pending' : 'Paid', 
                      style: TextStyle(color: s.dueAmount > 0 ? Colors.orange : Colors.green, fontSize: 12))),
                  ],
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
