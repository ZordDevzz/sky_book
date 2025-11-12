import 'package:shadcn_flutter/shadcn_flutter.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.circleUserRound, size: 80),
          const Gap(16),
          const Text('Profile Screen').h3(),
          const Gap(8),
          const Text(
            'TODO: Implement working user profile',
            textAlign: TextAlign.center,
          ).muted(),
        ],
      ),
    );
  }
}
