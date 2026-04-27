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

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 800;

        return Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isMobile) ...[
                Text(
                  'Generate Receipts',
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
              ] else
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
                        onChanged: (val) => ref.read(searchQueryProvider.notifier).update(val),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 32),
              Expanded(
                child: studentsAsync.when(
                  data: (students) => _buildReceiptList(students, ref, isMobile),
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

  Widget _buildReceiptList(List<StudentModel> students, WidgetRef ref, bool isMobile) {
    return ListView.separated(
      itemCount: students.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final student = students[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: Colors.blue.withOpacity(0.1),
            child: const Icon(Icons.receipt, color: Colors.blue)
          ),
          title: Text(student.fullName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 14 : 16)),
          subtitle: Text('${student.course}\nBatch: ${student.batchName}', style: const TextStyle(fontSize: 12)),
          trailing: isMobile 
            ? IconButton(
                onPressed: () => PdfService.generateAndPrintReceipt(student),
                icon: const Icon(Icons.print, color: Colors.blue),
              )
            : ElevatedButton.icon(
                onPressed: () => PdfService.generateAndPrintReceipt(student),
                icon: const Icon(Icons.print, size: 18),
                label: const Text('PRINT RECEIPT'),
              ),
        );
      },
    );
  }
}
