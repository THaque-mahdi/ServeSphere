import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'userprofile.dart';
import 'leaderboard.dart';

class FirebaseTest extends StatelessWidget {
  const FirebaseTest({super.key});

  void testFirebase() async {
    try {
      // Test Firestore connection
      await FirebaseFirestore.instance.collection('test').add({
        'message': 'Firebase is working!',
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('✅ Firebase connected successfully!');
    } catch (e) {
      print('❌ Firebase error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firebase Test')),
      body: Center(
        child: ElevatedButton(
          onPressed: testFirebase,
          child: const Text('Test Firebase Connection'),
        ),
      ),
    );
  }
}

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  // Dynamic data futures and streams
  late Future<List<Map<String, dynamic>>> _activitiesFuture;
  late Future<List<Map<String, dynamic>>> _featuredCampaignsFuture;
  late Stream<QuerySnapshot> _recentActivitiesStream;
  late Stream<DocumentSnapshot> _userStatsStream;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    _activitiesFuture = _fetchActivities();
    _featuredCampaignsFuture = _fetchFeaturedCampaigns();
    _recentActivitiesStream = _fetchRecentActivitiesStream();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userStatsStream = _fetchUserStatsStream(user.uid);
    }
  }

  // Fetch activities from Firestore
  Future<List<Map<String, dynamic>>> _fetchActivities() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('activities')
          .where('isActive', isEqualTo: true)
          .orderBy('count', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'title': data['title'] ?? 'Activity',
          'count': _formatCount(data['count'] ?? 0),
          'imageUrl': data['imageUrl'] ?? '',
          'id': doc.id,
          'description': data['description'] ?? '',
        };
      }).toList();
    } catch (e) {
      print('❌ Error fetching activities: $e');
      // Fallback to static data if Firebase fails
      return _getStaticActivities();
    }
  }

  String _formatCount(dynamic count) {
    if (count is int) {
      if (count >= 1000) {
        return '${(count / 1000).toStringAsFixed(0)}k';
      }
      return count.toString();
    }
    return count.toString();
  }

  // Static fallback activities
  List<Map<String, dynamic>> _getStaticActivities() {
    return [
      {
        'title': 'Tree plantation',
        'count': '11k',
        'imageUrl': 'https://images.stockcake.com/public/9/0/1/901d6234-d8ad-4bb3-99d2-0232a463c6a5_large/planting-small-tree-stockcake.jpg',
      },
      {
        'title': 'Blood Donation',
        'count': '100k',
        'imageUrl': 'https://www.gynecoloncol.com/wp-content/uploads/2020/10/2171-blood-donation.jpg',
      },
      {
        'title': 'Free tuition',
        'count': '116k',
        'imageUrl': 'https://parents.eduguide.sg/wp-content/uploads/2017/06/4bd4e9812f71dd1c9bf74cdc45e82264.jpg',
      },
      {
        'title': 'Food donation',
        'count': '22k',
        'imageUrl': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
      },
      {
        'title': 'Clean-up City',
        'count': '122k',
        'imageUrl': 'https://images.unsplash.com/photo-1521791136064-7986c2920216?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
      },
      {
        'title': 'Recycle',
        'count': '200k',
        'imageUrl': 'https://images.unsplash.com/photo-1481761289552-381112059e05?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
      },
    ];
  }

  // Fetch featured campaigns from Firestore
  Future<List<Map<String, dynamic>>> _fetchFeaturedCampaigns() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('campaigns')
          .where('isFeatured', isEqualTo: true)
          .where('status', isEqualTo: 'active')
          .orderBy('createdAt', descending: true)
          .limit(5)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        final progress = data['progress'] ?? 0;
        return {
          'title': data['title'] ?? 'Campaign',
          'description': data['description'] ?? '',
          'imageUrl': data['imageUrl'] ?? '',
          'progress': progress.toString(),
          'currentAmount': data['currentAmount'] ?? 0,
          'targetAmount': data['targetAmount'] ?? 1,
          'id': doc.id,
        };
      }).toList();
    } catch (e) {
      print('❌ Error fetching campaigns: $e');
      return _getStaticCampaigns();
    }
  }

  // Static fallback campaigns
  List<Map<String, dynamic>> _getStaticCampaigns() {
    return [
      {
        'title': 'Education for All',
        'description': 'Help underprivileged children access quality education',
        'imageUrl': 'https://images.unsplash.com/photo-1523050854058-8df90110c9f1?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        'progress': '65',
        'currentAmount': 6500,
        'targetAmount': 10000,
      },
      {
        'title': 'Clean Water Initiative',
        'description': 'Provide clean drinking water to rural communities',
        'imageUrl': 'https://images.unsplash.com/photo-1574362848149-11496d93a7c7?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        'progress': '42',
        'currentAmount': 4200,
        'targetAmount': 10000,
      },
    ];
  }

  // Stream for recent activities
  Stream<QuerySnapshot> _fetchRecentActivitiesStream() {
    return FirebaseFirestore.instance
        .collection('recentActivities')
        .orderBy('timestamp', descending: true)
        .limit(10)
        .snapshots();
  }

  // Stream for user stats
  Stream<DocumentSnapshot> _fetchUserStatsStream(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots();
  }

  // Format timestamp to relative time
  String _formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final time = timestamp.toDate();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${(difference.inDays / 7).floor()} weeks ago';
    }
  }

  void _onActivityTap(String activityTitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(activityTitle),
        content: Text('You selected $activityTitle. This would open detailed information about this activity.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ActivityEventsPage(activityType: activityTitle),
                ),
              );
            },
            child: Text('View Events'),
          ),
        ],
      ),
    );
  }

  void _onFeaturedCampaignTap(int index, List<Map<String, dynamic>> campaigns) {
    final campaign = campaigns[index];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(campaign['title']!),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(campaign['imageUrl']!, height: 150, width: double.infinity, fit: BoxFit.cover),
            SizedBox(height: 12),
            Text(campaign['description']!),
            SizedBox(height: 8),
            LinearProgressIndicator(
              value: (int.tryParse(campaign['progress']!) ?? 0) / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            SizedBox(height: 4),
            Text('Progress: ${campaign['progress']}%', style: TextStyle(fontSize: 12)),
            SizedBox(height: 4),
            Text(
              '\$${campaign['currentAmount']} raised of \$${campaign['targetAmount']}',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Donating to ${campaign['title']}')),
              );
            },
            child: Text('Donate Now'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('ServeSphere', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard),
            onPressed: () => Navigator.pushNamed(context, '/leaderboard'),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome section with user stats
            _buildWelcomeSection(),

            const SizedBox(height: 16),

            // Search bar
            TextFormField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Activities',
                hintText: 'Type activity name...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                // Search functionality would go here
              },
            ),

            const SizedBox(height: 24),

            // Featured campaigns section
            _buildFeaturedCampaigns(),

            const SizedBox(height: 24),

            // All activities section
            _buildAllActivities(),

            const SizedBox(height: 24),

            // Recent activities section
            _buildRecentActivities(),

            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          switch (index) {
            case 0: // Home - already here
              break;
            case 1: // Messages
              Navigator.pushNamed(context, '/messages');
              break;
            case 2: // Profile
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                Navigator.pushNamed(context, '/profile');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please log in to view profile')),
                );
              }
              break;
          }
        },
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

  Widget _buildWelcomeSection() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return _buildWelcomeSectionWithStats(12, 24, 350);
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: _userStatsStream,
      builder: (context, snapshot) {
        int eventsJoined = 12;
        int hoursServed = 24;
        int pointsEarned = 350;

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          eventsJoined = data['eventsJoined'] ?? 12;
          hoursServed = data['hoursServed'] ?? 24;
          pointsEarned = data['pointsEarned'] ?? 350;
        }

        return _buildWelcomeSectionWithStats(eventsJoined, hoursServed, pointsEarned);
      },
    );
  }

  Widget _buildWelcomeSectionWithStats(int eventsJoined, int hoursServed, int pointsEarned) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        const Text(
          'Let\'s make a difference together',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(eventsJoined.toString(), 'Events Joined'),
              _buildStatItem(hoursServed.toString(), 'Hours Served'),
              _buildStatItem(pointsEarned.toString(), 'Points Earned'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildFeaturedCampaigns() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Featured Campaigns',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _featuredCampaignsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return SizedBox(
                height: 200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, color: Colors.red, size: 40),
                      SizedBox(height: 8),
                      Text('Error loading campaigns'),
                    ],
                  ),
                ),
              );
            }

            final campaigns = snapshot.data ?? [];

            if (campaigns.isEmpty) {
              return SizedBox(
                height: 200,
                child: Center(
                  child: Text('No featured campaigns available'),
                ),
              );
            }

            return SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: campaigns.length,
                itemBuilder: (context, index) {
                  final campaign = campaigns[index];
                  return GestureDetector(
                    onTap: () => _onFeaturedCampaignTap(index, campaigns),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            child: Image.network(
                              campaign['imageUrl']!,
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                height: 120,
                                color: Colors.grey[200],
                                child: Icon(Icons.error, color: Colors.red),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  campaign['title']!,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  campaign['description']!,
                                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: (int.tryParse(campaign['progress']!) ?? 0) / 100,
                                  backgroundColor: Colors.grey[200],
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Progress: ${campaign['progress']}%',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        _onFeaturedCampaignTap(index, campaigns);
                                      },
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: Size.zero,
                                      ),
                                      child: const Text(
                                        'Donate Now',
                                        style: TextStyle(fontSize: 12, color: Colors.green),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAllActivities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'All Activities',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _activitiesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  children: [
                    Icon(Icons.error, color: Colors.red, size: 40),
                    SizedBox(height: 8),
                    Text('Error loading activities'),
                  ],
                ),
              );
            }

            final activities = snapshot.data ?? [];

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.75,
              ),
              itemCount: activities.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _onActivityTap(activities[index]['title']!),
                  child: _buildActivityCard(activities[index]),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecentActivities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activities',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: StreamBuilder<QuerySnapshot>(
            stream: _recentActivitiesStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Error loading recent activities: ${snapshot.error}');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              final activities = snapshot.data!.docs;

              if (activities.isEmpty) {
                return Center(
                  child: Text('No recent activities'),
                );
              }

              return Column(
                children: activities.map((doc) {
                  final activity = doc.data() as Map<String, dynamic>;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(activity['userAvatar'] ?? ''),
                      radius: 20,
                      child: activity['userAvatar'] == null
                          ? Icon(Icons.person, size: 20)
                          : null,
                    ),
                    title: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: activity['userName'] ?? 'User',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: ' ${activity['action']}',
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                    subtitle: Text(
                      _formatTimestamp(activity['timestamp']),
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Viewing ${activity['userName']}\'s activity')),
                      );
                    },
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 0, 0, 0),
            ),
            child: Text(
              'ServeSphere Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.event),
            title: const Text('Events'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/events');
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/notifications');
            },
          ),
          ListTile(
            leading: const Icon(Icons.leaderboard),
            title: const Text('Leaderboard'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/leaderboard');
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/profile');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/help');
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              try {
                await FirebaseAuth.instance.signOut();
                Navigator.pop(context);
              } catch (e) {
                print('Logout error: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Logout failed: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            child: Image.network(
              activity['imageUrl']!,
              height: 80,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 80,
                color: Colors.grey[200],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    Text('Image failed to load', style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 80,
                  color: Colors.grey[200],
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  activity['title']!,
                  style: const TextStyle(fontSize: 12, color: Colors.black),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${activity['count']!}+',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Activity Events Page to show events filtered by activity type
class ActivityEventsPage extends StatelessWidget {
  final String activityType;

  const ActivityEventsPage({super.key, required this.activityType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$activityType Events'),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event, size: 80, color: Colors.green),
            SizedBox(height: 16),
            Text(
              'Events for $activityType',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'This page would show all events related to $activityType',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}