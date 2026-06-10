import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/admin_provider.dart';
import '../models/models.dart';

class AnalyticsView extends ConsumerWidget {
  const AnalyticsView({super.key});

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
                  'Business Analytics',
                  style: GoogleFonts.montserrat(
                    fontSize: 20, 
                    fontWeight: FontWeight.bold, 
                    color: const Color(0xFF1A202C)
                  ),
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
                          'Business Analytics',
                          style: GoogleFonts.montserrat(
                            fontSize: 24, 
                            fontWeight: FontWeight.bold, 
                            color: const Color(0xFF1A202C)
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
              studentsAsync.when(
                data: (students) => Expanded(child: _buildDashboard(students, isMobile)),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err')),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDashboard(List<StudentModel> students, bool isMobile) {
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
        if (isMobile) ...[
          _buildMetricCard('Total Students', totalStudents.toString(), Icons.people, Colors.blue),
          const SizedBox(height: 16),
          _buildMetricCard('Total Revenue', 'Tk ${totalRevenue.toStringAsFixed(0)}', Icons.payments, Colors.green),
        ] else
          Row(
            children: [
              Expanded(child: _buildMetricCard('Total Students', totalStudents.toString(), Icons.people, Colors.blue)),
              const SizedBox(width: 24),
              Expanded(child: _buildMetricCard('Total Revenue', 'Tk ${totalRevenue.toStringAsFixed(0)}', Icons.payments, Colors.green)),
            ],
          ),
        const SizedBox(height: 32),
        Expanded(
          child: Card(
             margin: EdgeInsets.zero,
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
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
                          contentPadding: EdgeInsets.zero,
                          title: Text(course, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          subtitle: Text('${stat.studentCount} Students', style: const TextStyle(fontSize: 11)),
                          trailing: Text('Tk ${stat.revenue.toStringAsFixed(0)}', 
                            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14)),
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
    return Container(
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
    );
  }
}

class _CourseStat {
  int studentCount = 0;
  double revenue = 0;
}
