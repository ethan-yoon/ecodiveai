import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../models/dive_log.dart';
import 'speech_input_dialog.dart';
import 'wave_painter.dart';

Future<void> showEditLogDialog(
  BuildContext context,
  int index,
  DiveLog log,
  Function(DateTime, DateTime, int, DiveLog) onEdit,
) async {
  final stt.SpeechToText _speech = stt.SpeechToText();
  TextEditingController _logNoController = TextEditingController(text: log.logNo ?? '');
  TextEditingController _dateController = TextEditingController(text: log.date ?? '');
  TextEditingController _locationController = TextEditingController(text: log.location ?? '');
  TextEditingController _pointController = TextEditingController(text: log.point ?? '');
  TextEditingController _diveShopController = TextEditingController(text: log.diveShop ?? '');
  TextEditingController _airInController = TextEditingController(text: log.airIn ?? '');
  TextEditingController _airOutController = TextEditingController(text: log.airOut ?? '');
  TextEditingController _nitroxMixController = TextEditingController(text: log.nitroxMix?.isNotEmpty == true ? log.nitroxMix! : '21');
  TextEditingController _timeInController = TextEditingController();
  TextEditingController _timeOutController = TextEditingController();
  TextEditingController _surfaceIntervalController = TextEditingController(text: log.surfaceInterval ?? '');
  TextEditingController _visibilityController = TextEditingController(text: log.visibility ?? '');
  TextEditingController _surfTempController = TextEditingController(text: log.surfTemp ?? '');
  TextEditingController _waterTempController = TextEditingController(text: log.waterTemp ?? '');
  TextEditingController _avgDepthController = TextEditingController(text: log.avgDepth ?? '');
  TextEditingController _maxDepthController = TextEditingController(text: log.maxDepth ?? '');
  TextEditingController _notesController = TextEditingController(text: log.notes ?? '');
  TextEditingController _weightController = TextEditingController(text: log.weight ?? '');
  TextEditingController _suitThicknessController = TextEditingController(text: log.suitThickness ?? '');
  String _voiceMemo = log.voiceMemo ?? '';
  bool _isSkin = log.suitType == 'Skin', _isWet = log.suitType == 'Wet', _isSemidry = log.suitType == 'Semidry', _isDry = log.suitType == 'Dry', _safetyStop = log.safetyStop == 'Yes', _isFunDive = log.purpose == 'Fun', _isTrainingDive = log.purpose == 'Training', _is24HourFormat = true;
  List<String> _equipment = log.equipment?.split(', ') ?? [];
  List<String> _weatherOptions = ['Sunny', 'PartlyCloudy', 'Cloudy', 'Rainy'];
  List<bool> _weatherSelected = [false, false, false, false];
  String? initialWeather = log.weather;
  if (initialWeather != null) {
    int weatherIndex = _weatherOptions.indexOf(initialWeather);
    if (weatherIndex != -1) _weatherSelected[weatherIndex] = true;
  }
  TimeOfDay initialTimeIn = TimeOfDay.now(), initialTimeOut = TimeOfDay.now();
  if (log.timeIn != null && log.timeIn!.isNotEmpty) {
    final parts = log.timeIn!.split(':');
    if (parts.length == 2) {
      final hour = int.tryParse(parts[0]) ?? 0, minute = int.tryParse(parts[1]) ?? 0;
      initialTimeIn = TimeOfDay(hour: hour, minute: minute);
      _timeInController.text = _is24HourFormat ? '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}' : '${(hour % 12 == 0 ? 12 : hour % 12).toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} ${hour >= 12 ? 'PM' : 'AM'}';
    }
  }
  if (log.timeOut != null && log.timeOut!.isNotEmpty) {
    final parts = log.timeOut!.split(':');
    if (parts.length == 2) {
      final hour = int.tryParse(parts[0]) ?? 0, minute = int.tryParse(parts[1]) ?? 0;
      initialTimeOut = TimeOfDay(hour: hour, minute: minute);
      _timeOutController.text = _is24HourFormat ? '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}' : '${(hour % 12 == 0 ? 12 : hour % 12).toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} ${hour >= 12 ? 'PM' : 'AM'}';
    }
  }
  List<Map<String, dynamic>> equipmentOptions = [
    {'label': 'Reef Hook', 'value': 'ReefHook'},
    {'label': 'Photo', 'value': 'Photo'},
    {'label': 'Video', 'value': 'Video'},
    {'label': 'SMB', 'value': 'SMB'},
    {'label': 'Knife', 'value': 'Knife'},
    {'label': 'Lantern', 'value': 'Lantern'},
  ];
  List<Map<String, dynamic>> environmentOptions = [
    {'label': 'Beach', 'value': 'Beach'},
    {'label': 'Boat', 'value': 'Boat'},
    {'label': 'Liveaboard', 'value': 'Liveaboard'},
    {'label': 'Sunset', 'value': 'Sunset'},
    {'label': 'Night', 'value': 'Night'},
    {'label': 'Wall', 'value': 'Wall'},
    {'label': 'Drift', 'value': 'Drift'},
    {'label': 'Wreck', 'value': 'Wreck'},
    {'label': 'Cave', 'value': 'Cave'},
    {'label': 'Side Mount', 'value': 'SideMount'},
    {'label': 'Others', 'value': 'Others'},
  ];

  Future<void> _showWarningDialog(BuildContext context, String message, {VoidCallback? onOk}) async {
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Warning', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        content: Text(message, style: TextStyle(color: Colors.black)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              if (onOk != null) onOk();
            },
            child: Text('OK', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  await showDialog(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setDialogState) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Edit Dive Log', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black), borderRadius: BorderRadius.circular(8.0)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: TextFormField(controller: _logNoController, decoration: InputDecoration(labelText: 'Log No.', labelStyle: TextStyle(color: Colors.black), border: OutlineInputBorder()), style: TextStyle(color: Colors.black))),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _dateController,
                            readOnly: true,
                            decoration: InputDecoration(labelText: 'Date', labelStyle: TextStyle(color: Colors.black), border: OutlineInputBorder(), suffixIcon: Icon(Icons.calendar_today, color: Colors.black)),
                            style: TextStyle(color: Colors.black),
                            onTap: () async {
                              DateTime initialDate = DateTime.now();
                              if (_dateController.text.isNotEmpty) initialDate = DateFormat('yyyy-MM-dd').parse(_dateController.text);
                              final DateTime? picked = await showDatePicker(context: dialogContext, initialDate: initialDate, firstDate: DateTime(2000), lastDate: DateTime(2100));
                              if (picked != null) setDialogState(() => _dateController.text = DateFormat('yyyy-MM-dd').format(picked));
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text('Purpose', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        Checkbox(value: _isFunDive, onChanged: (value) => setDialogState(() { _isFunDive = value!; if (_isFunDive) _isTrainingDive = false; })),
                        Text('Fun', style: TextStyle(color: Colors.black)),
                        Checkbox(value: _isTrainingDive, onChanged: (value) => setDialogState(() { _isTrainingDive = value!; if (_isTrainingDive) _isFunDive = false; })),
                        Text('Training', style: TextStyle(color: Colors.black)),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text('Weather: ', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        ToggleButtons(
                          children: [
                            Icon(WeatherIcons.day_sunny, size: 20, color: Colors.black),
                            Icon(WeatherIcons.day_cloudy, size: 20, color: Colors.black),
                            Icon(WeatherIcons.cloud, size: 20, color: Colors.black),
                            Icon(WeatherIcons.rain, size: 20, color: Colors.black),
                          ],
                          isSelected: _weatherSelected,
                          onPressed: (index) => setDialogState(() { _weatherSelected = List.filled(4, false); _weatherSelected[index] = true; }),
                          color: Colors.black,
                          selectedColor: Colors.blue,
                          fillColor: Colors.blue.withOpacity(0.1),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    TextFormField(controller: _locationController, decoration: InputDecoration(labelText: 'Location', labelStyle: TextStyle(color: Colors.black), border: OutlineInputBorder()), style: TextStyle(color: Colors.black)),
                    SizedBox(height: 10),
                    TextFormField(controller: _pointController, decoration: InputDecoration(labelText: 'Point', labelStyle: TextStyle(color: Colors.black), border: OutlineInputBorder()), style: TextStyle(color: Colors.black)),
                    SizedBox(height: 10),
                    TextFormField(controller: _diveShopController, decoration: InputDecoration(labelText: 'Dive Shop', labelStyle: TextStyle(color: Colors.black), border: OutlineInputBorder()), style: TextStyle(color: Colors.black)),
                  ],
                ),
              ),
              SizedBox(height: 10),
              CustomPaint(painter: WavePainter(), child: Container(height: 30, width: double.infinity, color: Colors.lightBlueAccent.withOpacity(0.2))),
              Container(
                padding: EdgeInsets.all(8.0),
                color: Colors.lightBlueAccent.withOpacity(0.2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: TextFormField(controller: _airInController, decoration: InputDecoration(labelText: 'Air In (bar)', labelStyle: TextStyle(color: Colors.black), border: OutlineInputBorder()), style: TextStyle(color: Colors.black))),
                        SizedBox(width: 10),
                        Expanded(child: TextFormField(controller: _airOutController, decoration: InputDecoration(labelText: 'Air Out (bar)', labelStyle: TextStyle(color: Colors.black), border: OutlineInputBorder()), style: TextStyle(color: Colors.black))),
                        SizedBox(width: 10),
                        SizedBox(
                          width: 80,
                          child: TextFormField(
                            controller: _nitroxMixController,
                            decoration: InputDecoration(
                              labelText: 'Nitrox Mix',
                              labelStyle: TextStyle(color: Colors.black),
                              border: OutlineInputBorder(),
                              suffixText: '%',
                              suffixStyle: TextStyle(color: Colors.black),
                              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            ),
                            style: TextStyle(color: Colors.black),
                            keyboardType: TextInputType.number,
                            maxLength: 2,
                            buildCounter: (context, {required currentLength, required maxLength, required isFocused}) => SizedBox.shrink(),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              TextInputFormatter.withFunction((oldValue, newValue) => newValue.text.isEmpty ? newValue : (int.tryParse(newValue.text) == null ? oldValue : newValue)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Time Format:', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        ToggleButtons(
                          children: [Text('12h', style: TextStyle(color: Colors.black)), Text('24h', style: TextStyle(color: Colors.black))],
                          isSelected: [!_is24HourFormat, _is24HourFormat],
                          onPressed: (index) => setDialogState(() {
                            _is24HourFormat = index == 1;
                            if (_timeInController.text.isNotEmpty) {
                              final parts = _timeInController.text.split(':');
                              if (parts.length == 2) {
                                int hour = int.parse(parts[0]), minute = int.parse(parts[1].split(' ')[0]);
                                bool isPM = _timeInController.text.contains('PM');
                                if (isPM && hour != 12) hour += 12;
                                if (!isPM && hour == 12) hour = 0;
                                _timeInController.text = _is24HourFormat ? '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}' : '${(hour % 12 == 0 ? 12 : hour % 12).toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} ${hour >= 12 ? 'PM' : 'AM'}';
                              }
                            }
                            if (_timeOutController.text.isNotEmpty) {
                              final parts = _timeOutController.text.split(':');
                              if (parts.length == 2) {
                                int hour = int.parse(parts[0]), minute = int.parse(parts[1].split(' ')[0]);
                                bool isPM = _timeOutController.text.contains('PM');
                                if (isPM && hour != 12) hour += 12;
                                if (!isPM && hour == 12) hour = 0;
                                _timeOutController.text = _is24HourFormat ? '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}' : '${(hour % 12 == 0 ? 12 : hour % 12).toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} ${hour >= 12 ? 'PM' : 'AM'}';
                              }
                            }
                          }),
                          color: Colors.black,
                          selectedColor: Colors.blue,
                          fillColor: Colors.blue.withOpacity(0.1),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _timeInController,
                            readOnly: true,
                            decoration: InputDecoration(labelText: 'Time In', labelStyle: TextStyle(color: Colors.black), border: OutlineInputBorder(), suffixIcon: Icon(Icons.access_time, color: Colors.black)),
                            style: TextStyle(color: Colors.black),
                            onTap: () async {
                              final TimeOfDay? picked = await showTimePicker(
                                context: dialogContext,
                                initialTime: initialTimeIn,
                                builder: (context, child) => MediaQuery(data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: _is24HourFormat), child: child!),
                              );
                              if (picked != null) {
                                setDialogState(() {
                                  final hour = picked.hour, minute = picked.minute;
                                  _timeInController.text = _is24HourFormat ? '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}' : '${(hour % 12 == 0 ? 12 : hour % 12).toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} ${hour >= 12 ? 'PM' : 'AM'}';
                                });
                              }
                            },
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _timeOutController,
                            readOnly: true,
                            decoration: InputDecoration(labelText: 'Time Out', labelStyle: TextStyle(color: Colors.black), border: OutlineInputBorder(), suffixIcon: Icon(Icons.access_time, color: Colors.black)),
                            style: TextStyle(color: Colors.black),
                            onTap: () async {
                              final TimeOfDay? picked = await showTimePicker(
                                context: dialogContext,
                                initialTime: initialTimeOut,
                                builder: (context, child) => MediaQuery(data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: _is24HourFormat), child: child!),
                              );
                              if (picked != null) {
                                setDialogState(() {
                                  final hour = picked.hour, minute = picked.minute;
                                  _timeOutController.text = _is24HourFormat ? '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}' : '${(hour % 12 == 0 ? 12 : hour % 12).toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} ${hour >= 12 ? 'PM' : 'AM'}';
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    TextFormField(controller: _surfaceIntervalController, decoration: InputDecoration(labelText: 'Surface Interval', labelStyle: TextStyle(color: Colors.black), border: OutlineInputBorder()), style: TextStyle(color: Colors.black)),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: TextFormField(controller: _visibilityController, decoration: InputDecoration(labelText: 'Visibility', labelStyle: TextStyle(color: Colors.black), border: OutlineInputBorder(), suffixText: 'm', suffixStyle: TextStyle(color: Colors.black), contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)), style: TextStyle(color: Colors.black), keyboardType: TextInputType.number)),
                        SizedBox(width: 10),
                        Expanded(child: TextFormField(controller: _surfTempController, decoration: InputDecoration(labelText: 'Surf.Temp.', labelStyle: TextStyle(color: Colors.black), border: OutlineInputBorder(), suffixText: '°C', suffixStyle: TextStyle(color: Colors.black), contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)), style: TextStyle(color: Colors.black), keyboardType: TextInputType.number)),
                        SizedBox(width: 10),
                        Expanded(child: TextFormField(controller: _waterTempController, decoration: InputDecoration(labelText: 'Water Temp.', labelStyle: TextStyle(color: Colors.black), border: OutlineInputBorder(), suffixText: '°C', suffixStyle: TextStyle(color: Colors.black), contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)), style: TextStyle(color: Colors.black), keyboardType: TextInputType.number)),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: TextFormField(controller: _avgDepthController, decoration: InputDecoration(labelText: 'Avg Depth (m)', labelStyle: TextStyle(color: Colors.black), border: OutlineInputBorder()), style: TextStyle(color: Colors.black))),
                        SizedBox(width: 10),
                        Expanded(child: TextFormField(controller: _maxDepthController, decoration: InputDecoration(labelText: 'Max Depth (m)', labelStyle: TextStyle(color: Colors.black), border: OutlineInputBorder()), style: TextStyle(color: Colors.black))),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(children: [Checkbox(value: _safetyStop, onChanged: (value) => setDialogState(() => _safetyStop = value!)), Text('Safety Stop 5m 3min', style: TextStyle(color: Colors.black))]),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(8.0),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8.0)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Suit Information', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                          SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('Suit Thickness:', style: TextStyle(color: Colors.black)),
                              SizedBox(width: 10),
                              SizedBox(
                                width: 60,
                                child: TextFormField(
                                  controller: _suitThicknessController,
                                  decoration: InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8), suffixText: 'mm', suffixStyle: TextStyle(color: Colors.black)),
                                  style: TextStyle(color: Colors.black),
                                  keyboardType: TextInputType.number,
                                  maxLength: 1,
                                  buildCounter: (context, {required currentLength, required maxLength, required isFocused}) => SizedBox.shrink(),
                                ),
                              ),
                              SizedBox(width: 20),
                              Text('Suit Type:', style: TextStyle(color: Colors.black)),
                              SizedBox(width: 10),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Checkbox(value: _isSkin, onChanged: (value) => setDialogState(() { _isSkin = value!; if (_isSkin) { _isWet = false; _isSemidry = false; _isDry = false; } })),
                                  Text('Skin', style: TextStyle(color: Colors.black)),
                                  Checkbox(value: _isWet, onChanged: (value) => setDialogState(() { _isWet = value!; if (_isWet) { _isSkin = false; _isSemidry = false; _isDry = false; } })),
                                  Text('Wet', style: TextStyle(color: Colors.black)),
                                  Checkbox(value: _isSemidry, onChanged: (value) => setDialogState(() { _isSemidry = value!; if (_isSemidry) { _isSkin = false; _isWet = false; _isDry = false; } })),
                                  Text('Semidry', style: TextStyle(color: Colors.black)),
                                  Checkbox(value: _isDry, onChanged: (value) => setDialogState(() { _isDry = value!; if (_isDry) { _isSkin = false; _isWet = false; _isSemidry = false; } })),
                                  Text('Dry', style: TextStyle(color: Colors.black)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(children: [Expanded(child: TextFormField(controller: _weightController, decoration: InputDecoration(labelText: 'Weight (kg/lbs)', labelStyle: TextStyle(color: Colors.black), border: OutlineInputBorder()), style: TextStyle(color: Colors.black)))]),
                    SizedBox(height: 10),
                    Text('Equipment & Environment', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    Wrap(
                      spacing: 10,
                      children: equipmentOptions
                          .map((option) => Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Checkbox(
                                      value: _equipment.contains(option['value']),
                                      onChanged: (value) => setDialogState(() {
                                            if (value!) _equipment.add(option['value']);
                                            else _equipment.remove(option['value']);
                                          })),
                                  Text(option['label'], style: TextStyle(color: Colors.black)),
                                ],
                              ))
                          .toList() +
                          environmentOptions.map((option) => Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Checkbox(
                                      value: _equipment.contains(option['value']),
                                      onChanged: (value) => setDialogState(() {
                                            if (value!) _equipment.add(option['value']);
                                            else _equipment.remove(option['value']);
                                          })),
                                  Text(option['label'], style: TextStyle(color: Colors.black)),
                                ],
                              )).toList(),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _notesController,
                      decoration: InputDecoration(labelText: 'Notes', labelStyle: TextStyle(color: Colors.black), border: OutlineInputBorder()),
                      style: TextStyle(color: Colors.black),
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        final result = await showDialog<String>(context: dialogContext, builder: (context) => SpeechInputDialog(_speech));
                        if (result != null) setDialogState(() => _voiceMemo = result);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                      child: Text('AI Memo'),
                    ),
                    if (_voiceMemo.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8.0), child: Text('Voice Memo: $_voiceMemo', style: TextStyle(color: Colors.black))),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: Text('Cancel', style: TextStyle(color: Colors.blue))),
          TextButton(
            onPressed: () async {
              String nitroxMix = _nitroxMixController.text;
              int? nitroxValue = int.tryParse(nitroxMix);
              if (nitroxMix.isNotEmpty && (nitroxValue == null || nitroxValue < 21 || nitroxValue > 100)) {
                await _showWarningDialog(context, 'Nitrox Mix must be between 21% and 100%. Please correct the value.', onOk: () => setDialogState(() => _nitroxMixController.text = log.nitroxMix?.isNotEmpty == true ? log.nitroxMix! : '21'));
                return;
              }
              String timeIn = _timeInController.text, timeOut = _timeOutController.text;
              if (timeIn.isNotEmpty && timeOut.isNotEmpty) {
                int timeInHour, timeInMinute, timeOutHour, timeOutMinute;
                bool isTimeInPM = timeIn.contains('PM'), isTimeOutPM = timeOut.contains('PM');
                final timeInParts = timeIn.split(':'), timeOutParts = timeOut.split(':');
                timeInHour = int.parse(timeInParts[0]);
                timeInMinute = int.parse(timeInParts[1].split(' ')[0]);
                if (!_is24HourFormat) {
                  if (isTimeInPM && timeInHour != 12) timeInHour += 12;
                  if (!isTimeInPM && timeInHour == 12) timeInHour = 0;
                }
                timeOutHour = int.parse(timeOutParts[0]);
                timeOutMinute = int.parse(timeOutParts[1].split(' ')[0]);
                if (!_is24HourFormat) {
                  if (isTimeOutPM && timeOutHour != 12) timeOutHour += 12;
                  if (!isTimeOutPM && timeOutHour == 12) timeOutHour = 0;
                }
                final timeInMinutes = timeInHour * 60 + timeInMinute, timeOutMinutes = timeOutHour * 60 + timeOutMinute;
                if (timeOutMinutes <= timeInMinutes) {
                  await _showWarningDialog(context, 'Time Out must be later than Time In.', onOk: () => setDialogState(() => _timeOutController.text = log.timeOut ?? ''));
                  return;
                }
                timeIn = '${timeInHour.toString().padLeft(2, '0')}:${timeInMinute.toString().padLeft(2, '0')}';
                timeOut = '${timeOutHour.toString().padLeft(2, '0')}:${timeOutMinute.toString().padLeft(2, '0')}';
              } else {
                timeIn = log.timeIn ?? '';
                timeOut = log.timeOut ?? '';
              }
              String location = _locationController.text, point = _pointController.text, diveShop = _diveShopController.text, airIn = _airInController.text, airOut = _airOutController.text, surfaceInterval = _surfaceIntervalController.text, visibility = _visibilityController.text, surfTemp = _surfTempController.text, waterTemp = _waterTempController.text, avgDepth = _avgDepthController.text, maxDepth = _maxDepthController.text, notes = _notesController.text, weight = _weightController.text, suitThickness = _suitThicknessController.text;
              String selectedSuitType = _isSkin ? 'Skin' : _isWet ? 'Wet' : _isSemidry ? 'Semidry' : _isDry ? 'Dry' : log.suitType ?? '';
              String selectedWeather = '';
              for (int i = 0; i < _weatherSelected.length; i++) if (_weatherSelected[i]) { selectedWeather = _weatherOptions[i]; break; }
              selectedWeather = selectedWeather.isEmpty ? log.weather ?? '' : selectedWeather;

              DiveLog updatedLog = DiveLog(
                logNo: _logNoController.text,
                date: _dateController.text,
                location: location.isEmpty ? log.location : location,
                point: point.isEmpty ? log.point : point,
                diveShop: diveShop.isEmpty ? log.diveShop : diveShop,
                airIn: airIn.isEmpty ? log.airIn : airIn,
                airOut: airOut.isEmpty ? log.airOut : airOut,
                nitroxMix: nitroxMix.isEmpty ? log.nitroxMix : nitroxMix,
                timeIn: timeIn.isEmpty ? log.timeIn : timeIn,
                timeOut: timeOut.isEmpty ? log.timeOut : timeOut,
                surfaceInterval: surfaceInterval.isEmpty ? log.surfaceInterval : surfaceInterval,
                visibility: visibility.isEmpty ? log.visibility : visibility,
                surfTemp: surfTemp.isEmpty ? log.surfTemp : surfTemp,
                waterTemp: waterTemp.isEmpty ? log.waterTemp : waterTemp,
                avgDepth: avgDepth.isEmpty ? log.avgDepth : avgDepth,
                maxDepth: maxDepth.isEmpty ? log.maxDepth : maxDepth,
                suitThickness: suitThickness.isEmpty ? log.suitThickness : suitThickness,
                suitType: selectedSuitType.isEmpty ? log.suitType : selectedSuitType,
                weight: weight.isEmpty ? log.weight : weight,
                safetyStop: _safetyStop ? 'Yes' : 'No',
                equipment: _equipment.join(', '),
                weather: selectedWeather,
                notes: notes.isEmpty ? log.notes : notes,
                voiceMemo: _voiceMemo.isEmpty ? log.voiceMemo : _voiceMemo,
                purpose: _isFunDive ? 'Fun' : _isTrainingDive ? 'Training' : log.purpose,
                time: '',
              );

              DateTime originalDate = DateFormat('yyyy-MM-dd').parse(log.date ?? DateTime.now().toIso8601String().split('T')[0]);
              DateTime newDate = DateFormat('yyyy-MM-dd').parse(_dateController.text);

              onEdit(originalDate, newDate, index, updatedLog);
              Navigator.of(dialogContext).pop();
            },
            child: Text('Save', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    ),
  );
}