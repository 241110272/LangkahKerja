import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../main.dart';

/// The employee workspace uses the available tablet/desktop width. Other roles
/// retain the team's original mobile presentation.
class AdaptiveViewport extends StatelessWidget {
  const AdaptiveViewport({
    super.key,
    required this.expanded,
    required this.child,
  });
  final bool expanded;
  final Widget child;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      if (box.maxWidth < 600) return child;
      final inset = box.maxHeight < 500 ? 0.0 : 16.0;
      final width = math.min(
        expanded ? 1180.0 : 430.0,
        box.maxWidth - inset * 2,
      );
      final height = math.max(0.0, box.maxHeight - inset * 2);
      return DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF1ECF9), Color(0xFFE2D7F1), Color(0xFFF4EFF8)],
          ),
        ),
        child: Center(
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(inset == 0 ? 0 : 24),
              boxShadow: [
                BoxShadow(color: plum.withValues(alpha: .12), blurRadius: 40),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(size: Size(width, height)),
              child: child,
            ),
          ),
        ),
      );
    },
  );
}
