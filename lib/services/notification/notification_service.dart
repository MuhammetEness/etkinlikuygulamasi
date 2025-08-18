import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final List<AppNotification> _notificationsList = [];
  
  // Stream controller için
  final StreamController<int> _notificationCountController = StreamController<int>.broadcast();
  
  // ID counter için
  int _nextId = 1;
  
  // Bildirim sayısını takip etmek için
  int get notificationCount => _notificationsList.length;
  
  // Bildirim listesini döndür
  List<AppNotification> get notifications => List.unmodifiable(_notificationsList);

  // Stream getter
  Stream<int> get notificationCountStream => _notificationCountController.stream;

  // Stream'e bildirim gönder
  void _notifyListeners() {
    _notificationCountController.add(notificationCount);
  }

  Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings iosSettings = 
        DarwinInitializationSettings();
    
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
    
    // Eski verileri temizle ve yeni başla
    await clearAllStoredData();
  }

  // Test bildirimi gönder
  Future<void> sendTestNotification() async {
    final notification = AppNotification(
      id: _nextId++,
      title: 'Test Bildirimi',
      body: 'Bu bir test bildirimidir - ${DateTime.now().toString().substring(11, 16)}',
      timestamp: DateTime.now(),
      isRead: false,
    );
    
    await addNotification(notification);
    
    // Gerçek bildirim gönder
    await _notifications.show(
      notification.id,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Test Bildirimleri',
          channelDescription: 'Test bildirimleri için kanal',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  // Bildirim ekle
  Future<void> addNotification(AppNotification notification) async {
    _notificationsList.insert(0, notification);
    await _saveNotifications();
    _notifyListeners();
  }

  // Bildirimi okundu olarak işaretle
  Future<void> markAsRead(int id) async {
    final index = _notificationsList.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notificationsList[index] = _notificationsList[index].copyWith(isRead: true);
      await _saveNotifications();
      _notifyListeners();
    }
  }

  // Tek bildirimi sil
  Future<void> removeNotification(int id) async {
    _notificationsList.removeWhere((n) => n.id == id);
    await _saveNotifications();
    _notifyListeners();
  }

  // Tüm bildirimleri temizle
  Future<void> clearAllNotifications() async {
    _notificationsList.clear();
    _nextId = 1; // ID counter'ı sıfırla
    await _saveNotifications();
    _notifyListeners();
  }

  // SharedPreferences'ı tamamen temizle (debug için)
  Future<void> clearAllStoredData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('notifications');
    _notificationsList.clear();
    _nextId = 1;
    _notifyListeners();
  }

  // Dispose
  void dispose() {
    _notificationCountController.close();
  }

  // Bildirimleri SharedPreferences'a kaydet
  Future<void> _saveNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = _notificationsList.map((n) => n.toJson()).toList();
    await prefs.setString('notifications', jsonEncode(notificationsJson));
  }

  // Bildirimleri SharedPreferences'dan yükle
  Future<void> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsString = prefs.getString('notifications');
    
    if (notificationsString != null) {
      final notificationsJson = jsonDecode(notificationsString) as List;
      _notificationsList.clear();
      _notificationsList.addAll(
        notificationsJson.map((json) => AppNotification.fromJson(json))
      );
      
      // ID counter'ı güncelle - en yüksek ID'den sonraki sayıyı al
      if (_notificationsList.isNotEmpty) {
        final maxId = _notificationsList.map((n) => n.id).reduce((a, b) => a > b ? a : b);
        _nextId = maxId + 1;
      } else {
        _nextId = 1;
      }
    } else {
      _nextId = 1;
    }
  }
}

// Bildirim modeli
class AppNotification {
  final int id;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.isRead,
  });

  AppNotification copyWith({
    int? id,
    String? title,
    String? body,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'],
    );
  }
}
