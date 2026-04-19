import 'package:flutter_riverpod/flutter_riverpod.dart';

enum DashboardSection { dashboard, students, payments, settings }

class NavNotifier extends Notifier<DashboardSection> {
  @override
  DashboardSection build() => DashboardSection.dashboard;

  void setSection(DashboardSection section) => state = section;
}

final navProvider = NotifierProvider<NavNotifier, DashboardSection>(() {
  return NavNotifier();
});
