import 'package:shadcn_flutter/shadcn_flutter.dart';

class ToastHelper {
  static void showSuccess(BuildContext context, String message) {
    showToast(
      context: context,
      location: ToastLocation.bottomCenter,
      builder: (context, overlay) {
        return SurfaceCard(
          child: Basic(
            title: const Text('Thành công'),
            subtitle: Text(message),
            leading: const Icon(
              LucideIcons.circleCheck,
              color: Color(0xFF22C55E), // Green color
            ),
          ),
        );
      },
    );
  }

  static void showError(BuildContext context, String message) {
    showToast(
      context: context,
      location: ToastLocation.bottomCenter,
      builder: (context, overlay) {
        return SurfaceCard(
          child: Basic(
            title: const Text('Lỗi'),
            subtitle: Text(message),
            leading: const Icon(
              LucideIcons.circleAlert,
              color: Color(0xFFEF4444), // Red color
            ),
          ),
        );
      },
    );
  }

  static void showInfo(BuildContext context, String message) {
    showToast(
      context: context,
      location: ToastLocation.bottomCenter,
      builder: (context, overlay) {
        return SurfaceCard(
          child: Basic(
            title: const Text('Info'),
            subtitle: Text(message),
            leading: const Icon(
              LucideIcons.info,
              color: Color(0xFF3B82F6), // Blue color
            ),
          ),
        );
      },
    );
  }

  static void showWarning(BuildContext context, String message) {
    showToast(
      context: context,
      location: ToastLocation.bottomCenter,
      builder: (context, overlay) {
        return SurfaceCard(
          child: Basic(
            title: const Text('Warning'),
            subtitle: Text(message),
            leading: const Icon(
              LucideIcons.triangleAlert,
              color: Color(0xFFF59E0B), // Orange/Yellow color
            ),
          ),
        );
      },
    );
  }

  // Custom toast with action button
  static void showWithAction(
    BuildContext context,
    String message,
    String actionText,
    VoidCallback onAction,
  ) {
    showToast(
      context: context,
      builder: (context, overlay) {
        return SurfaceCard(
          child: Basic(
            title: Text(message),
            trailing: TextButton(
              onPressed: () {
                overlay.close();
                onAction();
              },
              child: Text(actionText),
            ),
          ),
        );
      },
    );
  }
}
