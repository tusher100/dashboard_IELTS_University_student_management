import 'package:flutter_riverpod/flutter_riverpod.dart';

enum DashboardSection { registration, receipts, students, results, settings }

class NavNotifier extends Notifier<DashboardSection> {
  @override
  DashboardSection build() => DashboardSection.registration;

  void setSection(DashboardSection section) => state = section;
}

final navProvider = NotifierProvider<NavNotifier, DashboardSection>(() {
  return NavNotifier();
});
