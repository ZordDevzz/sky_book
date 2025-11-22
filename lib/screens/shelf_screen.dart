import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sky_book/utils/toast_helper.dart';
import '../../providers/shelf_provider.dart';

class ShelfScreen extends StatelessWidget {
  const ShelfScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ShelfProvider>(
      builder: (context, shelfProvider, child) {
        if (shelfProvider.myShelf.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(LucideIcons.bookOpen, size: 80),
                const Gap(16),
                const Text('Your shelf is empty').h3(),
                const Gap(8),
                const Text(
                  'Add books from the Home or Discover page',
                  textAlign: TextAlign.center,
                ).muted(),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: shelfProvider.myShelf.length,
          itemBuilder: (context, index) {
            final shelf = shelfProvider.myShelf[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(shelf.title).h4().semiBold(),
                          const Gap(4),
                          Text('by ${shelf.author}').muted(),
                          const Gap(8),
                          Row(
                            children: [
                              const Icon(LucideIcons.star, size: 16),
                              const Gap(4),
                              Text('${shelf.rating}'),
                              const Gap(16),
                              const Icon(LucideIcons.bookOpen, size: 16),
                              const Gap(4),
                              Text('${shelf.totalChapters} chapters'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    DestructiveButton(
                      density: ButtonDensity.icon,
                      onPressed: () {
                        try {
                          shelfProvider.removeFromShelf(shelf.id);
                          ToastHelper.showSuccess(context, "Đã xoá khỏi shelf");
                        } catch (e) {
                          ToastHelper.showError(context, "Có lỗi xảy ra");
                        }
                      },
                      child: const Icon(LucideIcons.trash2),
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
