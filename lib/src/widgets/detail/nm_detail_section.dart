import 'package:flutter/material.dart';

import '../../theme/nm_theme.dart';

/// Bordered section container used in the detail/overview screens.
class NmDetailSection extends StatelessWidget {
  final String title;
  final Color? titleColor;
  final List<Widget> children;

  const NmDetailSection({
    super.key,
    required this.title,
    required this.children,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: NmTheme.fieldBackground(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: NmTheme.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: NmTextStyles.bold14(context).copyWith(
              color: titleColor ?? NmTheme.onSurface(context),
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

/// Vertical spacing between detail sections.
class NmDetailGap extends StatelessWidget {
  const NmDetailGap({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox(height: 12);
}
