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
    return Scaffold(
      body: Row(
        children: [
          _buildSidebar(context),
          Expanded(
            child: Column(
              children: [
                _buildHeader(ref),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatsRow(ref),
                        const SizedBox(height: 32),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 2, child: _buildEnrollmentTable(ref)),
                            const SizedBox(width: 32),
                            Expanded(flex: 1, child: _buildReceiptSection(ref)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    const slateNavy = Color(0xFF1A202C);
    const primaryRed = Color(0xFFD81B60);

    return Container(
      width: 280,
      color: slateNavy,
      child: Column(
        children: [
          const SizedBox(height: 48),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryRed,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.school, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Text(
                  'IELTS UNIVERSITY',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          _buildSidebarItem(Icons.dashboard_rounded, 'Dashboard', true),
          _buildSidebarItem(Icons.people_alt_rounded, 'Students', false),
          _buildSidebarItem(Icons.receipt_long_rounded, 'Payments', false),
          _buildSidebarItem(Icons.settings_suggest_rounded, 'Settings', false),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: primaryRed, 
                    child: Text('A', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Admin User', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      Text('Master Account', style: GoogleFonts.montserrat(color: Colors.white54, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, String label, bool isActive) {
    const primaryRed = Color(0xFFD81B60);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: isActive ? primaryRed.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: Icon(icon, color: isActive ? primaryRed : Colors.white54),
          title: Text(
            label,
            style: GoogleFonts.montserrat(
              color: isActive ? Colors.white : Colors.white54,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
          onTap: () {},
        ),
      ),
    );
  }

  Widget _buildHeader(WidgetRef ref) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEDF2F7))),
      ),
      child: Row(
        children: [
          Text(
            'Enrollment Overview',
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A202C),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: 300,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search students...',
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true,
                fillColor: const Color(0xFFF7FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (val) => ref.read(searchQueryProvider.notifier).state = val,
            ),
          ),
          const SizedBox(width: 24),
          const Icon(Icons.notifications_none_rounded, color: Color(0xFF4A5568)),
        ],
      ),
    );
  }

  Widget _buildStatsRow(WidgetRef ref) {
    final studentsAsync = ref.watch(studentsStreamProvider);
    final count = studentsAsync.when(
      data: (d) => d.length.toString(), 
      loading: () => '...', 
      error: (_, __) => '0'
    );

    return Row(
      children: [
        _buildStatCard('Total Students', count, Icons.people_outline_rounded, Colors.blue),
        const SizedBox(width: 24),
        _buildStatCard('Active Courses', '12', Icons.book_outlined, Colors.purple),
        const SizedBox(width: 24),
        _buildStatCard('Monthly Revenue', '\$12,450', Icons.account_balance_wallet_outlined, Colors.green),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: GoogleFonts.montserrat(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(value, style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF1A202C))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnrollmentTable(WidgetRef ref) {
    final studentsAsync = ref.watch(filteredStudentsProvider);

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'Recent Enrollments',
              style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A202C)),
            ),
          ),
          studentsAsync.when(
            data: (students) => _buildActualTable(students, ref),
            loading: () => const Padding(padding: EdgeInsets.all(48.0), child: Center(child: CircularProgressIndicator())),
            error: (err, _) => Center(child: Text('Error: $err')),
          ),
        ],
      ),
    );
  }

  Widget _buildActualTable(List<StudentModel> students, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: DataTable(
        horizontalMargin: 24,
        headingRowHeight: 56,
        dataRowHeight: 72,
        headingTextStyle: GoogleFonts.montserrat(
          fontWeight: FontWeight.bold,
          color: Colors.black54,
          fontSize: 12,
          letterSpacing: 0.5,
        ),
        columns: const [
          DataColumn(label: Text('STUDENT')),
          DataColumn(label: Text('COURSE')),
          DataColumn(label: Text('PLAN')),
          DataColumn(label: Text('ACTIONS')),
        ],
        rows: students.map((student) {
          return DataRow(
            cells: [
              DataCell(
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: const Color(0xFFD81B60).withOpacity(0.1),
                      child: Text(student.fullName[0], style: const TextStyle(color: Color(0xFFD81B60), fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(student.fullName, style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 14)),
                        Text(student.mobileNumber, style: const TextStyle(color: Colors.black45, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              DataCell(Text(student.course, style: const TextStyle(fontSize: 13))),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    student.paymentPlan,
                    style: const TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              DataCell(
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onPressed: () => ref.read(selectedStudentProvider.notifier).update((s) => student),
                  color: const Color(0xFFD81B60),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReceiptSection(WidgetRef ref) {
    final selectedStudent = ref.watch(selectedStudentProvider);

    if (selectedStudent == null) {
      return Card(
        child: Container(
          height: 400,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.receipt_outlined, size: 64, color: Colors.black12),
              const SizedBox(height: 16),
              Text(
                'Select a student to view details',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(color: Colors.black38, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.sticky_note_2_rounded, color: Color(0xFFD81B60)),
                const SizedBox(width: 12),
                Text('Details', style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 32),
            _buildInfoRow('Name', selectedStudent.fullName),
            _buildInfoRow('Mobile', selectedStudent.mobileNumber),
            _buildInfoRow('Course', selectedStudent.course),
            _buildInfoRow('Payment', selectedStudent.paymentPlan),
            _buildInfoRow('Scholarship', selectedStudent.scholarship),
            _buildInfoRow('Amount', '\$${selectedStudent.amountPaid}'),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () => PdfService.generateAndPrintReceipt(selectedStudent),
              child: const Text('GENERATE PDF RECEIPT'),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => ref.read(selectedStudentProvider.notifier).update((s) => null),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('CLOSE'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.montserrat(color: Colors.black38, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1A202C))),
        ],
      ),
    );
  }
}
