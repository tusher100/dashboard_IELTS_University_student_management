import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/admin_provider.dart';
import '../models/models.dart';
import '../services/pdf_service.dart';

class ReceiptsView extends ConsumerWidget {
  const ReceiptsView({super.key});

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
                'Generate Receipts',
                style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF1A202C)),
              ),
              const Spacer(),
              SizedBox(
                width: 300,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search student...',
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
            child: studentsAsync.when(
              data: (students) => _buildReceiptList(students, ref),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptList(List<StudentModel> students, WidgetRef ref) {
    return ListView.separated(
      itemCount: students.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final student = students[index];
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.receipt)),
          title: Text(student.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('${student.course} - Batch: ${student.batchName}'),
          trailing: ElevatedButton.icon(
            onPressed: () => PdfService.generateAndPrintReceipt(student),
            icon: const Icon(Icons.print, size: 18),
            label: const Text('PRINT RECEIPT'),
          ),
        );
      },
    );
  }
}
