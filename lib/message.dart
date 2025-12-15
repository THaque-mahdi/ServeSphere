import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  int _currentIndex = 1; // Messages is active

  // Sample group chats for different activities
  final List<Map<String, dynamic>> groupChats = [
    {
      'id': 'tree_plantation',
      'name': 'Tree Plantation Volunteers',
      'lastMessage': 'Let\'s meet at the park at 9 AM tomorrow',
      'lastMessageTime': DateTime.now().subtract(Duration(minutes: 30)),
      'unreadCount': 3,
      'members': 45,
      'imageUrl': 'https://images.stockcake.com/public/9/0/1/901d6234-d8ad-4bb3-99d2-0232a463c6a5_large/planting-small-tree-stockcake.jpg',
      'isOnline': true,
    },
    {
      'id': 'clean_city',
      'name': 'Clean City Initiative',
      'lastMessage': 'We collected 50 bags of trash yesterday!',
      'lastMessageTime': DateTime.now().subtract(Duration(hours: 2)),
      'unreadCount': 0,
      'members': 89,
      'imageUrl': 'https://images.unsplash.com/photo-1521791136064-7986c2920216?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
      'isOnline': true,
    },
    {
      'id': 'blood_donation',
      'name': 'Blood Donation Camp',
      'lastMessage': 'Urgent: We need O+ blood donors',
      'lastMessageTime': DateTime.now().subtract(Duration(hours: 5)),
      'unreadCount': 1,
      'members': 120,
      'imageUrl': 'https://www.gynecoloncol.com/wp-content/uploads/2020/10/2171-blood-donation.jpg',
      'isOnline': false,
    },
    {
      'id': 'food_donation',
      'name': 'Food Donation Drive',
      'lastMessage': 'Thanks everyone for the donations!',
      'lastMessageTime': DateTime.now().subtract(Duration(days: 1)),
      'unreadCount': 0,
      'members': 67,
      'imageUrl': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
      'isOnline': true,
    },
    {
      'id': 'free_tuition',
      'name': 'Free Tuition Program',
      'lastMessage': 'New study materials uploaded',
      'lastMessageTime': DateTime.now().subtract(Duration(days: 2)),
      'unreadCount': 0,
      'members': 34,
      'imageUrl': 'https://parents.eduguide.sg/wp-content/uploads/2017/06/4bd4e9812f71dd1c9bf74cdc45e82264.jpg',
      'isOnline': false,
    },
    {
      'id': 'recycle_team',
      'name': 'Recycling Warriors',
      'lastMessage': 'Monthly recycling competition starts tomorrow',
      'lastMessageTime': DateTime.now().subtract(Duration(days: 3)),
      'unreadCount': 7,
      'members': 156,
      'imageUrl': 'https://images.unsplash.com/photo-1481761289552-381112059e05?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
      'isOnline': true,
    },
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Handle navigation
    switch (index) {
      case 0: // Home
        Navigator.pushNamed(context, '/home');
        break;
      case 1: // Messages - already here
        break;
      case 2: // Profile
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messages'),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              _showSearchDialog();
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              _handleMenuSelection(value);
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(value: 'create_group', child: Text('Create New Group')),
              PopupMenuItem(value: 'archived', child: Text('Archived Chats')),
              PopupMenuItem(value: 'settings', child: Text('Message Settings')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search messages...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                // Implement search functionality
                setState(() {});
              },
            ),
          ),

          // Online Status
          _buildOnlineStatus(),

          // Group Chats List
          Expanded(
            child: ListView.builder(
              itemCount: groupChats.length,
              itemBuilder: (context, index) {
                final chat = groupChats[index];
                return _buildGroupChatItem(chat);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateGroupDialog(context);
        },
        child: Icon(Icons.group_add),
        backgroundColor: Colors.green,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        selectedItemColor: const Color.fromARGB(255, 0, 0, 0),
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  Widget _buildOnlineStatus() {
    final onlineCount = groupChats.where((chat) => chat['isOnline'] == true).length;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            'Active Groups',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(width: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$onlineCount online',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          Spacer(),
          Text(
            '${groupChats.length} groups',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupChatItem(Map<String, dynamic> chat) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundImage: NetworkImage(chat['imageUrl']),
              backgroundColor: Colors.grey[300],
            ),
            if (chat['isOnline'] == true)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                chat['name'],
                style: TextStyle(
                  fontWeight: chat['unreadCount'] > 0 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (chat['unreadCount'] > 0)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${chat['unreadCount']}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              chat['lastMessage'],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: chat['unreadCount'] > 0 ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.people, size: 12, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  '${chat['members']} members',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Spacer(),
                Text(
                  _formatTime(chat['lastMessageTime']),
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        onTap: () {
          _navigateToGroupChat(chat);
        },
        onLongPress: () {
          _showGroupOptions(chat);
        },
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) return 'Now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';

    final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final month = monthNames[time.month - 1];
    final day = time.day;
    final year = time.year;

    return '$month $day, $year';
  }

  void _navigateToGroupChat(Map<String, dynamic> chat) {
    // Navigate to individual group chat screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupChatScreen(
          groupId: chat['id'],
          groupName: chat['name'],
          groupImage: chat['imageUrl'],
        ),
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Search Messages'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Type to search...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Search'),
          ),
        ],
      ),
    );
  }

  void _showCreateGroupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Create New Group'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey[300],
              child: Icon(Icons.group_add, size: 40, color: Colors.grey),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Group Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'Group Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Group created successfully!')),
              );
            },
            child: Text('Create Group'),
          ),
        ],
      ),
    );
  }

  void _showGroupOptions(Map<String, dynamic> chat) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text('Mute Notifications'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Notifications muted for ${chat['name']}')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.archive),
              title: Text('Archive Chat'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Chat archived')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text('Delete Chat', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(chat);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> chat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Chat?'),
        content: Text('Are you sure you want to delete the chat with ${chat['name']}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Chat deleted')),
              );
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'create_group':
        _showCreateGroupDialog(context);
        break;
      case 'archived':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Archived chats opened')),
        );
        break;
      case 'settings':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Message settings opened')),
        );
        break;
    }
  }
}

// Complete Group Chat Screen with messaging functionality
class GroupChatScreen extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String groupImage;

  const GroupChatScreen({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.groupImage,
  });

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sample messages data
  final List<Map<String, dynamic>> _messages = [
    {
      'id': '1',
      'text': 'Hello everyone! Welcome to the group! 🌱',
      'sender': 'Sarah Johnson',
      'senderId': 'user1',
      'timestamp': DateTime.now().subtract(Duration(hours: 2)),
      'isMe': false,
      'avatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=60',
    },
    {
      'id': '2',
      'text': 'Hi Sarah! Excited to be part of this initiative!',
      'sender': 'Mike Chen',
      'senderId': 'user2',
      'timestamp': DateTime.now().subtract(Duration(hours: 1, minutes: 45)),
      'isMe': false,
      'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=60',
    },
    {
      'id': '3',
      'text': 'When is our next tree planting event?',
      'sender': 'You',
      'senderId': 'current_user',
      'timestamp': DateTime.now().subtract(Duration(hours: 1, minutes: 30)),
      'isMe': true,
      'avatar': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=60',
    },
    {
      'id': '4',
      'text': 'We\'re planning for this Saturday at Central Park. 9 AM sharp!',
      'sender': 'Sarah Johnson',
      'senderId': 'user1',
      'timestamp': DateTime.now().subtract(Duration(hours: 1, minutes: 15)),
      'isMe': false,
      'avatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=60',
    },
    {
      'id': '5',
      'text': 'Great! I\'ll bring some extra saplings from my nursery.',
      'sender': 'Emily Rodriguez',
      'senderId': 'user3',
      'timestamp': DateTime.now().subtract(Duration(hours: 1)),
      'isMe': false,
      'avatar': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=60',
    },
    {
      'id': '6',
      'text': 'Perfect! I can help with organizing the tools.',
      'sender': 'You',
      'senderId': 'current_user',
      'timestamp': DateTime.now().subtract(Duration(minutes: 45)),
      'isMe': true,
      'avatar': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=60',
    },
    {
      'id': '7',
      'text': 'Don\'t forget to bring gloves and water bottles! 💧',
      'sender': 'Sarah Johnson',
      'senderId': 'user1',
      'timestamp': DateTime.now().subtract(Duration(minutes: 30)),
      'isMe': false,
      'avatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=60',
    },
    {
      'id': '8',
      'text': 'Thanks for the reminder! See you all on Saturday!',
      'sender': 'You',
      'senderId': 'current_user',
      'timestamp': DateTime.now().subtract(Duration(minutes: 5)),
      'isMe': true,
      'avatar': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=60',
    },
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final newMessage = {
      'id': '${DateTime.now().millisecondsSinceEpoch}',
      'text': _messageController.text,
      'sender': 'You',
      'senderId': 'current_user',
      'timestamp': DateTime.now(),
      'isMe': true,
      'avatar': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=60',
    };

    setState(() {
      _messages.add(newMessage);
    });

    _messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatMessageTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) return 'Now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';

    final hour = timestamp.hour % 12 == 0 ? 12 : timestamp.hour % 12;
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final period = timestamp.hour < 12 ? 'AM' : 'PM';

    return '$hour:$minute $period';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.groupImage),
              radius: 16,
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.groupName, style: TextStyle(fontSize: 16)),
                Text(
                  '45 members • Online',
                  style: TextStyle(fontSize: 12, color: Colors.green),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.video_call),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Video call feature coming soon!')),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.call),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Voice call feature coming soon!')),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              _handleChatMenuSelection(value);
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(value: 'members', child: Text('View Members')),
              PopupMenuItem(value: 'media', child: Text('Media & Files')),
              PopupMenuItem(value: 'settings', child: Text('Group Settings')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Group info banner
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.green[50],
            child: Row(
              children: [
                Icon(Icons.info, size: 16, color: Colors.green),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'This is the official group for ${widget.groupName}. Be respectful and helpful!',
                    style: TextStyle(fontSize: 12, color: Colors.green[800]),
                  ),
                ),
              ],
            ),
          ),

          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),

          // Message input
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              children: [
                // Attachment button
                IconButton(
                  icon: Icon(Icons.attach_file, color: Colors.grey),
                  onPressed: () {
                    _showAttachmentOptions();
                  },
                ),

                // Message input field
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),

                // Send button
                IconButton(
                  icon: Icon(Icons.send, color: Colors.green),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isMe = message['isMe'] == true;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe)
            CircleAvatar(
              backgroundImage: NetworkImage(message['avatar']),
              radius: 16,
            ),

          SizedBox(width: 8),

          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe)
                  Text(
                    message['sender'],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),

                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe ? Colors.green : Colors.grey[100],
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    message['text'],
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  _formatMessageTime(message['timestamp']),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),

          if (isMe)
            SizedBox(width: 8),

          if (isMe)
            CircleAvatar(
              backgroundImage: NetworkImage(message['avatar']),
              radius: 16,
            ),
        ],
      ),
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo, color: Colors.green),
              title: Text('Photo & Video'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gallery would open here')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_camera, color: Colors.green),
              title: Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Camera would open here')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.insert_drive_file, color: Colors.green),
              title: Text('Document'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('File picker would open here')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.location_on, color: Colors.green),
              title: Text('Location'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Location picker would open here')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleChatMenuSelection(String value) {
    switch (value) {
      case 'members':
        _showGroupMembers();
        break;
      case 'media':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Media gallery would open here')),
        );
        break;
      case 'settings':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Group settings would open here')),
        );
        break;
    }
  }

  void _showGroupMembers() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Group Members (45)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            // Sample members list
            ..._buildSampleMembersList(),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSampleMembersList() {
    final sampleMembers = [
      {'name': 'Sarah Johnson', 'role': 'Admin', 'avatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=60'},
      {'name': 'Mike Chen', 'role': 'Member', 'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=60'},
      {'name': 'Emily Rodriguez', 'role': 'Member', 'avatar': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=60'},
      {'name': 'You', 'role': 'Member', 'avatar': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=60'},
    ];

    return sampleMembers.map((member) => ListTile(
      leading: CircleAvatar(backgroundImage: NetworkImage(member['avatar']!)),
      title: Text(member['name']!),
      subtitle: Text(member['role']!),
      trailing: member['name'] == 'You' ? null : ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Message ${member['name']}')),
          );
        },
        child: Text('Message'),
      ),
    )).toList();
  }
}