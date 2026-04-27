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
                'Student Directory',
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
                  onChanged: (val) => ref.read(searchQueryProvider.notifier).state = val,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Card(
              child: studentsAsync.when(
                data: (students) => _buildTable(students, context),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err')),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(List<StudentModel> students, BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          headingRowHeight: 60,
          dataRowHeight: 70,
          columns: const [
            DataColumn(label: Text('DATE')),
            DataColumn(label: Text('NAME')),
            DataColumn(label: Text('MOBILE')),
            DataColumn(label: Text('COURSE')),
            DataColumn(label: Text('BATCH')),
            DataColumn(label: Text('DUE')),
            DataColumn(label: Text('GDR')),
            DataColumn(label: Text('INSTITUTION')),
          ],
          rows: students.map((student) {
            return DataRow(
              onSelectChanged: (_) => _showDetails(context, student),
              cells: [
                DataCell(Text(DateFormat('dd-MM-yy').format(student.date))),
                DataCell(Text(student.fullName, style: const TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text(student.mobileNumber)),
                DataCell(Text(student.course)),
                DataCell(Text(student.batchName)),
                DataCell(Text('Tk ${student.dueAmount.toStringAsFixed(0)}', 
                  style: TextStyle(color: student.dueAmount > 0 ? Colors.red : Colors.green, fontWeight: FontWeight.bold))),
                DataCell(Text(student.gender[0])),
                DataCell(Text(student.educationalInstitution)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showDetails(BuildContext context, StudentModel student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(student.fullName),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoTile('ID', student.id ?? 'N/A'),
              _infoTile('DOB', DateFormat('dd-MM-yyyy').format(student.dob)),
              _infoTile('Email', student.email),
              _infoTile('Time', student.time),
              _infoTile('Subject', student.subject),
              _infoTile('R/A', student.ra),
              _infoTile('Source', student.source),
              _infoTile('Guardian', '${student.guardianName} (${student.relation})'),
              _infoTile('Paid', 'Tk ${student.paidAmount}'),
              _infoTile('Total', 'Tk ${student.totalAmount}'),
              _infoTile('Discount', 'Tk ${student.discount}'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CLOSE')),
        ],
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black, fontSize: 14),
          children: [
            TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
