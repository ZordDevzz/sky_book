import 'package:shadcn_flutter/shadcn_flutter.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.circleUserRound, size: 80),
          const Gap(16),
          const Text('Leaderboard Screen').h3(),
          const Gap(8),
          const Text(
            'TODO: Implement working leaderboard screen with readingStreak board, storiesRead board count from User model',
            textAlign: TextAlign.center,
          ).muted(),
        ],
      ),
    );
  }
}
