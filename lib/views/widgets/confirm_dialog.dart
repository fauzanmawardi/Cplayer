import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';

/// Dialog konfirmasi reusable, dipakai sebelum aksi yang tidak bisa
/// dibatalkan (mis. hapus lagu/video dari library).
/// Return true kalau user menekan tombol konfirmasi (mis. "Hapus").
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Hapus',
  String cancelLabel = 'Batal',
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(title, style: AppTextStyles.subheading),
      content: Text(message, style: AppTextStyles.caption),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel,
              style: AppTextStyles.body
                  .copyWith(color: AppColors.textSecondary)),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel,
              style: AppTextStyles.body.copyWith(color: AppColors.favorite)),
        ),
      ],
    ),
  );
  return result ?? false;
}