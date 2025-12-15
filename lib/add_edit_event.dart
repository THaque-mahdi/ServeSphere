import 'package:flutter/material.dart';
import 'event_model.dart';
import 'event_service.dart';

class AddEditEventScreen extends StatefulWidget {
  final EventModel? event;

  const AddEditEventScreen({super.key, this.event});

  @override
  State<AddEditEventScreen> createState() => _AddEditEventScreenState();
}

class _AddEditEventScreenState extends State<AddEditEventScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _maxParticipantsController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  DateTime? _selectedDate;

  final EventService _eventService = EventService();

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      _titleController.text = widget.event!.title;
      _categoryController.text = widget.event!.category;
      _descriptionController.text = widget.event!.description;
      _locationController.text = widget.event!.location;
      _maxParticipantsController.text = widget.event!.maxParticipants.toString();
      _imageController.text = widget.event!.imageUrl;
      _selectedDate = widget.event!.dateTime;
    }
  }

  void _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveEvent() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null) return;

    final event = EventModel(
      id: widget.event?.id ?? '',
      title: _titleController.text.trim(),
      category: _categoryController.text.trim(),
      description: _descriptionController.text.trim(),
      location: _locationController.text.trim(),
      dateTime: _selectedDate!,
      maxParticipants: int.parse(_maxParticipantsController.text.trim()),
      joinedCount: widget.event?.joinedCount ?? 0,
      imageUrl: _imageController.text.trim(),
    );

    if (widget.event == null) {
      await _eventService.addEvent(event);
    } else {
      await _eventService.updateEvent(event);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event == null ? "Add Event" : "Edit Event"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Title"),
                validator: (val) => val == null || val.isEmpty ? "Enter title" : null,
              ),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: "Category"),
                validator: (val) => val == null || val.isEmpty ? "Enter category" : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
                validator: (val) => val == null || val.isEmpty ? "Enter description" : null,
              ),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: "Location"),
                validator: (val) => val == null || val.isEmpty ? "Enter location" : null,
              ),
              TextFormField(
                controller: _maxParticipantsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Max Participants"),
                validator: (val) {
                  if (val == null || val.isEmpty) return "Enter max participants";
                  if (int.tryParse(val) == null) return "Enter a valid number";
                  return null;
                },
              ),
              TextFormField(
                controller: _imageController,
                decoration: const InputDecoration(labelText: "Image URL"),
                validator: (val) => val == null || val.isEmpty ? "Enter image URL" : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(_selectedDate != null
                    ? "Date: ${_selectedDate!.toLocal()}".split(' ')[0]
                    : "Pick Event Date"),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveEvent,
                child: Text(widget.event == null ? "Add Event" : "Update Event"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
