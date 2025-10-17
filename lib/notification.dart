import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _selectedFilter = 'all';

  // Sample notifications including event reminders
  final List<Map<String, dynamic>> notifications = [
    {
      'id': '1',
      'type': 'event_reminder',
      'title': 'Event Reminder',
      'message': 'Tree Planting event starts in 2 hours',
      'timestamp': DateTime.now().subtract(Duration(minutes: 5)),
      'isRead': false,
      'eventId': 'tree_plant_1',
      'priority': 'high',
    },
    {
      'id': '2',
      'type': 'event_update',
      'title': 'Event Updated',
      'message': 'Blood Donation Camp location has changed',
      'timestamp': DateTime.now().subtract(Duration(hours: 2)),
      'isRead': false,
      'eventId': 'blood_donation_1',
      'priority': 'medium',
    },
    {
      'id': '3',
      'type': 'achievement',
      'title': 'Achievement Unlocked!',
      'message': 'You\'ve earned the "Eco Warrior" badge',
      'timestamp': DateTime.now().subtract(Duration(hours: 5)),
      'isRead': true,
      'priority': 'medium',
    },
    {
      'id': '4',
      'type': 'message',
      'title': 'New Message',
      'message': 'Sarah sent you a message in Tree Plantation group',
      'timestamp': DateTime.now().subtract(Duration(days: 1)),
      'isRead': true,
      'priority': 'low',
    },
    {
      'id': '5',
      'type': 'event_reminder',
      'title': 'Event Reminder',
      'message': 'City Cleanup Drive starts tomorrow at 2 PM',
      'timestamp': DateTime.now().subtract(Duration(days: 1)),
      'isRead': true,
      'eventId': 'clean_city_1',
      'priority': 'medium',
    },
    {
      'id': '6',
      'type': 'system',
      'title': 'Welcome to ServeSphere!',
      'message': 'Thank you for joining our community',
      'timestamp': DateTime.now().subtract(Duration(days: 2)),
      'isRead': true,
      'priority': 'low',
    },
    {
      'id': '7',
      'type': 'event_reminder',
      'title': 'Event Starting Soon',
      'message': 'Food Donation Collection starts in 30 minutes',
      'timestamp': DateTime.now().subtract(Duration(days: 3)),
      'isRead': true,
      'eventId': 'food_drive_1',
      'priority': 'high',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(Icons.checklist),
            onPressed: _markAllAsRead,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(value: 'all', child: Text('All Notifications')),
              PopupMenuItem(value: 'unread', child: Text('Unread Only')),
              PopupMenuItem(value: 'event_reminders', child: Text('Event Reminders')),
              PopupMenuItem(value: 'achievements', child: Text('Achievements')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          _buildNotificationStats(),
          Expanded(
            child: _buildNotificationsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          SizedBox(width: 16),
          _buildFilterChip('All', 'all'),
          SizedBox(width: 8),
          _buildFilterChip('Unread', 'unread'),
          SizedBox(width: 8),
          _buildFilterChip('Reminders', 'event_reminders'),
          SizedBox(width: 8),
          _buildFilterChip('Achievements', 'achievements'),
          SizedBox(width: 16),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return ChoiceChip(
      label: Text(label),
      selected: _selectedFilter == value,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      selectedColor: Colors.green,
      labelStyle: TextStyle(
        color: _selectedFilter == value ? Colors.white : Colors.black,
      ),
    );
  }

  Widget _buildNotificationStats() {
    final unreadCount = notifications.where((n) => n['isRead'] == false).length;
    final reminderCount = notifications.where((n) => n['type'] == 'event_reminder').length;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border(bottom: BorderSide(color: Colors.blue[100]!)),
      ),
      child: Row(
        children: [
          _buildStatItem('$unreadCount', 'Unread'),
          SizedBox(width: 16),
          _buildStatItem('$reminderCount', 'Reminders'),
          Spacer(),
          Icon(Icons.notifications_active, color: Colors.blue, size: 20),
          SizedBox(width: 4),
          Text(
            'Notifications',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.blue[700],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationsList() {
    final filteredNotifications = _getFilteredNotifications();

    if (filteredNotifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              _getEmptyStateMessage(),
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'You\'re all caught up!',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredNotifications.length,
      itemBuilder: (context, index) {
        var notification = filteredNotifications[index];
        return _buildNotificationItem(notification);
      },
    );
  }

  List<Map<String, dynamic>> _getFilteredNotifications() {
    switch (_selectedFilter) {
      case 'unread':
        return notifications.where((n) => n['isRead'] == false).toList();
      case 'event_reminders':
        return notifications.where((n) => n['type'] == 'event_reminder').toList();
      case 'achievements':
        return notifications.where((n) => n['type'] == 'achievement').toList();
      default:
        return notifications;
    }
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    return Dismissible(
      key: Key(notification['id']),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        _deleteNotification(notification['id']);
      },
      child: Container(
        decoration: BoxDecoration(
          color: notification['isRead'] == true ? Colors.white : Colors.blue[50],
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!),
          ),
        ),
        child: ListTile(
          leading: _getNotificationIcon(notification['type'], notification['priority']),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  notification['title'],
                  style: TextStyle(
                    fontWeight: notification['isRead'] == true ? FontWeight.normal : FontWeight.bold,
                  ),
                ),
              ),
              if (notification['priority'] == 'high')
                Icon(Icons.priority_high, color: Colors.red, size: 16),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(notification['message']),
              SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    _formatTimestamp(notification['timestamp']),
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Spacer(),
                  if (notification['type'] == 'event_reminder')
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Reminder',
                        style: TextStyle(fontSize: 10, color: Colors.green[800]),
                      ),
                    ),
                ],
              ),
            ],
          ),
          trailing: notification['isRead'] == true
              ? null
              : Icon(Icons.circle, color: Colors.blue, size: 12),
          onTap: () {
            _handleNotificationTap(notification);
          },
        ),
      ),
    );
  }

  Widget _getNotificationIcon(String type, String priority) {
    Color color;
    switch (priority) {
      case 'high':
        color = Colors.red;
        break;
      case 'medium':
        color = Colors.orange;
        break;
      default:
        color = Colors.blue;
    }

    IconData icon;
    switch (type) {
      case 'event_reminder':
        icon = Icons.event;
        break;
      case 'event_update':
        icon = Icons.update;
        break;
      case 'achievement':
        icon = Icons.emoji_events;
        break;
      case 'message':
        icon = Icons.message;
        break;
      default:
        icon = Icons.notifications;
    }

    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';

    final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final month = monthNames[timestamp.month - 1];
    final day = timestamp.day;
    final year = timestamp.year;

    return '$month $day, $year';
  }

  void _handleNotificationTap(Map<String, dynamic> notification) {
    // Mark as read
    setState(() {
      notification['isRead'] = true;
    });

    // Handle notification action based on type
    switch (notification['type']) {
      case 'event_reminder':
      case 'event_update':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Opening event details...')),
        );
        // Navigate to event details
        break;
      case 'message':
        Navigator.pushNamed(context, '/messages');
        break;
      case 'achievement':
      // Navigate to profile or achievements
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in notifications) {
        notification['isRead'] = true;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('All notifications marked as read')),
    );
  }

  void _deleteNotification(String notificationId) {
    setState(() {
      notifications.removeWhere((n) => n['id'] == notificationId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Notification deleted')),
    );
  }

  String _getEmptyStateMessage() {
    switch (_selectedFilter) {
      case 'unread':
        return 'No unread notifications';
      case 'event_reminders':
        return 'No event reminders';
      case 'achievements':
        return 'No achievement notifications';
      default:
        return 'No notifications';
    }
  }
}