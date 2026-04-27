import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/nav_provider.dart';
import '../providers/auth_provider.dart';
import 'registration_form.dart';
import 'receipts_view.dart';
import 'student_directory.dart';
import 'course_results.dart';
import 'analytics_view.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSection = ref.watch(navProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      body: Row(
        children: [
          _buildSidebar(context, ref),
          Expanded(
            child: Column(
              children: [
                _buildHeader(ref, currentSection),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildSectionContent(ref, currentSection),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionContent(WidgetRef ref, DashboardSection section) {
    switch (section) {
      case DashboardSection.registration:
        return const RegistrationForm(key: ValueKey('registration'));
      case DashboardSection.receipts:
        return const ReceiptsView(key: ValueKey('receipts'));
      case DashboardSection.students:
        return const StudentDirectory(key: ValueKey('students'));
      case DashboardSection.results:
        return const CourseResultsView(key: ValueKey('results'));
      case DashboardSection.analytics:
        return const AnalyticsView(key: ValueKey('analytics'));
      case DashboardSection.settings:
        return _buildSettingsView(ref);
    }
  }

  Widget _buildSidebar(BuildContext context, WidgetRef ref) {
    const slateNavy = Color(0xFF1A202C);
    const primaryRed = Color(0xFFE4284C);
    final currentSection = ref.watch(navProvider);

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
                Expanded(
                  child: Text(
                    'IELTS UNIVERSITY',
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      letterSpacing: 1.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          _buildSidebarItem(ref, Icons.app_registration_rounded, 'Registration', DashboardSection.registration, currentSection == DashboardSection.registration),
          _buildSidebarItem(ref, Icons.receipt_long_rounded, 'Receipts', DashboardSection.receipts, currentSection == DashboardSection.receipts),
          _buildSidebarItem(ref, Icons.people_alt_rounded, 'Directory', DashboardSection.students, currentSection == DashboardSection.students),
          _buildSidebarItem(ref, Icons.bar_chart_rounded, 'Results', DashboardSection.results, currentSection == DashboardSection.results),
          _buildSidebarItem(ref, Icons.insights_rounded, 'Analytics', DashboardSection.analytics, currentSection == DashboardSection.analytics),
          _buildSidebarItem(ref, Icons.settings_suggest_rounded, 'Settings', DashboardSection.settings, currentSection == DashboardSection.settings),
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Admin User', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13), overflow: TextOverflow.ellipsis),
                        Text('Master Account', style: GoogleFonts.montserrat(color: Colors.white54, fontSize: 11), overflow: TextOverflow.ellipsis),
                      ],
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

  Widget _buildSidebarItem(WidgetRef ref, IconData icon, String label, DashboardSection section, bool isActive) {
    const primaryRed = Color(0xFFE4284C);
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
          onTap: () => ref.read(navProvider.notifier).setSection(section),
        ),
      ),
    );
  }

  Widget _buildHeader(WidgetRef ref, DashboardSection section) {
    String title;
    switch (section) {
      case DashboardSection.registration: title = 'Student Registration'; break;
      case DashboardSection.receipts: title = 'Payments & Receipts'; break;
      case DashboardSection.students: title = 'Student Directory'; break;
      case DashboardSection.results: title = 'Course Results'; break;
      case DashboardSection.analytics: title = 'System Analytics'; break;
      case DashboardSection.settings: title = 'System Settings'; break;
    }

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
            title,
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A202C),
            ),
          ),
          const Spacer(),
          const Icon(Icons.notifications_none_rounded, color: Color(0xFF4A5568)),
          const SizedBox(width: 24),
          IconButton(
            onPressed: () => ref.read(authProvider.notifier).logout(),
            icon: const Icon(Icons.logout, color: Colors.redAccent),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsView(WidgetRef ref) {
    return Center(
      key: const ValueKey('settings'),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 64,
              backgroundColor: Color(0xFF1A202C),
              child: Icon(Icons.person, color: Colors.white, size: 64),
            ),
            const SizedBox(height: 24),
            Text('Admin Authority', style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.bold)),
            const Text('Super Admin Role', style: TextStyle(color: Colors.black45)),
            const SizedBox(height: 48),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('Change Security Password'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.color_lens_outlined),
              title: const Text('Dashboard Theme'),
              trailing: const Text('Light Mode'),
              onTap: () {},
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () => ref.read(authProvider.notifier).logout(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.1),
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                minimumSize: const Size(double.infinity, 56),
              ),
              child: const Text('LOGOUT FROM SYSTEM'),
            ),
          ],
        ),
      ),
    );
  }
}

