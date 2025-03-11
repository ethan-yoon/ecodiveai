import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../models/dive_log.dart';
import '../../services/dive_log_service.dart';
import '../../widgets/add_log_dialog.dart';
import '../../widgets/edit_log_dialog.dart';

class DiveLogAnalyticsPage extends StatefulWidget {
  @override
  _DiveLogPageState createState() => _DiveLogPageState();
}

class _DiveLogPageState extends State<DiveLogAnalyticsPage> {
  late final ValueNotifier<List<DiveLog>> _selectedEvents;
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  bool _isCalendarView = true;
  final DiveLogService _diveLogService = DiveLogService();

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_diveLogService.getEventsForDay(_selectedDay));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('Dive Log'), backgroundColor: Colors.blue, foregroundColor: Colors.white),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("View Mode:", style: TextStyle(color: Colors.black)),
                ToggleButtons(
                  children: [Icon(Icons.calendar_today), Icon(Icons.list)],
                  isSelected: [_isCalendarView, !_isCalendarView],
                  onPressed: (index) {
                    setState(() => _isCalendarView = index == 0);
                  },
                  color: Colors.black,
                  selectedColor: Colors.blue,
                  fillColor: Colors.blue.withOpacity(0.1),
                ),
              ],
            ),
          ),
          if (_isCalendarView)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                DateFormat('yyyy MMMM').format(_focusedDay),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
          Expanded(
            child: _isCalendarView
                ? Column(
                    children: [
                      Container(
                        color: Colors.white,
                        padding: EdgeInsets.all(8.0),
                        child: TableCalendar<DiveLog>(
                          firstDay: DateTime.utc(2020, 1, 1),
                          lastDay: DateTime.utc(2030, 12, 31),
                          focusedDay: _focusedDay,
                          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                          onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                              _selectedDay = selectedDay;
                              _focusedDay = focusedDay;
                              _selectedEvents.value = _diveLogService.getEventsForDay(selectedDay);
                            });
                          },
                          onPageChanged: (focusedDay) {
                            setState(() => _focusedDay = focusedDay);
                          },
                          calendarFormat: CalendarFormat.month,
                          availableCalendarFormats: const {CalendarFormat.month: 'Month'},
                          headerStyle: HeaderStyle(
                            formatButtonVisible: false,
                            titleTextStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                            leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black),
                            rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black),
                          ),
                          eventLoader: _diveLogService.getEventsForDay,
                          calendarStyle: CalendarStyle(
                            defaultTextStyle: TextStyle(color: Colors.black),
                            weekendTextStyle: TextStyle(color: Colors.red),
                            todayTextStyle: TextStyle(color: Colors.white),
                            todayDecoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                            selectedTextStyle: TextStyle(color: Colors.white),
                            selectedDecoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                            outsideTextStyle: TextStyle(color: Colors.grey),
                          ),
                          calendarBuilders: CalendarBuilders(
                            markerBuilder: (context, date, events) => events.isNotEmpty
                                ? Positioned(
                                    right: 1,
                                    bottom: 1,
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blue),
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ValueListenableBuilder<List<DiveLog>>(
                          valueListenable: _selectedEvents,
                          builder: (context, events, _) => events.isEmpty
                              ? Center(child: Text('No dive logs for this day.', style: TextStyle(color: Colors.black)))
                              : ListView.builder(
                                  itemCount: events.length,
                                  itemBuilder: (context, index) {
                                    final log = events[index];
                                    return ListTile(
                                      title: Text('${log.location} - ${log.avgDepth} - ${log.time}', style: TextStyle(color: Colors.black)),
                                      subtitle: Text('Notes: ${log.notes}', style: TextStyle(color: Colors.black54)),
                                      trailing: IconButton(
                                        icon: Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () => showEditLogDialog(
                                          context,
                                          index,
                                          log,
                                          (originalDay, newDay, index, updatedLog) {
                                            setState(() {
                                              _diveLogService.editDiveLog(originalDay, newDay, index, updatedLog);
                                              _selectedDay = newDay;
                                              _focusedDay = newDay;
                                              _selectedEvents.value = _diveLogService.getEventsForDay(_selectedDay);
                                            });
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ),
                    ],
                  )
                : ListView(children: _buildDiveLogList()),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () => showAddLogDialog(
                context,
                _selectedDay,
                (day, log) {
                  setState(() {
                    _diveLogService.addDiveLog(day, log);
                    _selectedEvents.value = _diveLogService.getEventsForDay(_selectedDay);
                  });
                },
              ),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
              child: Text('Add Dive Log'),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDiveLogList() {
    var groupedLogs = _diveLogService.getGroupedLogs();
    List<Widget> widgets = [];
    var sortedKeys = groupedLogs.keys.toList()..sort((a, b) => b.compareTo(a));
    for (String yearMonth in sortedKeys) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
          child: Text(yearMonth, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black)),
        ),
      );
      var entries = groupedLogs[yearMonth]!..sort((a, b) => b.key.compareTo(a.key));
      for (var entry in entries) {
        for (var log in entry.value) {
          widgets.add(
            ListTile(
              title: Text('${DateFormat('dd').format(entry.key)} - ${log.location} - ${log.avgDepth} - ${log.time}', style: TextStyle(color: Colors.black)),
              subtitle: Text('Notes: ${log.notes}', style: TextStyle(color: Colors.black54)),
              onTap: () => showEditLogDialog(
                context,
                entry.value.indexOf(log),
                log,
                (originalDay, newDay, index, updatedLog) {
                  setState(() {
                    _diveLogService.editDiveLog(originalDay, newDay, index, updatedLog);
                    _selectedDay = newDay;
                    _focusedDay = newDay;
                    _selectedEvents.value = _diveLogService.getEventsForDay(_selectedDay);
                  });
                },
              ),
            ),
          );
        }
      }
    }
    return widgets;
  }
}