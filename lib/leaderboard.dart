import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;
  String _selectedTimeframe = 'all'; // 'week', 'month', 'all'

  // Sample users data
  final List<Map<String, dynamic>> sampleUsers = [
    {
      'id': 'user1',
      'name': 'Sarah Johnson',
      'points': 2850,
      'avatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=60',
      'eventsJoined': 45,
      'hoursServed': 120,
      'level': 'Eco Champion',
      'badges': 12,
    },
    {
      'id': 'user2',
      'name': 'Mike Chen',
      'points': 2670,
      'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=60',
      'eventsJoined': 38,
      'hoursServed': 98,
      'level': 'Community Hero',
      'badges': 10,
    },
    {
      'id': 'user3',
      'name': 'Emily Rodriguez',
      'points': 2420,
      'avatar': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=60',
      'eventsJoined': 42,
      'hoursServed': 115,
      'level': 'Green Warrior',
      'badges': 11,
    },
    {
      'id': 'user4',
      'name': 'David Kim',
      'points': 2180,
      'avatar': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=60',
      'eventsJoined': 35,
      'hoursServed': 87,
      'level': 'Volunteer Star',
      'badges': 8,
    },
    {
      'id': 'user5',
      'name': 'Priya Sharma',
      'points': 1950,
      'avatar': 'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=60',
      'eventsJoined': 32,
      'hoursServed': 76,
      'level': 'Eco Warrior',
      'badges': 7,
    },
    {
      'id': 'user6',
      'name': 'Alex Thompson',
      'points': 1780,
      'avatar': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=60',
      'eventsJoined': 28,
      'hoursServed': 65,
      'level': 'Community Builder',
      'badges': 6,
    },
    {
      'id': 'user7',
      'name': 'Maria Garcia',
      'points': 1620,
      'avatar': 'https://images.unsplash.com/photo-1544725176-7c40e5a71c5e?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=60',
      'eventsJoined': 26,
      'hoursServed': 58,
      'level': 'Green Volunteer',
      'badges': 5,
    },
    {
      'id': 'user8',
      'name': 'James Wilson',
      'points': 1480,
      'avatar': 'https://images.unsplash.com/photo-1519244703995-f4e0f30006d5?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=60',
      'eventsJoined': 24,
      'hoursServed': 52,
      'level': 'Active Member',
      'badges': 4,
    },
    {
      'id': 'user9',
      'name': 'Lisa Wang',
      'points': 1350,
      'avatar': 'https://images.unsplash.com/photo-1517841905240-472988babdf9?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=60',
      'eventsJoined': 22,
      'hoursServed': 48,
      'level': 'Dedicated Helper',
      'badges': 4,
    },
    {
      'id': 'user10',
      'name': 'Ryan Patel',
      'points': 1230,
      'avatar': 'https://images.unsplash.com/photo-1517070208541-6ddc4d3efbcb?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=60',
      'eventsJoined': 20,
      'hoursServed': 45,
      'level': 'Community Member',
      'badges': 3,
    },
    {
      'id': 'current_user',
      'name': 'You',
      'points': 850,
      'avatar': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=60',
      'eventsJoined': 15,
      'hoursServed': 32,
      'level': 'Rising Star',
      'badges': 2,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadLeaderboardData();
  }

  void _loadLeaderboardData() {
    // Simulate loading from Firebase
    Future.delayed(Duration(milliseconds: 1000), () {
      setState(() {
        _users = sampleUsers;
        _isLoading = false;
      });
    });
  }

  int _getCurrentUserRank() {
    final currentUserId = 'current_user'; // Simulated current user
    return _users.indexWhere((user) => user['id'] == currentUserId) + 1;
  }

  Widget _buildRankBadge(int rank) {
    if (rank == 1) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.amber, Colors.orange],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withOpacity(0.3),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            '$rank',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      );
    } else if (rank == 2) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey, Colors.grey[600]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '$rank',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      );
    } else if (rank == 3) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange[700]!, Colors.orange[900]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '$rank',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      );
    } else {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '$rank',
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      );
    }
  }

  Widget _buildTopThree() {
    if (_users.length < 3) return SizedBox();

    final topThree = _users.take(3).toList();

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.green[50]!, Colors.blue[50]!],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'TOP VOLUNTEERS',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Second place
              _buildTopUserCard(topThree[1], 2),
              // First place
              _buildTopUserCard(topThree[0], 1, isFirst: true),
              // Third place
              _buildTopUserCard(topThree[2], 3),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopUserCard(Map<String, dynamic> user, int rank, {bool isFirst = false}) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: isFirst ? 90 : 70,
              height: isFirst ? 90 : 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _getRankColor(rank),
                  width: isFirst ? 4 : 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: CircleAvatar(
                backgroundImage: NetworkImage(user['avatar']),
                backgroundColor: Colors.grey[300],
              ),
            ),
            Positioned(
              bottom: -2,
              right: -2,
              child: _buildRankBadge(rank),
            ),
            if (rank == 1)
              Positioned(
                top: -5,
                left: 0,
                right: 0,
                child: Center(
                  child: Icon(
                    Icons.emoji_events,
                    color: Colors.amber,
                    size: 24,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 12),
        Text(
          user['name'],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isFirst ? 14 : 12,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 4),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: _getRankColor(rank).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${user['points']} pts',
            style: TextStyle(
              color: _getRankColor(rank),
              fontWeight: FontWeight.bold,
              fontSize: isFirst ? 12 : 10,
            ),
          ),
        ),
        SizedBox(height: 4),
        Text(
          user['level'],
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey;
      case 3:
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  Widget _buildLeaderboardList() {
    final otherUsers = _users.length > 3 ? _users.sublist(3) : [];

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: otherUsers.length,
      itemBuilder: (context, index) {
        final user = otherUsers[index];
        final rank = index + 4;
        final isCurrentUser = user['id'] == 'current_user';

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: isCurrentUser ? Colors.blue[50] : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: isCurrentUser ? Border.all(color: Colors.blue) : null,
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
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$rank',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(width: 12),
                Stack(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(user['avatar']),
                      backgroundColor: Colors.grey[300],
                    ),
                    if (isCurrentUser)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    user['name'],
                    style: TextStyle(
                      fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                      color: isCurrentUser ? Colors.blue : Colors.black,
                    ),
                  ),
                ),
                if (user['badges'] > 0)
                  Row(
                    children: [
                      Icon(Icons.emoji_events, size: 14, color: Colors.amber),
                      SizedBox(width: 2),
                      Text(
                        '${user['badges']}',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
              ],
            ),
            subtitle: Row(
              children: [
                Icon(Icons.event, size: 12, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  '${user['eventsJoined']} events',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                SizedBox(width: 8),
                Icon(Icons.access_time, size: 12, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  '${user['hoursServed']}h',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${user['points']}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'points',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurrentUserCard() {
    final currentUserRank = _getCurrentUserRank();
    final currentUser = _users.firstWhere(
          (user) => user['id'] == 'current_user',
      orElse: () => {},
    );

    if (currentUser.isEmpty) return SizedBox();

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue[50]!, Colors.green[50]!],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(currentUser['avatar']),
                radius: 25,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Rank',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  '#$currentUserRank',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                Text(
                  currentUser['name'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.emoji_events, size: 12, color: Colors.amber),
                    SizedBox(width: 4),
                    Text(
                      '${currentUser['badges']} badges',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Points',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                '${currentUser['points']}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.event, size: 12, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    '${currentUser['eventsJoined']} events',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeframeButton(String text, String value) {
    final isSelected = _selectedTimeframe == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTimeframe = value;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leaderboard'),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadLeaderboardData,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading leaderboard...',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      )
          : Column(
        children: [
          // Timeframe selector
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTimeframeButton('This Week', 'week'),
                _buildTimeframeButton('This Month', 'month'),
                _buildTimeframeButton('All Time', 'all'),
              ],
            ),
          ),

          // Top three users
          _buildTopThree(),

          // Current user card
          _buildCurrentUserCard(),

          // Leaderboard title
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Community Rankings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                Text(
                  '${_users.length} volunteers',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          // Leaderboard list
          Expanded(
            child: _buildLeaderboardList(),
          ),
        ],
      ),
    );
  }
}