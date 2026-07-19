import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/settings_controller.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../controllers/background_controller.dart';

/// View: halaman Settings (Theme, Language, Playback, Equalizer, About, dll).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
        children: [
          Row(
            children: [
              const Icon(Icons.chevron_left, color: AppColors.textPrimary),
              const SizedBox(width: 4),
              Text('Settings', style: AppTextStyles.heading),
            ],
          ),
          const SizedBox(height: 20),

          // ---------- Info app ----------
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.play_circle_fill, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cplayer', style: AppTextStyles.subheading),
                  Text('Enjoy your every moment', style: AppTextStyles.caption),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          Text('General',
              style: AppTextStyles.caption.copyWith(color: AppColors.accent)),
          const SizedBox(height: 4),
          _SettingsTile(
          icon: Icons.dark_mode_outlined,
          label: 'Theme',
          value: settings.isDarkMode ? 'Dark' : 'Light',
          onTap: () => controller.toggleDarkMode(), // sesuaikan nama method di settingsController kamu
          ),
          _SettingsTile(
          icon: Icons.image_outlined,
          label: 'Background',
          value: ref.watch(backgroundControllerProvider).hasCustomBackground
          ? 'Custom'
          : 'Default',
          onTap: () => ref.read(backgroundControllerProvider.notifier).pickFromGallery(),
          ),
          // _SettingsTile(
          //   icon: Icons.language,
          //   label: 'Language',
          //   value: settings.language,
          //   onTap: () => controller.setLanguage(
          //     settings.language == 'English' ? 'Indonesia' : 'English',
          //   ),
          // ),
          // const _SettingsTile(icon: Icons.play_arrow_rounded, label: 'Playback'),
          // const _SettingsTile(icon: Icons.equalizer_rounded, label: 'Equalizer'),
          // const SizedBox(height: 20),

          // Text('More',
          //     style: AppTextStyles.caption.copyWith(color: AppColors.accent)),
          // const SizedBox(height: 4),
          // const _SettingsTile(icon: Icons.star_border_rounded, label: 'Rate Us'),
          // const _SettingsTile(icon: Icons.ios_share_rounded, label: 'Share App'),
          // const _SettingsTile(
          //     icon: Icons.info_outline_rounded, label: 'About Cplayer'),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(label, style: AppTextStyles.body),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null) ...[
            Text(value!, style: AppTextStyles.caption),
            const SizedBox(width: 6),
          ],
          const Icon(Icons.chevron_right,
              color: AppColors.textMuted, size: 20),
        ],
      ),
    );
  }
}
