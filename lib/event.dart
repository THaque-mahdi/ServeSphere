import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _selectedFilter = 'upcoming'; // 'upcoming', 'past', 'my_events'

  // Sample events with reminders
  final List<Map<String, dynamic>> events = [
    {
      'id': 'tree_plant_1',
      'title': 'Community Tree Planting',
      'description': 'Join us for a tree planting event at Central Park. We\'ll be planting 100+ saplings to help the environment.',
      'dateTime': DateTime.now().add(Duration(days: 2, hours: 9)),
      'location': 'Central Park, Main Entrance',
      'imageUrl': 'https://images.stockcake.com/public/9/0/1/901d6234-d8ad-4bb3-99d2-0232a463c6a5_large/planting-small-tree-stockcake.jpg',
      'participantsCount': 45,
      'maxParticipants': 100,
      'organizer': 'Green Earth Foundation',
      'reminderSet': true,
      'category': 'Environment',
      'status': 'upcoming',
    },
    {
      'id': 'clean_city_1',
      'title': 'City Cleanup Drive',
      'description': 'Help us clean up the downtown area. Gloves and bags will be provided.',
      'dateTime': DateTime.now().add(Duration(days: 5, hours: 14)),
      'location': 'Downtown City Center',
      'imageUrl': 'https://images.unsplash.com/photo-1521791136064-7986c2920216?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
      'participantsCount': 89,
      'maxParticipants': 150,
      'organizer': 'Clean City Initiative',
      'reminderSet': false,
      'category': 'Cleanup',
      'status': 'upcoming',
    },
    {
      'id': 'blood_donation_1',
      'title': 'Blood Donation Camp',
      'description': 'Emergency blood donation drive. All blood types needed.',
      'dateTime': DateTime.now().add(Duration(days: 1, hours: 10)),
      'location': 'City Hospital, Blood Bank',
      'imageUrl': 'https://www.gynecoloncol.com/wp-content/uploads/2020/10/2171-blood-donation.jpg',
      'participantsCount': 23,
      'maxParticipants': 50,
      'organizer': 'Red Cross Society',
      'reminderSet': true,
      'category': 'Health',
      'status': 'upcoming',
    },
    {
      'id': 'food_drive_1',
      'title': 'Food Donation Collection',
      'description': 'Collecting non-perishable food items for local shelters.',
      'dateTime': DateTime.now().add(Duration(days: 3, hours: 11)),
      'location': 'Community Center Hall',
      'imageUrl': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
      'participantsCount': 34,
      'maxParticipants': 80,
      'organizer': 'Food for All',
      'reminderSet': false,
      'category': 'Food',
      'status': 'upcoming',
    },
    {
      'id': 'past_event_1',
      'title': 'Beach Cleanup',
      'description': 'Monthly beach cleanup event',
      'dateTime': DateTime.now().subtract(Duration(days: 7)),
      'location': 'Sunset Beach',
      'imageUrl': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
      'participantsCount': 67,
      'maxParticipants': 100,
      'organizer': 'Ocean Protection Group',
      'reminderSet': false,
      'category': 'Cleanup',
      'status': 'completed',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Events'),
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
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(value: 'upcoming', child: Text('Upcoming Events')),
              PopupMenuItem(value: 'past', child: Text('Past Events')),
              PopupMenuItem(value: 'my_events', child: Text('My Events')),
              PopupMenuItem(value: 'with_reminders', child: Text('Events with Reminders')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          _buildStatsBar(),
          Expanded(
            child: _buildEventsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateEventDialog(context);
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
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
          _buildFilterChip('Upcoming', 'upcoming'),
          SizedBox(width: 8),
          _buildFilterChip('Past Events', 'past'),
          SizedBox(width: 8),
          _buildFilterChip('My Events', 'my_events'),
          SizedBox(width: 8),
          _buildFilterChip('Reminders', 'with_reminders'),
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

  Widget _buildStatsBar() {
    final upcomingCount = events.where((event) => event['status'] == 'upcoming').length;
    final reminderCount = events.where((event) => event['reminderSet'] == true).length;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        border: Border(bottom: BorderSide(color: Colors.green[100]!)),
      ),
      child: Row(
        children: [
          _buildStatItem('$upcomingCount', 'Upcoming'),
          SizedBox(width: 16),
          _buildStatItem('$reminderCount', 'Reminders'),
          Spacer(),
          Icon(Icons.calendar_today, color: Colors.green, size: 20),
          SizedBox(width: 4),
          Text(
            _getCurrentDate(),
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
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
            color: Colors.green,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.green[700],
          ),
        ),
      ],
    );
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${monthNames[now.month - 1]} ${now.day}, ${now.year}';
  }

  Widget _buildEventsList() {
    final filteredEvents = _getFilteredEvents();

    if (filteredEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              _getEmptyStateMessage(),
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            if (_selectedFilter == 'upcoming')
              ElevatedButton(
                onPressed: () {
                  _showCreateEventDialog(context);
                },
                child: Text('Create Event'),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredEvents.length,
      itemBuilder: (context, index) {
        final event = filteredEvents[index];
        return _buildEventCard(event);
      },
    );
  }

  List<Map<String, dynamic>> _getFilteredEvents() {
    final now = DateTime.now();

    switch (_selectedFilter) {
      case 'upcoming':
        return events.where((event) => event['status'] == 'upcoming').toList();
      case 'past':
        return events.where((event) => event['status'] == 'completed').toList();
      case 'my_events':
        return events.where((event) => event['participantsCount'] > 0).toList();
      case 'with_reminders':
        return events.where((event) => event['reminderSet'] == true).toList();
      default:
        return events;
    }
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    final dateTime = event['dateTime'] as DateTime;
    final isUpcoming = event['status'] == 'upcoming';
    final daysUntil = dateTime.difference(DateTime.now()).inDays;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      child: Column(
        children: [
          // Event Image and Status
          Stack(
            children: [
              if (event['imageUrl'] != null)
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    event['imageUrl'],
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 150,
                      color: Colors.grey[200],
                      child: Icon(Icons.event, size: 50, color: Colors.grey),
                    ),
                  ),
                ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    event['category'],
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isUpcoming ? Colors.blue : Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isUpcoming ? 'In ${daysUntil}d' : 'Completed',
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),

          // Event Details
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        event['title'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        event['reminderSet'] ? Icons.notifications_active : Icons.notifications_none,
                        color: event['reminderSet'] ? Colors.green : Colors.grey,
                      ),
                      onPressed: () {
                        _toggleReminder(event);
                      },
                    ),
                  ],
                ),
                SizedBox(height: 8),

                // Date and Time
                Row(
                  children: [
                    Icon(Icons.event, size: 16, color: Colors.grey),
                    SizedBox(width: 8),
                    Text(
                      _formatEventDateTime(dateTime),
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                SizedBox(height: 4),

                // Location
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        event['location'],
                        style: TextStyle(color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),

                // Organizer
                Row(
                  children: [
                    Icon(Icons.people, size: 16, color: Colors.grey),
                    SizedBox(width: 8),
                    Text(
                      'Organized by ${event['organizer']}',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                SizedBox(height: 12),

                // Description
                Text(
                  event['description'],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                SizedBox(height: 12),

                // Participants and Action Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.people_outline, size: 16, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          '${event['participantsCount']}/${event['maxParticipants']}',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        if (isUpcoming)
                          OutlinedButton(
                            onPressed: () {
                              _showEventDetails(event);
                            },
                            child: Text('Details'),
                          ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            if (isUpcoming) {
                              _joinEvent(event);
                            } else {
                              _showEventDetails(event);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isUpcoming ? Colors.green : Colors.grey,
                          ),
                          child: Text(
                            isUpcoming ? 'Join Event' : 'View Details',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatEventDateTime(DateTime dateTime) {
    final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final month = monthNames[dateTime.month - 1];
    final day = dateTime.day;
    final year = dateTime.year;
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour < 12 ? 'AM' : 'PM';

    return '$month $day, $year • $hour:$minute $period';
  }

  String _getEmptyStateMessage() {
    switch (_selectedFilter) {
      case 'upcoming':
        return 'No upcoming events';
      case 'past':
        return 'No past events';
      case 'my_events':
        return 'You haven\'t joined any events yet';
      case 'with_reminders':
        return 'No events with reminders';
      default:
        return 'No events found';
    }
  }

  void _toggleReminder(Map<String, dynamic> event) {
    setState(() {
      event['reminderSet'] = !event['reminderSet'];
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            event['reminderSet']
                ? 'Reminder set for ${event['title']}'
                : 'Reminder removed for ${event['title']}'
        ),
      ),
    );
  }

  void _joinEvent(Map<String, dynamic> event) {
    setState(() {
      event['participantsCount']++;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('You have joined ${event['title']}'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              event['participantsCount']--;
            });
          },
        ),
      ),
    );
  }

  void _showEventDetails(Map<String, dynamic> event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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
              event['title'],
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            // Add more event details here
            Text('Event details would be shown here'),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Search Events'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search events...',
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

  void _showCreateEventDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Create New Event'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Event creation form would go here'),
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
                SnackBar(content: Text('Event created successfully!')),
              );
            },
            child: Text('Create Event'),
          ),
        ],
      ),
    );
  }
}