import 'package:shadcn_flutter/shadcn_flutter.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.circleUserRound, size: 80),
          const Gap(16),
          const Text('Discover Screen').h3(),
          const Gap(8),
          const Text(
            'TODO: Implement working discover screen with data crawled',
            textAlign: TextAlign.center,
          ).muted(),
        ],
      ),
    );
  }
}
