import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sky_book/screens/auth/auth_screen.dart';
import 'package:sky_book/models/book.dart';
import 'package:sky_book/screens/book_details/book_details_screen.dart';
import 'package:sky_book/screens/leaderboard/leaderboard_provider.dart';
import 'package:sky_book/services/auth_provider.dart';
import 'package:sky_book/services/language_provider.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Consumer<LeaderboardProvider>(
              builder: (context, provider, _) {
                final colorScheme = Theme.of(context).colorScheme;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Header(
                      lang: lang,
                      provider: provider,
                      colorScheme: colorScheme,
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: provider.fetchLeaderboard,
                        child: provider.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(
                                  12,
                                  10,
                                  12,
                                  16,
                                ),
                                itemCount: provider.entries.length,
                                itemBuilder: (context, index) {
                                  final book = provider.entries[index];
                                  final count = switch (provider.range) {
                                    LeaderboardRange.weekly =>
                                        '${provider.countFor(book)} ${lang.t('views_week')}',
                                    LeaderboardRange.monthly =>
                                        '${provider.countFor(book)} ${lang.t('views_month')}',
                                    LeaderboardRange.allTime =>
                                        '${provider.countFor(book)} ${lang.t('views_total')}',
                                  };
                                  return _AnimatedEntryCard(
                                    index: index,
                                    child: _EntryCard(
                                      rank: index + 1,
                                      book: book,
                                      countLabel: count,
                                      colorScheme: colorScheme,
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                  ],
                );
              },
            ),
            if (auth.isGuest)
              _GuestLockOverlay(
                message: lang.t('login_required'),
                actionLabel: lang.t('login_or_register'),
                onAction: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => const AuthScreen()));
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _GuestLockOverlay extends StatelessWidget {
  const _GuestLockOverlay({
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            color: Colors.black.withOpacity(0.35),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_outline, size: 36),
                    const SizedBox(height: 12),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: onAction,
                      child: Text(actionLabel),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.lang,
    required this.provider,
    required this.colorScheme,
  });

  final LanguageProvider lang;
  final LeaderboardProvider provider;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withOpacity(0.14),
            colorScheme.secondary.withOpacity(0.10),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lang.t('leaderboard'),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            lang.t('leaderboard_subtitle'),
            style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: LeaderboardRange.values.map((r) {
              final selected = provider.range == r;
              final label = switch (r) {
                LeaderboardRange.weekly => lang.t('range_week'),
                LeaderboardRange.monthly => lang.t('range_month'),
                LeaderboardRange.allTime => lang.t('range_all'),
              };
              return ChoiceChip(
                label: Text(label),
                selected: selected,
                onSelected: (_) => provider.setRange(r),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({
    required this.rank,
    required this.book,
    required this.countLabel,
    required this.colorScheme,
  });

  final int rank;
  final Book book;
  final String countLabel;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final highlight = rank <= 3;
    final gradientColors = highlight
        ? [
            colorScheme.primary.withOpacity(0.18),
            colorScheme.secondary.withOpacity(0.14),
          ]
        : [
            colorScheme.surface,
            colorScheme.surfaceContainerHighest.withOpacity(0.6),
          ];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BookDetailsScreen(bookId: book.bookId),
            ),
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _RankBadge(rank: rank, colorScheme: colorScheme),
            const SizedBox(width: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 70,
                height: 94,
                child: book.coverImageUrl != null
                    ? Image.asset(
                        "assets/images/thumbnails/${book.coverImageUrl!}",
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.book),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          book.author?.name ?? 'Unknown',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _StatPill(
                            icon: Icons.visibility,
                            label: countLabel,
                            colorScheme: colorScheme,
                          ),
                          _StatPill(
                            icon: Icons.star_rate_rounded,
                            label: '${(book.rating ?? 0).toStringAsFixed(1)}/5',
                            colorScheme: colorScheme,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedEntryCard extends StatelessWidget {
  const _AnimatedEntryCard({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final duration = Duration(milliseconds: 260 + 30 * (index % 6));
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeOut,
      builder: (context, value, _) {
        return Transform.translate(
          offset: Offset(0, 16 * (1 - value)),
          child: Opacity(
            opacity: value.clamp(0, 1),
            child: child,
          ),
        );
      },
    );
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.rank, required this.colorScheme});
  final int rank;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final medalColors = <Color>[
      const Color(0xFFF2C078),
      const Color(0xFFE0E6ED),
      const Color(0xFFC99C72),
    ];
    final bg = rank <= 3
        ? medalColors[rank - 1]
        : colorScheme.primary.withOpacity(0.1);
    final fg = rank <= 3 ? Colors.black : colorScheme.primary;

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        '$rank',
        style: TextStyle(color: fg, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.icon,
    required this.label,
    required this.colorScheme,
  });

  final IconData icon;
  final String label;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
