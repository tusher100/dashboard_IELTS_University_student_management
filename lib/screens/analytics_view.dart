import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/admin_provider.dart';
import '../models/models.dart';

class AnalyticsView extends ConsumerWidget {
  const AnalyticsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(studentsStreamProvider);

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Business Analytics',
            style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF1A202C)),
          ),
          const SizedBox(height: 32),
          studentsAsync.when(
            data: (students) => Expanded(child: _buildDashboard(students)),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error: $err')),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard(List<StudentModel> students) {
    final totalRevenue = students.fold<double>(0, (sum, s) => sum + s.paidAmount);
    final totalStudents = students.length;

    // Grouping by course
    final courseStats = <String, _CourseStat>{};
    for (var s in students) {
      final stat = courseStats.putIfAbsent(s.course, () => _CourseStat());
      stat.studentCount++;
      stat.revenue += s.paidAmount;
    }

    return Column(
      children: [
        Row(
          children: [
            _buildMetricCard('Total Students', totalStudents.toString(), Icons.people, Colors.blue),
            const SizedBox(width: 24),
            _buildMetricCard('Total Revenue', 'Tk ${totalRevenue.toStringAsFixed(0)}', Icons.payments, Colors.green),
          ],
        ),
        const SizedBox(height: 32),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Revenue by Course', style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: courseStats.length,
                      itemBuilder: (context, index) {
                        final course = courseStats.keys.elementAt(index);
                        final stat = courseStats[course]!;
                        return ListTile(
                          title: Text(course, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${stat.studentCount} Students'),
                          trailing: Text('Tk ${stat.revenue.toStringAsFixed(0)}', 
                            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 4),
                Text(value, style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseStat {
  int studentCount = 0;
  double revenue = 0;
}
