class DiveLog {
  String? logNo;
  String? date;
  String? location;
  String? point;
  String? diveShop;
  String? airIn;
  String? airOut;
  String? nitroxMix;
  String? timeIn;
  String? timeOut;
  String? surfaceInterval;
  String? visibility;
  String? surfTemp;
  String? waterTemp;
  String? avgDepth;
  String? maxDepth;
  String? suitThickness;
  String? suitType;
  String? weight;
  String? safetyStop;
  String? equipment;
  String? weather;
  String? notes;
  String? voiceMemo;
  String? purpose;
  String? time;

  DiveLog({
    this.logNo,
    this.date,
    this.location,
    this.point,
    this.diveShop,
    this.airIn,
    this.airOut,
    this.nitroxMix,
    this.timeIn,
    this.timeOut,
    this.surfaceInterval,
    this.visibility,
    this.surfTemp,
    this.waterTemp,
    this.avgDepth,
    this.maxDepth,
    this.suitThickness,
    this.suitType,
    this.weight,
    this.safetyStop,
    this.equipment,
    this.weather,
    this.notes,
    this.voiceMemo,
    this.purpose,
    this.time,
  });

  Map<String, String> toMap() {
    return {
      'logNo': logNo ?? '',
      'date': date ?? '',
      'location': location ?? '',
      'point': point ?? '',
      'diveShop': diveShop ?? '',
      'airIn': airIn ?? '',
      'airOut': airOut ?? '',
      'nitroxMix': nitroxMix ?? '',
      'timeIn': timeIn ?? '',
      'timeOut': timeOut ?? '',
      'surfaceInterval': surfaceInterval ?? '',
      'visibility': visibility ?? '',
      'surfTemp': surfTemp ?? '',
      'waterTemp': waterTemp ?? '',
      'avgDepth': avgDepth ?? '',
      'maxDepth': maxDepth ?? '',
      'suitThickness': suitThickness ?? '',
      'suitType': suitType ?? '',
      'weight': weight ?? '',
      'safetyStop': safetyStop ?? '',
      'equipment': equipment ?? '',
      'weather': weather ?? '',
      'notes': notes ?? '',
      'voiceMemo': voiceMemo ?? '',
      'purpose': purpose ?? '',
      'time': time ?? '',
    };
  }

  factory DiveLog.fromMap(Map<String, String> map) {
    return DiveLog(
      logNo: map['logNo'],
      date: map['date'],
      location: map['location'],
      point: map['point'],
      diveShop: map['diveShop'],
      airIn: map['airIn'],
      airOut: map['airOut'],
      nitroxMix: map['nitroxMix'],
      timeIn: map['timeIn'],
      timeOut: map['timeOut'],
      surfaceInterval: map['surfaceInterval'],
      visibility: map['visibility'],
      surfTemp: map['surfTemp'],
      waterTemp: map['waterTemp'],
      avgDepth: map['avgDepth'],
      maxDepth: map['maxDepth'],
      suitThickness: map['suitThickness'],
      suitType: map['suitType'],
      weight: map['weight'],
      safetyStop: map['safetyStop'],
      equipment: map['equipment'],
      weather: map['weather'],
      notes: map['notes'],
      voiceMemo: map['voiceMemo'],
      purpose: map['purpose'],
      time: map['time'],
    );
  }
}