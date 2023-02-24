import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:sneakpeak_mapbox_poc/activity_map_dm.dart';

class ActivityMapHelper {
  String? _activityData;
  ActivityMapDm? activityMapDm;

  Future<void> loadJson() async {
    _activityData = await rootBundle.loadString('assets/activity_map.json');
  }

  Future<void> decode() async {
    if (_activityData != null) {
      activityMapDm = ActivityMapDm.fromJson(jsonDecode(_activityData!));
    }
  }
}
