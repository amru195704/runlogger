import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_2/model/debugData.dart';
import 'package:flutter_application_2/model/gpsLogData.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';
import 'package:intl/intl.dart';

//パッケージの追加
// flutter pub add geolocator
//

/// <summary>
/// 差分時間を文字列に変換する。
/// hh:mm:ss.ssss形式
/// </summary>
String duration2String(Duration duration) {
  var microseconds = duration.inMicroseconds;
  var sign = "";
  var negative = microseconds < 0;

  var hours = microseconds ~/ Duration.microsecondsPerHour;
  microseconds = microseconds.remainder(Duration.microsecondsPerHour);
  if (negative) {
    hours = 0 - hours; // Not using `-hours` to avoid creating -0.0 on web.
    microseconds = 0 - microseconds;
    sign = "-";
  }
  var minutes = microseconds ~/ Duration.microsecondsPerMinute;
  microseconds = microseconds.remainder(Duration.microsecondsPerMinute);

  var minutesPadding = minutes < 10 ? "0" : "";

  var seconds = microseconds ~/ Duration.microsecondsPerSecond;
  microseconds = microseconds.remainder(Duration.microsecondsPerSecond);

  var secondsPadding = seconds < 10 ? "0" : "";

  // Padding up to six digits for microseconds.
  var s2sec = microseconds / 10000;
  var s2secText = s2sec.toString().padLeft(2, "0");

  return "$sign$hours:"
      "$minutesPadding$minutes:"
      "$secondsPadding$seconds."
      "$s2secText";
}

// モジュールグループを表すのに使用されるクラス
/// <summary>
/// GPSの位置情報を取得するクラス.
/// 別々な関数や値をまとめるためのクラスで、staticで全てアクセスします。
/// </summary>
class Gps {
  // （内部）デバッグ用の位置情報を返す
  static int _posNo = 0;
  static late Position _currentPos;
  static Coordinate _currentCoordinate = Coordinate.alt(
    latitude: 0,
    longitude: 0,
    altitude: 0,
  );
  // 外部からのアクセス用現在座標（Position形式）
  static Position get currentPos => _currentPos;
  // 外部からのアクセス用現在座標（Coordinate形式）
  static Coordinate get currentCoordinate => _currentCoordinate;
  // (内部でバック用）ランダムな値を生成するためのクラス
  static final _random = Random();
  //　位置情報を取得する関数 (currentPos/currentCoordinateは、２次的な値です）
  static Future<Position> getLocation() async {
    // デバッグモードの場合、デバッグ用の位置情報を返す
    if (kDebugMode) {
      double lat, lon, alt;
      (lat, lon, alt) = debugMitakaPositions[_posNo];
      // 最終データチェック
      _posNo++;
      if (_posNo >= debugMitakaPositions.length) {
        _posNo = 0;
      }
      // 標高を少し、変化するため＝0.0から1.0未満のランダムな実数
      double randomDouble = _random.nextDouble() * 2.0;
      // デバッグ用の位置情報を返す
      return Future.value(Position(
        latitude: lat,
        longitude: lon,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: alt + randomDouble,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      ));
    } else {
      // 本番モードの場合、実際の位置情報を返す
      return await Geolocator.getCurrentPosition();
    }
  }

  // ログ開始フラグと開始時間
  static bool logSartFlg = false;
  static late DateTime _gpsLogStartTime;
  // ログ座標保存テーブル
  static final CoordinateTable _logCoordinateTable = CoordinateTable();
  //  run グラフデータ
  static final List<FlSpot> _spdDatList = [];
  static final List<FlSpot> _altDatList = [];
  // ロググラフXインデックス
  static double graphIdx = 0.0;
  //　GPS計測開始
  static void gpsStart() {
    // 1. Timer.periodic : 新しい繰り返しタイマーを作成します
    // 1秒ごとに _counterを1ずつ足していく
    Timer.periodic(
      // 第一引数：繰り返す間隔の時間を設定
      const Duration(seconds: 1),
      // 第二引数：その間隔ごとに動作させたい処理を書く
      (Timer timer) async {
        _currentPos = await getLocation();
        if (logSartFlg == true) {
          // 位置情報を記録する
          _currentCoordinate = _logCoordinateTable.addCoordinate(Coordinate.alt(
            latitude: _currentPos.latitude,
            longitude: _currentPos.longitude,
            altitude: _currentPos.altitude,
          ));
          // run グラフデータ
          if (graphIdx > 0.0) {
            _altDatList.add(FlSpot(graphIdx, _currentCoordinate.altitude));
            _spdDatList.add(FlSpot(graphIdx, _currentCoordinate.dltSpeed));
          }
          graphIdx += 1.0;
        }
      },
    );
  }

  // 保存座標数を戻す
  static int getCoordinateCount() {
    return _logCoordinateTable.coordinates.length;
  }

  // minPos/maxPosの取得
  static Coordinate getMinPos() {
    return _logCoordinateTable.minPos;
  }

  static Coordinate getMaxPos() {
    return _logCoordinateTable.maxPos;
  }

  // (標高のmin.max)を取得
  static double getAltMin() {
    return (_logCoordinateTable.minPos.altitude);
  }

  static double getAltMax() {
    return (_logCoordinateTable.maxPos.altitude);
  }

  // (速度のmin.max)を取得
  static double getSpeedMin() {
    return (_logCoordinateTable.minPos.dltSpeed);
  }

  static double getSpeedMax() {
    return (_logCoordinateTable.maxPos.dltSpeed);
  }

  // ログ開始：_logCoordinateTableに座標を追加開始する
  static void gpsLogStart() {
    logSartFlg = true;
    _logCoordinateTable.clearCoordinate();
    _altDatList.clear();
    _spdDatList.clear();
    graphIdx = 0.0;
    _gpsLogStartTime = DateTime.now();
  }

  //　ログ終了：_logCoordinateTableに座標を追加終了する
  static void gpsLogStop() {
    logSartFlg = false;
    // ログをファイルに書き込む
    _logCoordinateTable.saveCsv();
  }

  // 表示文字列取得
  // ログ系か時間の文字列を戻す
  static String getGpsLogTime() {
    if (logSartFlg == true) {
      // 差分時間を計算（Duration型）
      Duration difference = DateTime.now().difference(_gpsLogStartTime);
      return duration2String(difference); // HH:MM:SS形式   ;
    }
    return "00:00:00";
  }

  // ログの移動距離文字列を戻す
  static String getGpsLogDistance() {
    if (logSartFlg == true) {
      double distance = _logCoordinateTable.totalDistance;
      if (distance > 1000.0) {
        return "${(distance / 1000.0).toStringAsFixed(2)}km";
      }
      return "${distance.toStringAsFixed(2)}m";
    }
    return "0.0km";
  }

  // ロググラフデータを戻す
  static List<FlSpot> getGpsLogGraphData(
      int graphNo, double minD, double maxD, double xMaxDefault) {
    if (logSartFlg == false) {
      return [];
    }
    if (_spdDatList.length < xMaxDefault) {
      if (graphNo == 0) {
        return _spdDatList;
      }
      return _altDatList;
    }
    // データ取得範囲計算
    int minIdx = minD.toInt();
    int maxIdx = maxD.toInt();
    if (maxIdx >= _logCoordinateTable.coordinates.length) {
      maxIdx = _logCoordinateTable.coordinates.length - 1;
    }
    if (graphNo == 0) {
      return _spdDatList.sublist(minIdx, maxIdx);
    }
    return _altDatList.sublist(minIdx, maxIdx);
  }
}
