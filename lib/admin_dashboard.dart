import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_edit_event.dart';
import 'event_model.dart';
import 'event_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final EventService _eventService = EventService();

  int totalEvents = 0;
  int totalParticipants = 0;
  int upcomingEvents = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Summary Cards
            StreamBuilder<List<EventModel>>(
              stream: _eventService.getEvents(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSummaryCard("Total Events", 0, Colors.blue),
                      _buildSummaryCard("Participants", 0, Colors.green),
                      _buildSummaryCard("Upcoming", 0, Colors.orange),
                    ],
                  );
                }

                final events = snapshot.data!;

                totalEvents = events.length;
                totalParticipants =
                    events.fold(0, (sum, e) => sum + e.joinedCount);
                upcomingEvents = events
                    .where((e) => e.dateTime.isAfter(DateTime.now()))
                    .length;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSummaryCard("Total Events", totalEvents, Colors.blue),
                    _buildSummaryCard(
                        "Participants", totalParticipants, Colors.green),
                    _buildSummaryCard("Upcoming", upcomingEvents, Colors.orange),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),

            // Event List
            Expanded(
              child: StreamBuilder<List<EventModel>>(
                stream: _eventService.getEvents(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text(
                          "No events created yet",
                          style: TextStyle(fontSize: 16),
                        ));
                  }

                  final events = snapshot.data!;

                  return ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];

                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: event.imageUrl.isNotEmpty
                              ? Image.network(
                            event.imageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          )
                              : Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.image),
                          ),
                          title: Text(event.title),
                          subtitle: Text(
                              "${event.category} • ${event.location} • ${event.dateTime.toLocal()}"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          AddEditEventScreen(event: event),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon:
                                const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _eventService.deleteEvent(event.id);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // Floating button to add event
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditEventScreen()),
          );
        },
      ),
    );
  }

  // Helper: Summary Card
  Widget _buildSummaryCard(String title, int count, Color color) {
    return Expanded(
      child: Card(
        color: color,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Text(
                count.toString(),
                style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
