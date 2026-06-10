import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../providers/admin_provider.dart';
import '../services/pdf_service.dart';
import 'registration_form.dart';

class StudentDirectory extends ConsumerWidget {
  const StudentDirectory({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(filteredStudentsProvider);
    final rawStudentsAsync = ref.watch(studentsStreamProvider);
    
    final List<String> batches = [];
    final List<String> levels = [];
    final List<String> courses = [];
    
    rawStudentsAsync.whenData((students) {
      batches.addAll(students.map((e) => e.displayBatch).where((b) => b.isNotEmpty).toSet().toList()..sort());
      levels.addAll(students.map((e) => e.level).where((l) => l != 'None').toSet().toList()..sort());
      courses.addAll(students.map((e) => e.displayCourse).toSet().toList()..sort());
    });

    final currentBatch = ref.watch(batchFilterProvider);
    final currentLevel = ref.watch(levelFilterProvider);
    final currentCourse = ref.watch(courseFilterProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 800;

        Widget buildDropdown(String hint, String? value, List<String> items, Function(String?) onChanged) {
          return SizedBox(
            width: isMobile ? double.infinity : 200,
            child: DropdownButtonFormField<String>(
              value: value,
              isExpanded: true,
              hint: Text(hint),
              items: [
                DropdownMenuItem<String>(value: null, child: Text(hint, overflow: TextOverflow.ellipsis)),
                ...items.map((i) => DropdownMenuItem(value: i, child: Text(i, overflow: TextOverflow.ellipsis))),
              ],
              onChanged: onChanged,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              ),
            ),
          );
        }

        return Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isMobile) ...[
                Text(
                  'Student Records',
                  style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1A202C)),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  onChanged: (val) => ref.read(searchQueryProvider.notifier).update(val),
                ),
                const SizedBox(height: 16),
                buildDropdown('All Levels', currentLevel, levels, (v) => ref.read(levelFilterProvider.notifier).update(v)),
                const SizedBox(height: 8),
                buildDropdown('All Courses', currentCourse, courses, (v) => ref.read(courseFilterProvider.notifier).update(v)),
                const SizedBox(height: 8),
                buildDropdown('All Batches', currentBatch, batches, (v) => ref.read(batchFilterProvider.notifier).update(v)),
              ] else
                Column(
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
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (levels.isNotEmpty) ...[
                          buildDropdown('All Levels', currentLevel, levels, (v) => ref.read(levelFilterProvider.notifier).update(v)),
                          const SizedBox(width: 16),
                        ],
                        buildDropdown('All Courses', currentCourse, courses, (v) => ref.read(courseFilterProvider.notifier).update(v)),
                        const SizedBox(width: 16),
                        buildDropdown('All Batches', currentBatch, batches, (v) => ref.read(batchFilterProvider.notifier).update(v)),
                      ],
                    ),
                  ],
                ),
              const SizedBox(height: 32),
              Expanded(
                child: studentsAsync.when(
                  data: (students) => _buildFullListView(context, students, ref, isMobile),
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

  Widget _buildFullListView(BuildContext context, List<StudentModel> students, WidgetRef ref, bool isMobile) {
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
        return _buildStudentCard(context, student, ref, isMobile);
      },
    );
  }

  Widget _buildStudentCard(BuildContext context, StudentModel student, WidgetRef ref, bool isMobile) {
    final coachingCenter = ref.watch(coachingCenterProvider) ?? 'IELTS University';
    final primaryColor = coachingCenter == 'IELTS University' ? const Color(0xFFD81B60) : const Color(0xFF38A169);

    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: isMobile ? 24 : 30,
                  backgroundColor: primaryColor.withOpacity(0.1),
                  child: Text(student.fullName[0], style: TextStyle(fontSize: isMobile ? 18 : 24, fontWeight: FontWeight.bold, color: primaryColor)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(student.fullName, style: GoogleFonts.montserrat(fontSize: isMobile ? 16 : 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Enrolled: ${DateFormat('dd MMM yy').format(student.date)}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
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
              spacing: isMobile ? 16 : 48,
              runSpacing: 24,
              children: [
                _infoGroup('PERSONAL', [
                  _infoItem('Gender', student.gender),
                  _infoItem('DOB', DateFormat('dd-MM-yyyy').format(student.dob)),
                  _infoItem('Mobile', student.mobileNumber),
                  _infoItem('Email', student.email),
                ], isMobile),
                _infoGroup('EDUCATION', [
                  _infoItem('Institution', student.educationalInstitution),
                  _infoItem('Subject', student.subject),
                  _infoItem('R/A', student.ra),
                ], isMobile),
                _infoGroup('COURSE', [
                  _infoItem('Course Name', student.course),
                  _infoItem('Batch', student.batchName),
                  _infoItem('Time', student.time),
                  _infoItem('Duration', student.courseDuration),
                ], isMobile),
                _infoGroup('GUARDIAN', [
                  _infoItem('Guardian Name', student.guardianName),
                  _infoItem('Relation', student.relation),
                  _infoItem('Source', student.source),
                ], isMobile),
                _infoGroup('PAYMENT', [
                  _infoItem('Total Amount', 'Tk ${student.totalAmount.toStringAsFixed(0)}'),
                  _infoItem('Paid Amount', 'Tk ${student.paidAmount.toStringAsFixed(0)}'),
                  _infoItem('Discount', 'Tk ${student.discount.toStringAsFixed(0)}'),
                  _infoItem('Due Balance', 'Tk ${(student.dueAmount < 0 ? 0 : student.dueAmount).toStringAsFixed(0)}', 
                    valueColor: student.dueAmount > 0 ? primaryColor : Colors.green),
                ], isMobile),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => Dialog(
                          insetPadding: EdgeInsets.all(isMobile ? 16 : 48),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Scaffold(
                              appBar: AppBar(
                                title: const Text('Edit Student'),
                                leading: IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ),
                              body: RegistrationForm(studentToEdit: student),
                            ),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryColor,
                      side: BorderSide(color: primaryColor),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showCollectFeeDialog(context, student, ref),
                    icon: const Icon(Icons.payment, size: 18),
                    label: const Text('Collect Fee'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoGroup(String title, List<Widget> items, bool isMobile) {
    return SizedBox(
      width: isMobile ? 140 : 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
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
        content: SizedBox(
          width: 500,
          child: Text('Are you sure you want to delete the record for ${student.fullName}? This action cannot be undone.'),
        ),
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

  void _showCollectFeeDialog(BuildContext context, StudentModel student, WidgetRef ref) {
    final coachingCenter = ref.read(coachingCenterProvider) ?? 'IELTS University';
    final primaryColor = coachingCenter == 'IELTS University' ? const Color(0xFFD81B60) : const Color(0xFF38A169);

    String? selectedMonth;
    final List<String> months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Collect Monthly Fee', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Text('Student: ${student.fullName}', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('Course: ${student.course}'),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedMonth,
                decoration: const InputDecoration(labelText: 'Payment Month', border: OutlineInputBorder()),
                items: months.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                onChanged: (val) => setState(() => selectedMonth = val),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount (Tk)', border: OutlineInputBorder()),
              ),
            ],
          ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(amountController.text) ?? 0;
                if (selectedMonth != null && amount > 0) {
                  final newRecord = PaymentRecord(
                    title: '$selectedMonth Month',
                    amount: amount,
                    date: DateTime.now(),
                  );
                
                  double newDue = student.dueAmount - amount;
                  if (newDue < 0) newDue = 0;

                  final updatedStudent = student.copyWith(
                    paidAmount: student.paidAmount + amount,
                    dueAmount: newDue,
                    paymentHistory: [...student.paymentHistory, newRecord],
                  );

                await ref.read(adminActionProvider.notifier).updateStudent(updatedStudent);
                if (context.mounted) Navigator.pop(context);

                ref.read(isPdfGeneratingProvider.notifier).update(true);
                try {
                  await PdfService.generateReceipt(updatedStudent);
                } finally {
                  ref.read(isPdfGeneratingProvider.notifier).update(false);
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white),
            child: const Text('Save & Print Receipt'),
          ),
        ],
      ),
    ));
  }
}
