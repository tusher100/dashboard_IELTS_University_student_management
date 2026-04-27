import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/admin_provider.dart';
import '../models/models.dart';
import 'package:intl/intl.dart';

class StudentDirectory extends ConsumerWidget {
  const StudentDirectory({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(filteredStudentsProvider);

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Student Records',
                style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF1A202C)),
              ),
              const Spacer(),
              SizedBox(
                width: 300,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by name or mobile...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  onChanged: (val) => ref.read(searchQueryProvider.notifier).update(val),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: studentsAsync.when(
              data: (students) => _buildFullListView(context, students, ref),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullListView(BuildContext context, List<StudentModel> students, WidgetRef ref) {
    if (students.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('No students found', style: GoogleFonts.montserrat(color: Colors.grey, fontSize: 18)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        return _buildStudentCard(context, student, ref);
      },
    );
  }

  Widget _buildStudentCard(BuildContext context, StudentModel student, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFFE4284C).withOpacity(0.1),
                  child: Text(student.fullName[0], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFE4284C))),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(student.fullName, style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Enrolled on: ${DateFormat('dd MMMM yyyy').format(student.date)}', style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _confirmDelete(context, student, ref),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: 'Delete Record',
                ),
              ],
            ),
            const Divider(height: 32),
            Wrap(
              spacing: 48,
              runSpacing: 24,
              children: [
                _infoGroup('PERSONAL', [
                  _infoItem('Gender', student.gender),
                  _infoItem('DOB', DateFormat('dd-MM-yyyy').format(student.dob)),
                  _infoItem('Mobile', student.mobileNumber),
                  _infoItem('Email', student.email),
                ]),
                _infoGroup('EDUCATION', [
                  _infoItem('Institution', student.educationalInstitution),
                  _infoItem('Subject', student.subject),
                  _infoItem('R/A', student.ra),
                ]),
                _infoGroup('COURSE', [
                  _infoItem('Course Name', student.course),
                  _infoItem('Batch', student.batchName),
                  _infoItem('Time', student.time),
                  _infoItem('Duration', student.courseDuration),
                ]),
                _infoGroup('GUARDIAN', [
                  _infoItem('Guardian Name', student.guardianName),
                  _infoItem('Relation', student.relation),
                  _infoItem('Source', student.source),
                ]),
                _infoGroup('PAYMENT', [
                  _infoItem('Total Amount', 'Tk ${student.totalAmount.toStringAsFixed(0)}'),
                  _infoItem('Paid Amount', 'Tk ${student.paidAmount.toStringAsFixed(0)}'),
                  _infoItem('Discount', 'Tk ${student.discount.toStringAsFixed(0)}'),
                  _infoItem('Due Balance', 'Tk ${student.dueAmount.toStringAsFixed(0)}', 
                    valueColor: student.dueAmount > 0 ? Colors.red : Colors.green),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoGroup(String title, List<Widget> items) {
    return SizedBox(
      width: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
          const SizedBox(height: 8),
          ...items,
        ],
      ),
    );
  }

  Widget _infoItem(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.black38)),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: valueColor ?? Colors.black87)),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, StudentModel student, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Student?'),
        content: Text('Are you sure you want to delete the record for ${student.fullName}? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          TextButton(
            onPressed: () async {
              if (student.id != null) {
                await ref.read(adminProvider).deleteStudent(student.id!);
                if (context.mounted) Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Record for ${student.fullName} deleted')),
                );
              }
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
