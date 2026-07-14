import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';

/// Widget reusable: header section, mis. "Recently Played" + "View all"
class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onViewAll;

  const SectionHeader({
    super.key,
    required this.title,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.subheading),
        if (onViewAll != null)
          GestureDetector(
            onTap: onViewAll,
            child: Text('View all', style: AppTextStyles.link),
          ),
      ],
    );
  }
}
