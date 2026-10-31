import 'package:flutter/material.dart';
import '../services/job_store.dart';
import 'role_selection.dart';

export 'role_selection.dart';

/// Legacy compatibility wrapper: Onboarding now renders the Role Selection Menu.
class Onboarding extends StatelessWidget {
  const Onboarding({super.key, required this.store});
  final JobStore store;

  @override
  Widget build(BuildContext context) => RoleSelectionScreen(store: store);
}
