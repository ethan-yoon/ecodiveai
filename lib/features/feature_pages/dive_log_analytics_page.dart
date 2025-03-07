import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:intl/intl.dart';

class DiveLogAnalyticsPage extends StatefulWidget {
  @override
  _DiveLogPageState createState() => _DiveLogPageState();
}

class _DiveLogPageState extends State<DiveLogAnalyticsPage> {
  late final ValueNotifier<List<Map<String, String>>> _selectedEvents;
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _isCalendarView = true;

  final Map<DateTime, List<Map<String, String>>> _diveLogs = {
    DateTime(2025, 3, 5): [
      {
        'region': 'Malapascua',
        'depth': '30m',
        'time': '45min',
        'notes': 'Great visibility',
        'voiceMemo': 'Recorded Voice Memo Here',
      },
    ],
    DateTime(2025, 3, 6): [
      {
        'region': 'Cebu',
        'depth': '40m',
        'time': '50min',
        'notes': 'Strong current',
        'voiceMemo': 'Recorded Voice Memo Here',
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay));
    _speech = stt.SpeechToText();
  }

  List<Map<String, String>> _getEventsForDay(DateTime day) {
    final events = _diveLogs[DateTime(day.year, day.month, day.day)] ?? [];
    print("Events for $day: $events");
    return events;
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  void _addDiveLog(DateTime day, Map<String, String> log) {
    setState(() {
      final key = DateTime(day.year, day.month, day.day);
      if (_diveLogs[key] != null) {
        _diveLogs[key]?.add(log);
      } else {
        _diveLogs[key] = [log];
      }
      _selectedEvents.value = _getEventsForDay(_selectedDay);
    });
  }

  void _editDiveLog(DateTime day, int index, Map<String, String> updatedLog) {
    setState(() {
      final key = DateTime(day.year, day.month, day.day);
      _diveLogs[key]?[index] = updatedLog;
      _selectedEvents.value = _getEventsForDay(_selectedDay);
    });
  }

  void _toggleListening() async {
    if (_isListening) {
      _speech.stop();
      setState(() {
        _isListening = false;
      });
    } else {
      bool available = await _speech.initialize();
      if (available) {
        _speech.listen(onResult: (result) {
          setState(() {
            _isListening = true;
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dive Log'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("View Mode:"),
                ToggleButtons(
                  children: [Icon(Icons.calendar_today), Icon(Icons.list)],
                  isSelected: [_isCalendarView, !_isCalendarView],
                  onPressed: (index) {
                    setState(() {
                      _isCalendarView = index == 0;
                    });
                  },
                ),
              ],
            ),
          ),
          // 캘린더 뷰일 때만 년월 표시
          if (_isCalendarView)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                DateFormat('yyyy MMMM').format(_focusedDay),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          Expanded(
            child: _isCalendarView
                ? Column(
                    children: [
                      TableCalendar<Map<String, String>>(
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                            _selectedEvents.value = _getEventsForDay(selectedDay);
                          });
                        },
                        onPageChanged: (focusedDay) {
                          setState(() {
                            _focusedDay = focusedDay;
                          });
                        },
                        calendarFormat: CalendarFormat.month,
                        availableCalendarFormats: const {
                          CalendarFormat.month: 'Month',
                        },
                        headerStyle: HeaderStyle(
                          formatButtonVisible: false,
                        ),
                        eventLoader: _getEventsForDay,
                        calendarStyle: CalendarStyle(
                          defaultTextStyle: TextStyle(color: Colors.black),
                          weekendTextStyle: TextStyle(color: Colors.red),
                          todayTextStyle: TextStyle(color: Colors.white),
                          todayDecoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          selectedTextStyle: TextStyle(color: Colors.white),
                          selectedDecoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          outsideTextStyle: TextStyle(color: Colors.grey),
                        ),
                        calendarBuilders: CalendarBuilders(
                          markerBuilder: (context, date, events) {
                            if (events.isNotEmpty) {
                              return Positioned(
                                right: 1,
                                bottom: 1,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.blue,
                                  ),
                                ),
                              );
                            }
                            return null;
                          },
                        ),
                      ),
                      Expanded(
                        child: ValueListenableBuilder<List<Map<String, String>>>(
                          valueListenable: _selectedEvents,
                          builder: (context, events, _) {
                            if (events.isEmpty) {
                              return Center(child: Text('No dive logs for this day.'));
                            }
                            return ListView.builder(
                              itemCount: events.length,
                              itemBuilder: (context, index) {
                                final log = events[index];
                                return ListTile(
                                  title: Text('${log['region']} - ${log['depth']} - ${log['time']}'),
                                  subtitle: Text('Notes: ${log['notes']}'),
                                  trailing: IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () => _showEditLogDialog(context, index, log),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  )
                : ListView(
                    children: _buildDiveLogList(),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () => _showAddLogDialog(context),
              child: Text('Add Dive Log'),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDiveLogList() {
    Map<String, List<MapEntry<DateTime, List<Map<String, String>>>>> groupedLogs = {};
    
    _diveLogs.forEach((date, logs) {
      String yearMonth = DateFormat('yyyy-MM').format(date);
      if (!groupedLogs.containsKey(yearMonth)) {
        groupedLogs[yearMonth] = [];
      }
      groupedLogs[yearMonth]!.add(MapEntry(date, logs));
    });

    List<Widget> widgets = [];
    
    var sortedKeys = groupedLogs.keys.toList()
      ..sort((a, b) => b.compareTo(a));
    
    for (String yearMonth in sortedKeys) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
          child: Text(
            yearMonth,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black,
            ),
          ),
        ),
      );
      
      var entries = groupedLogs[yearMonth]!
        ..sort((a, b) => b.key.compareTo(a.key));
      
      for (var entry in entries) {
        for (var log in entry.value) {
          widgets.add(
            ListTile(
              title: Text('${DateFormat('dd').format(entry.key)} - ${log['region']} - ${log['depth']} - ${log['time']}'),
              subtitle: Text('Notes: ${log['notes']}'),
              onTap: () => _showEditLogDialog(
                context,
                entry.value.indexOf(log),
                log,
              ),
            ),
          );
        }
      }
    }
    
    return widgets;
  }

  void _showAddLogDialog(BuildContext context) {
    TextEditingController _regionController = TextEditingController();
    TextEditingController _depthController = TextEditingController();
    TextEditingController _timeController = TextEditingController();
    TextEditingController _notesController = TextEditingController();
    String _voiceMemo = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Dive Log'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: _regionController, decoration: InputDecoration(hintText: 'Enter region')),
                TextField(controller: _depthController, decoration: InputDecoration(hintText: 'Enter depth')),
                TextField(controller: _timeController, decoration: InputDecoration(hintText: 'Enter time')),
                TextField(controller: _notesController, decoration: InputDecoration(hintText: 'Enter notes')),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _toggleListening,
                  child: Text(_isListening ? 'Stop Recording' : 'Start Recording'),
                ),
                if (_voiceMemo.isNotEmpty) Text(_voiceMemo),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String region = _regionController.text;
                String depth = _depthController.text;
                String time = _timeController.text;
                String notes = _notesController.text;

                if (region.isNotEmpty && depth.isNotEmpty && time.isNotEmpty) {
                  Map<String, String> newLog = {
                    'region': region,
                    'depth': depth,
                    'time': time,
                    'notes': notes,
                    'voiceMemo': _voiceMemo,
                  };
                  _addDiveLog(_selectedDay, newLog);
                }
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showEditLogDialog(BuildContext context, int index, Map<String, String> log) {
    TextEditingController _regionController = TextEditingController(text: log['region']);
    TextEditingController _depthController = TextEditingController(text: log['depth']);
    TextEditingController _timeController = TextEditingController(text: log['time']);
    TextEditingController _notesController = TextEditingController(text: log['notes']);
    String _voiceMemo = log['voiceMemo'] ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Dive Log'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: _regionController, decoration: InputDecoration(hintText: 'Enter region')),
                TextField(controller: _depthController, decoration: InputDecoration(hintText: 'Enter depth')),
                TextField(controller: _timeController, decoration: InputDecoration(hintText: 'Enter time')),
                TextField(controller: _notesController, decoration: InputDecoration(hintText: 'Enter notes')),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _toggleListening,
                  child: Text(_isListening ? 'Stop Recording' : 'Start Recording'),
                ),
                if (_voiceMemo.isNotEmpty) Text(_voiceMemo),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String region = _regionController.text;
                String depth = _depthController.text;
                String time = _timeController.text;
                String notes = _notesController.text;

                if (region.isNotEmpty && depth.isNotEmpty && time.isNotEmpty) {
                  Map<String, String> updatedLog = {
                    'region': region,
                    'depth': depth,
                    'time': time,
                    'notes': notes,
                    'voiceMemo': _voiceMemo,
                  };
                  _editDiveLog(_selectedDay, index, updatedLog);
                }
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
}