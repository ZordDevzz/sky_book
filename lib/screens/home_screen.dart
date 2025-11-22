import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:provider/provider.dart';
import '../../providers/shelf_provider.dart';
import '../../utils/toast_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch books when screen loads
    Future.microtask(() {
      context.read<ShelfProvider>().fetchShelfs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ShelfProvider>(
      builder: (context, shelfProvider, child) {
        if (shelfProvider.isLoading) {
          return const Center(child: Text('Loading shelfs...'));
        }

        if (shelfProvider.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(LucideIcons.circleAlert, size: 48),
                const SizedBox(height: 16),
                Text('Error: ${shelfProvider.errorMessage}'),
                const SizedBox(height: 16),
                PrimaryButton(
                  onPressed: () => shelfProvider.fetchShelfs(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (shelfProvider.shelfs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.bookOpen, size: 48),
                SizedBox(height: 16),
                Text('No shelfs available'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: shelfProvider.shelfs.length,
          itemBuilder: (context, index) {
            final shelf = shelfProvider.shelfs[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(shelf.title).h4().semiBold(),
                    const Gap(4),
                    Text('by ${shelf.author}').muted(),
                    const Gap(8),
                    Text(shelf.description).small(),
                    const Gap(8),
                    Row(
                      children: [
                        const Icon(LucideIcons.star, size: 16),
                        const Gap(4),
                        Text('${shelf.rating}'),
                        const Gap(16),
                        const Icon(LucideIcons.eye, size: 16),
                        const Gap(4),
                        Text('${shelf.views}'),
                        const Gap(16),
                        const Icon(LucideIcons.bookOpen, size: 16),
                        const Gap(4),
                        Text('${shelf.totalChapters} chapters'),
                      ],
                    ),
                    const Gap(12),
                    Row(
                      children: [
                        Expanded(
                          child: PrimaryButton(
                            onPressed: () {
                              try {
                                shelfProvider.addToShelf(shelf);
                                ToastHelper.showSuccess(
                                  context,
                                  'Đã lưu ${shelf.title} vào thư viện',
                                );
                              } catch (e) {
                                ToastHelper.showError(
                                  context,
                                  'Failed to save book',
                                );
                              }
                            },
                            child: const Text('Add to Shelf'),
                          ),
                        ),
                        const Gap(8),
                        OutlineButton(
                          onPressed: () {
                            // TODO: Navigate to book detail
                          },
                          child: const Text('Details'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ).withPadding(bottom: 12);
          },
        );
      },
    );
  }
}
