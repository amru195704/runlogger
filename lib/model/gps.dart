import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_2/model/debugData.dart';
import 'package:flutter_application_2/model/gpsLogData.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';

//パッケージの追加
// flutter pub add geolocator
//
/// デバイスの現在位置を決定する。
/// 位置情報サービスが有効でない場合、または許可されていない場合。
/// エラーを返します
Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // 位置情報サービスが有効かどうかをテストします。
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // 位置情報サービスが有効でない場合、続行できません。
    // 位置情報にアクセスし、ユーザーに対して 
    // 位置情報サービスを有効にするようアプリに要請する。
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    // ユーザーに位置情報を許可してもらうよう促す
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // 拒否された場合エラーを返す
      return Future.error('Location permissions are denied');
    }
  }
  
  // 永久に拒否されている場合のエラーを返す
  if (permission == LocationPermission.deniedForever) {
    return Future.error(
      'Location permissions are permanently denied, we cannot request permissions.');
  } 

  // ここまでたどり着くと、位置情報に対しての権限が許可されているということなので
  // デバイスの位置情報を返す。
  return await Geolocator.getCurrentPosition();
}

// モジュールグループを表すのに使用されるクラス
class Gps {
  // デバッグ用の位置情報を返す
  static int _posNo = 0;
  static late Position _currentPos;
  static late Coordinate _currentCoordinate;
  //
  static Position get currentPos => _currentPos;
  static Coordinate get currentCoordinate => _currentCoordinate;
  static final _random = Random();
  //
  static Future<Position> getLocation() async {
    if (kDebugMode) {
      double lat, lon, alt;
      (lat, lon, alt) = debug3Positions[_posNo];
      // 最終データチェック
      _posNo++;
      if (_posNo >= debug3Positions.length) {
        _posNo = 0;
      }
      // 標高を少し、変化するため＝0.0から1.0未満のランダムな実数
      double randomDouble = _random.nextDouble();
      // デバッグ用の位置情報を返す
      return Future.value(Position(
        latitude: lat,
        longitude: lon,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: alt+randomDouble,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      ));
    } else {
      return await Geolocator.getCurrentPosition();
    }
  }

  /// GPSの位置情報を取得して、gpsLogDataに格納する
  static bool _gpsStartFlg = false;
  static late DateTime _gpsStartTime ;
  // ログ開始フラグ
  static bool logSartFlg = false;
  static late DateTime _gpsLogStartTime ;
  // 座標保存テーブル
  static CoordinateTable _coordinateTable = CoordinateTable();
  //  run グラフデータ
  static List<FlSpot> _spdDatList = [];
  static List<FlSpot> _altDatList = [];
  // ログインデックス
  static double graphIdx = 0.0;
  //
  static void gpsStart() {
    _gpsStartFlg = true;
    _gpsStartTime = DateTime.now();
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
          _currentCoordinate = _coordinateTable.addCoordinate(Coordinate.alt(
            latitude: _currentPos.latitude,
            longitude: _currentPos.longitude,
            altitude: _currentPos.altitude,
          ));
          // run グラフデータ
          _altDatList.add(FlSpot(graphIdx, _currentCoordinate.altitude));
          _spdDatList.add(FlSpot(graphIdx, _currentCoordinate.dltSpeed));
          graphIdx += 1.0;
        }
      },
    );
  }
  // minPos/maxPosの取得
  static Coordinate getMinPos() {
    return _coordinateTable.minPos;
  }
  static Coordinate getMaxPos() {
    return _coordinateTable.maxPos;
  }
  // (標高のmin.max)を取得
  static double getAltMin() {
    return (_coordinateTable.minPos.altitude);
  }
  static double getAltMax() {
    return (_coordinateTable.maxPos.altitude);
  }
  // (速度のmin.max)を取得
  static double getSpeedMin() {
    return (_coordinateTable.minPos.dltSpeed);
  }
  static double getSpeedMax() {
    return (_coordinateTable.maxPos.dltSpeed);
  }
 
  // ログ開始
  static void gpsLogStart()
  {
    logSartFlg = true;
    _coordinateTable.clearCoordinate();
    _altDatList.clear();
    _spdDatList.clear();
    _altDatList.add(FlSpot(0,0));
     _spdDatList.add(FlSpot(0,0));
    graphIdx = 0.0;
    _gpsLogStartTime = DateTime.now();
  }
  //
  static void gpsLogStop()
  {
    logSartFlg = false;
    // ログをファイルに書き込む
    //csvExport(_coordinateTable.coordinates, 'gpsLog.csv');
  }
  // 表示文字列取得
  // ログ系か時間の文字列を戻す
  static String getGpsLogTime()
  {
    if (logSartFlg == true)
    {
      return DateTime.now().difference(_gpsLogStartTime).toString();
    }
    return "00:00:00";
  }
  // ログの移動距離文字列を戻す
  static String getGpsLogDistance()
  {
    if (logSartFlg == true)
    {
      double distance = _coordinateTable.totalDistance;
      if (distance > 1000.0)
      {
        return (distance / 1000.0).toStringAsFixed(1) + "km";
      }
      return distance.toStringAsFixed(1) + "m";
    }
    return "0.0km";
  }
  // ロググラフデータを戻す
  static List<FlSpot> getGpsLogGraphData(int idx)
  {
    if (idx == 0)
    {
      return _spdDatList;
    }
    return _altDatList;
  }
}