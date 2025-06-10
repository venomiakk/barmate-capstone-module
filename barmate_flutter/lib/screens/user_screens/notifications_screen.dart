
import 'package:barmate/controllers/notifications_controller.dart';
import 'package:barmate/model/notifications_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();

    // Poczekaj jedną klatkę renderowania, żeby kontekst był gotowy
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationService>(context, listen: false).markAllAsRead();
    });
  }

@override
Widget build(BuildContext context) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Provider.of<NotificationService>(context, listen: false).markAllAsRead();
  });


  return Scaffold(
    appBar: AppBar(
      title: const Text("Notifications"),
      actions: [
        IconButton(
          icon: const Icon(Icons.delete_forever),
          tooltip: "Clear all",
          onPressed: () {
            Provider.of<NotificationService>(context, listen: false).clearAllNotifications();
          },
        ),
      ],
    ),
    body: Consumer<NotificationService>(
      builder: (context, service, _) {
        final List<AppNotification> notifications = service.notifications;

        if (notifications.isEmpty) {
          return const Center(
            child: Text("No notifications yet."),
          );
        }

        return ListView.separated(
          itemCount: notifications.length,
          separatorBuilder: (context, index) => const Divider(height: 0),
          itemBuilder: (context, index) {
            final notif = notifications[index];
            return Dismissible(
              key: ValueKey(notif.timestamp.toIso8601String()),
              direction: DismissDirection.endToStart,
              onDismissed: (_) {
                service.removeNotification(notif);
              },
              background: Container(
                alignment: Alignment.centerRight,
                color: Colors.red,
                padding: const EdgeInsets.only(right: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              child: ListTile(
                leading: const Icon(Icons.notifications),
                title: Text(
                  notif.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(notif.message),
                trailing: Text(
                  timeAgo(notif.timestamp),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ),
            );
          },
        );
      },
    ),
  );
}


  String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
