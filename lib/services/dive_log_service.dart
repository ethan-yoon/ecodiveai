import 'package:intl/intl.dart';
import '../models/dive_log.dart';

class DiveLogService {
  final Map<DateTime, List<DiveLog>> _diveLogs = {
    DateTime(2025, 3, 5): [
      DiveLog(
        logNo: '001',
        date: '2025-03-05',
        location: 'Malapascua',
        point: 'Montoya Point',
        diveShop: 'Sea Explorers',
        airIn: '200',
        airOut: '50',
        nitroxMix: '32',
        timeIn: '09:00',
        timeOut: '09:45',
        surfaceInterval: '1h',
        visibility: '15',
        surfTemp: '28',
        waterTemp: '26',
        avgDepth: '30m',
        maxDepth: '32m',
        suitThickness: '3',
        suitType: 'Wet',
        weight: '10kg',
        safetyStop: 'Yes',
        equipment: 'Photo, SMB',
        weather: 'Sunny',
        notes: 'Great visibility',
        voiceMemo: 'Recorded Voice Memo Here',
        purpose: 'Fun',
        time: '',
      ),
    ],
    DateTime(2025, 3, 6): [
      DiveLog(
        logNo: '002',
        date: '2025-03-06',
        location: 'Cebu',
        point: 'House Reef',
        diveShop: 'Aquatica Dive Center',
        airIn: '210',
        airOut: '60',
        nitroxMix: '36',
        timeIn: '10:00',
        timeOut: '10:50',
        surfaceInterval: '2h',
        visibility: '20',
        surfTemp: '29',
        waterTemp: '27',
        avgDepth: '40m',
        maxDepth: '42m',
        suitThickness: '5',
        suitType: 'Semidry',
        weight: '12kg',
        safetyStop: 'Yes',
        equipment: 'Video, Knife',
        weather: 'Cloudy',
        notes: 'Strong current',
        voiceMemo: 'Recorded Voice Memo Here',
        purpose: 'Training',
        time: '',
      ),
    ],
  };

  List<DiveLog> getEventsForDay(DateTime day) {
    final events = _diveLogs[DateTime(day.year, day.month, day.day)] ?? [];
    print("Events for $day: $events");
    return events;
  }

  void addDiveLog(DateTime day, DiveLog log) {
    final key = DateTime(day.year, day.month, day.day);
    if (_diveLogs[key] != null) {
      _diveLogs[key]!.add(log);
    } else {
      _diveLogs[key] = [log];
    }
  }

  void editDiveLog(DateTime originalDay, DateTime newDay, int index, DiveLog updatedLog) {
    final originalKey = DateTime(originalDay.year, originalDay.month, originalDay.day);
    final newKey = DateTime(newDay.year, newDay.month, newDay.day);
    if (_diveLogs[originalKey] != null && _diveLogs[originalKey]!.length > index) {
      _diveLogs[originalKey]!.removeAt(index);
      if (_diveLogs[originalKey]!.isEmpty) _diveLogs.remove(originalKey);
    }
    if (_diveLogs[newKey] != null) {
      _diveLogs[newKey]!.add(updatedLog);
    } else {
      _diveLogs[newKey] = [updatedLog];
    }
    print("After edit, diveLogs: $_diveLogs");
  }

  Map<String, List<MapEntry<DateTime, List<DiveLog>>>> getGroupedLogs() {
    Map<String, List<MapEntry<DateTime, List<DiveLog>>>> groupedLogs = {};
    _diveLogs.forEach((date, logs) {
      String yearMonth = DateFormat('yyyy-MM').format(date);
      if (!groupedLogs.containsKey(yearMonth)) groupedLogs[yearMonth] = [];
      groupedLogs[yearMonth]!.add(MapEntry(date, logs));
    });
    return groupedLogs;
  }
}