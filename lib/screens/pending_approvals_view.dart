import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/admin_provider.dart';
import '../models/models.dart';

class PendingApprovalsView extends ConsumerWidget {
  const PendingApprovalsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingStudentsStreamProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 800;

        return Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Registration Approvals',
                style: GoogleFonts.montserrat(
                  fontSize: isMobile ? 20 : 24, 
                  fontWeight: FontWeight.bold, 
                  color: const Color(0xFF1A202C)
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: pendingAsync.when(
                  data: (students) => _buildPendingList(context, students, ref, isMobile),
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

  Widget _buildPendingList(BuildContext context, List<StudentModel> students, WidgetRef ref, bool isMobile) {
    if (students.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
            const SizedBox(height: 16),
            Text('No pending approvals', style: GoogleFonts.montserrat(color: Colors.grey, fontSize: 18)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange.withOpacity(0.1),
                    child: const Icon(Icons.pending, color: Colors.orange),
                  ),
                  title: Text(student.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Mobile: ${student.mobileNumber} | Course: ${student.course}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: () => _showDetails(context, student),
                        child: const Text('DETAILS'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _approveStudent(context, ref, student),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        child: const Text('APPROVE'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDetails(BuildContext context, StudentModel student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(student.fullName, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _detailRow('Email', student.email),
                _detailRow('Gender', student.gender),
                _detailRow('DOB', DateFormat('dd-MM-yyyy').format(student.dob)),
                _detailRow('Institution', student.educationalInstitution),
                _detailRow('Subject', student.subject),
                _detailRow('Batch', student.batchName),
                _detailRow('Preferred Time', student.time),
                _detailRow('Guardian', student.guardianName),
                _detailRow('Relation', student.relation),
                const Divider(height: 32),
                _detailRow('Total Fee', 'Tk ${student.totalAmount}'),
                _detailRow('Paid Amount', 'Tk ${student.paidAmount}'),
                _detailRow('Discount', 'Tk ${student.discount}'),
                _detailRow('Due Balance', 'Tk ${student.dueAmount}', color: Colors.red),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CLOSE')),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Future<void> _approveStudent(BuildContext context, WidgetRef ref, StudentModel student) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Approval'),
        content: Text('Are you sure you want to approve registration for ${student.fullName}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('APPROVE', style: TextStyle(color: Colors.green))),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(adminActionProvider.notifier).approveStudent(student);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${student.fullName} has been approved and added to directory.')),
        );
      }
    }
  }
}
