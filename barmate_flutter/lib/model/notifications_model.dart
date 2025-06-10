class AppNotification {
  final String title;
  final String message;
  final DateTime timestamp;
  bool isRead; 

  AppNotification({
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false, 
  });
}
