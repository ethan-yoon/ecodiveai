import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../models/dive_log.dart';
import 'speech_input_dialog.dart';
import 'wave_painter.dart';

Future<void> showAddLogDialog(
  BuildContext context,
  DateTime selectedDay,
  Function(DateTime, DiveLog) onAdd,
) async {
  final stt.SpeechToText _speech = stt.SpeechToText();
  TextEditingController _logNoController = TextEditingController();
  TextEditingController _dateController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(selectedDay));
  TextEditingController _locationController = TextEditingController();
  TextEditingController _pointController = TextEditingController();
  TextEditingController _diveShopController = TextEditingController();
  TextEditingController _airInController = TextEditingController();
  TextEditingController _airOutController = TextEditingController();
  TextEditingController _nitroxMixController = TextEditingController(text: '21');
  TextEditingController _timeInController = TextEditingController();
  TextEditingController _timeOutController = TextEditingController();
  TextEditingController _surfaceIntervalController = TextEditingController();
  TextEditingController _visibilityController = TextEditingController();
  TextEditingController _surfTempController = TextEditingController();
  TextEditingController _waterTempController = TextEditingController();
  TextEditingController _avgDepthController = TextEditingController();
  TextEditingController _maxDepthController = TextEditingController();
  TextEditingController _notesController = TextEditingController();
  TextEditingController _weightController = TextEditingController();
  TextEditingController _suitThicknessController = TextEditingController();
  String _voiceMemo = '';
  bool _isSkin = false, _isWet = false, _isSemidry = false, _isDry = false, _safetyStop = false, _isFunDive = false, _isTrainingDive = false, _is24HourFormat = true;
  List<String> _weatherOptions = ['Sunny', 'PartlyCloudy', 'Cloudy', 'Rainy'];
  List<bool> _weatherSelected = [false, false, false, false];
  List<String> _equipment = [];
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
        title: Text('Add Dive Log', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
                              final DateTime? picked = await showDatePicker(context: dialogContext, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
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
                                initialTime: TimeOfDay.now(),
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
                                initialTime: TimeOfDay.now(),
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
                await _showWarningDialog(context, 'Nitrox Mix must be between 21% and 100%. Please correct the value.', onOk: () => setDialogState(() => _nitroxMixController.text = '21'));
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
                  await _showWarningDialog(context, 'Time Out must be later than Time In.', onOk: () => setDialogState(() => _timeOutController.text = ''));
                  return;
                }
                timeIn = '${timeInHour.toString().padLeft(2, '0')}:${timeInMinute.toString().padLeft(2, '0')}';
                timeOut = '${timeOutHour.toString().padLeft(2, '0')}:${timeOutMinute.toString().padLeft(2, '0')}';
              }
              String location = _locationController.text, point = _pointController.text, diveShop = _diveShopController.text, airIn = _airInController.text, airOut = _airOutController.text, surfaceInterval = _surfaceIntervalController.text, visibility = _visibilityController.text, surfTemp = _surfTempController.text, waterTemp = _waterTempController.text, avgDepth = _avgDepthController.text, maxDepth = _maxDepthController.text, notes = _notesController.text, weight = _weightController.text, suitThickness = _suitThicknessController.text;
              String selectedSuitType = _isSkin ? 'Skin' : _isWet ? 'Wet' : _isSemidry ? 'Semidry' : _isDry ? 'Dry' : '';
              String selectedWeather = '';
              for (int i = 0; i < _weatherSelected.length; i++) if (_weatherSelected[i]) { selectedWeather = _weatherOptions[i]; break; }
              if (location.isNotEmpty || point.isNotEmpty || diveShop.isNotEmpty) {
                DiveLog newLog = DiveLog(
                  logNo: _logNoController.text,
                  date: _dateController.text,
                  location: location,
                  point: point,
                  diveShop: diveShop,
                  airIn: airIn,
                  airOut: airOut,
                  nitroxMix: nitroxMix,
                  timeIn: timeIn,
                  timeOut: timeOut,
                  surfaceInterval: surfaceInterval,
                  visibility: visibility,
                  surfTemp: surfTemp,
                  waterTemp: waterTemp,
                  avgDepth: avgDepth,
                  maxDepth: maxDepth,
                  suitThickness: suitThickness,
                  suitType: selectedSuitType,
                  weight: weight,
                  safetyStop: _safetyStop ? 'Yes' : 'No',
                  equipment: _equipment.join(', '),
                  weather: selectedWeather,
                  notes: notes,
                  voiceMemo: _voiceMemo,
                  purpose: _isFunDive ? 'Fun' : _isTrainingDive ? 'Training' : '',
                  time: '',
                );
                DateTime parsedDate = DateFormat('yyyy-MM-dd').parse(_dateController.text);
                onAdd(parsedDate, newLog);
              }
              Navigator.of(dialogContext).pop();
            },
            child: Text('Save', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    ),
  );
}