import 'package:flutter/material.dart';
import '../main.dart';
import '../services/job_store.dart';

/// Shared role navigation for the employee, employer, and admin shells.
///
/// Keeping the same switcher in each shell makes every role reachable from
/// every other role, while the compact trigger keeps the menu usable on small
/// phones.
class RoleSwitcher extends StatelessWidget {
  const RoleSwitcher({super.key, required this.store});

  final JobStore store;

  @override
  Widget build(BuildContext context) {
    // The app presents its mobile layout in a 430px frame on larger screens,
    // so switch to the compact trigger for that frame as well as small phones.
    final compact = MediaQuery.sizeOf(context).width < 600;

    return PopupMenuButton<String>(
      tooltip: 'Ganti mode aplikasi',
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 6,
      shadowColor: plum.withValues(alpha: 0.12),
      offset: const Offset(0, 8),
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: line),
      ),
      onSelected: (role) => store.setActiveRole(role),
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 'employee',
          height: 50,
          child: Row(
            children: [
              Icon(Icons.person_search_rounded, size: 19, color: plum),
              SizedBox(width: 10),
              Text('Hiree', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'employer',
          height: 50,
          child: Row(
            children: [
              Icon(Icons.business_center_outlined, size: 19, color: plum),
              SizedBox(width: 10),
              Text('Hirer', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'admin',
          height: 50,
          child: Row(
            children: [
              Icon(Icons.admin_panel_settings_outlined, size: 19, color: plum),
              SizedBox(width: 10),
              Text('Admin', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ],
      child: Container(
        constraints: BoxConstraints(minWidth: compact ? 40 : 0, minHeight: 40),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 10 : 11,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          color: lavender.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: compact
            ? const Icon(Icons.swap_horiz_rounded, size: 20, color: plum)
            : const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.swap_horiz_rounded, size: 16, color: plum),
                  SizedBox(width: 5),
                  Text(
                    'Switch Mode',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: plum,
                    ),
                  ),
                  SizedBox(width: 3),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: plum,
                  ),
                ],
              ),
      ),
    );
  }
}
