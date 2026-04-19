import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../providers/admin_provider.dart';
import '../services/pdf_service.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const primaryRed = Color(0xFFD81B60);

    return Scaffold(
      appBar: AppBar(
        title: Text('IELTS University Admin Dashboard', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        backgroundColor: primaryRed,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(child: Text('Admin Control Panel', style: GoogleFonts.montserrat())),
          ),
        ],
      ),
      body: Row(
        children: [
          // Left Panel: Data Table
          Expanded(
            flex: 3,
            child: _buildLeftPanel(ref),
          ),
          const VerticalDivider(width: 1),
          // Right Panel: Receipt Preview
          Expanded(
            flex: 2,
            child: _buildRightPanel(ref),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftPanel(WidgetRef ref) {
    final studentsAsync = ref.watch(filteredStudentsProvider);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchBar(ref),
          const SizedBox(height: 24),
          Expanded(
            child: studentsAsync.when(
              data: (students) => _buildDataTable(students, ref),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(WidgetRef ref) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search by Student Name or Mobile...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      onChanged: (val) => ref.read(searchQueryProvider.notifier).state = val,
    );
  }

  Widget _buildDataTable(List<StudentModel> students, WidgetRef ref) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Full Name')),
            DataColumn(label: Text('Mobile')),
            DataColumn(label: Text('Course')),
            DataColumn(label: Text('Actions')),
          ],
          rows: students.map((student) {
            return DataRow(
              cells: [
                DataCell(Text(student.fullName)),
                DataCell(Text(student.mobileNumber)),
                DataCell(Text(student.course)),
                DataCell(
                  ElevatedButton.icon(
                    onPressed: () => ref.read(selectedStudentProvider.notifier).update((state) => student),
                    icon: const Icon(Icons.receipt_long, size: 18),
                    label: const Text('View Receipt'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildRightPanel(WidgetRef ref) {
    final selectedStudent = ref.watch(selectedStudentProvider);

    if (selectedStudent == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('Select a student to preview receipt', style: GoogleFonts.montserrat(color: Colors.grey[600])),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Receipt Preview', style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text('IELTS UNIVERSITY', style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFFD81B60))),
                  ),
                  const Divider(height: 40),
                  _buildPreviewRow('Student Name', selectedStudent.fullName),
                  _buildPreviewRow('Course', selectedStudent.course),
                  _buildPreviewRow('Amount Paid', '\$${selectedStudent.amountPaid.toStringAsFixed(2)}'),
                  _buildPreviewRow('Payment Plan', selectedStudent.paymentPlan),
                  _buildPreviewRow('Scholarship', selectedStudent.scholarship),
                  const Spacer(),
                  const Divider(),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => PdfService.generateAndPrintReceipt(selectedStudent),
                    icon: const Icon(Icons.print),
                    label: const Text('Print Official Receipt'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      backgroundColor: const Color(0xFFD81B60),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black54)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
