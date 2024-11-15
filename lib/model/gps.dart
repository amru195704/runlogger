import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_2/model/gpsLogData.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';

// debug用座標リスト
List<(double,double)> debugPositions = [
                 ( 33.123649700,131.788723100 ),
                 ( 33.123634677,131.788726041 ),
                 ( 33.123754473,131.788709089 ),
                 ( 33.123827500,131.788634200 ),
                 ( 33.123835833,131.788597851 ),
                 ( 33.123898995,131.788711871 ),
                 ( 33.123852734,131.788755827 ),
                 ( 33.123925791,131.788866642 ),
                 ( 33.123983100,131.788942500 ),
                 ( 33.123997469,131.788936474 ),
                 ( 33.124059656,131.789045700 ),
                 ( 33.124044797,131.789038486 ),
                 ( 33.124128236,131.789095245 ),
                 ( 33.124101612,131.789237667 ),
                 ( 33.124199574,131.789274500 ),
                 ( 33.124260177,131.789343845 ),
                 ( 33.124263600,131.789403600 ),
                 ( 33.124296764,131.789432318 ),
                 ( 33.124265940,131.789491964 ),
                 ( 33.124200891,131.789486159 ),
                 ( 33.124113600,131.789614700 ),
                 ( 33.124115768,131.789611791 ),
                 ( 33.124030442,131.789634213 ),
                 ( 33.124052099,131.789743561 ),
                 ( 33.123965720,131.789813210 ),
                 ( 33.123986970,131.789876412 ),
                 ( 33.123906125,131.789908476 ),
                 ( 33.123816400,131.790036900 ),
                 ( 33.123796668,131.790022525 ),
                 ( 33.123803908,131.790081523 ),
                 ( 33.123748044,131.790167770 ),
                 ( 33.123685800,131.790217500 ),
                 ( 33.123716833,131.790223736 ),
                 ( 33.123607885,131.790246489 ),
                 ( 33.123591028,131.790315461 ),
                 ( 33.123489480,131.790361881 ),
                 ( 33.123444989,131.790345581 ),
                 ( 33.123389103,131.790421149 ),
                 ( 33.123340992,131.790501273 ),
                 ( 33.123299695,131.790542579 ),
                 ( 33.123213740,131.790513585 ),
                 ( 33.123116465,131.790611075 ),
                 ( 33.123050074,131.790638500 ),
                 ( 33.123009984,131.790720962 ),
                 ( 33.122969013,131.790755810 ),
                 ( 33.122932883,131.790767745 ),
                 ( 33.122829150,131.790821659 ),
                 ( 33.122816725,131.790896971 ),
                 ( 33.122672500,131.790936962 ),
                 ( 33.122623389,131.790920699 ),
                 ( 33.122570712,131.790934682 ),
                 ( 33.122502883,131.791007727 ),
                 ( 33.122444200,131.791084200 ),
                 ( 33.122399455,131.791064425 ),
                 ( 33.122505431,131.791116071 ),
                 ( 33.122505300,131.791225800 ),
                 ( 33.122545242,131.791198280 ),
                 ( 33.122574700,131.791292500 ),
                 ( 33.122619177,131.791336335 ),
                 ( 33.122595257,131.791383395 ),
                 ( 33.122685800,131.791436900 ),
                 ( 33.122691400,131.791448100 ),
                 ( 33.122662722,131.791484759 ),
                 ( 33.122724700,131.791539700 ),
                 ( 33.122713579,131.791585847 ),
                 ( 33.122737889,131.791588812 ),
                 ( 33.122799339,131.791685227 ),
                 ( 33.122844507,131.791760110 ),
                 ( 33.122866400,131.791809200 ),
                 ( 33.122904286,131.791775258 ),
                 ( 33.122878141,131.791857514 ),
                 ( 33.122938600,131.791948100 ),
                 ( 33.122965514,131.791970860 ),
                 ( 33.122954043,131.791974914 ),
                 ( 33.123026753,131.792060288 ),
                 ( 33.123019635,131.792147696 ),
                 ( 33.123060800,131.792278600 ),
                 ( 33.123018509,131.792317721 ),
                 ( 33.123113600,131.792381400 ),
                 ( 33.123118770,131.792414499 ),
                 ( 33.123203784,131.792399528 ),
                 ( 33.123184375,131.792529458 ),
                 ( 33.123247622,131.792507335 ),
                 ( 33.123321684,131.792632424 ),
                 ( 33.123347117,131.792664695 ),
                 ( 33.123451625,131.792712391 ),
                 ( 33.123444979,131.792730657 ),
                 ( 33.123532749,131.792846212 ),
                 ( 33.123606151,131.792856859 ),
                 ( 33.123591064,131.792948852 ),
                 ( 33.123708652,131.792942204 ),
                 ( 33.123710045,131.792991606 ),
                 ( 33.123787625,131.793125861 ),
                 ( 33.123860412,131.793178917 ),
                 ( 33.123830880,131.793168659 ),
                 ( 33.123894973,131.793209254 ),
                 ( 33.123992039,131.793308805 ),
                 ( 33.124008402,131.793328905 ),
                 ( 33.124038451,131.793425641 ),
                 ( 33.124117679,131.793475946 ),
                 ( 33.124224700,131.793573100 ),
                 ( 33.124178461,131.793547770 ),
                 ( 33.124271900,131.793473100 ),
                 ( 33.124269566,131.793471462 ),
                 ( 33.124330206,131.793417289 ),
                 ( 33.124325205,131.793327133 ),
                 ( 33.124350942,131.793275381 ),
                 ( 33.124415154,131.793189630 ),
                 ( 33.124443231,131.793204051 ),
                 ( 33.124498920,131.793129210 ),
                 ( 33.124604961,131.793025581 ),
                 ( 33.124605619,131.792975753 ),
                 ( 33.124676526,131.792965085 ),
                 ( 33.124675143,131.792861218 ),
                 ( 33.124747984,131.792751909 ),
                 ( 33.124810800,131.792675800 ),
];

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
  static Position get currentPos => _currentPos;
  static final _random = Random();
  //
  static Future<Position> getLocation() async {
    if (kDebugMode) {
      double lat, lon;
      (lat, lon) = debugPositions[_posNo];
      // 最終データチェック
      _posNo++;
      if (_posNo >= debugPositions.length) {
        _posNo = 0;
      }
      // 0.0から1.0未満のランダムな実数
      double randomDouble = _random.nextDouble()*10;
      // デバッグ用の位置情報を返す
      return Future.value(Position(
        latitude: lat,
        longitude: lon,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: randomDouble,
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
  static bool _gpsLogSartFlg = false;
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
        if (_gpsLogSartFlg == true) {
          // 位置情報を記録する
          Coordinate rtnCod = _coordinateTable.addCoordinate(Coordinate.alt(
            latitude: _currentPos.latitude,
            longitude: _currentPos.longitude,
            altitude: _currentPos.altitude,
          ));
          // run グラフデータ
          _altDatList.add(FlSpot(graphIdx, rtnCod.altitude));
          if (rtnCod.dltTime > 0.0)
          {
            double speed = rtnCod.dltDistance / rtnCod.dltTime; // m/s
            _spdDatList.add(FlSpot(graphIdx, speed));
          }
          else
          {
            _spdDatList.add(FlSpot(graphIdx, 0.0));
          }
          graphIdx += 1.0;
        }
      },
    );
  }
  static void gpsLogStart()
  {
    _gpsLogSartFlg = true;
    _coordinateTable.clearCoordinate();
    _altDatList.clear();
    _spdDatList.clear();
    graphIdx = 0.0;
    _gpsLogStartTime = DateTime.now();
  }
  //
  static void gpsLogStop()
  {
    _gpsLogSartFlg = false;
    // ログをファイルに書き込む
    //csvExport(_coordinateTable.coordinates, 'gpsLog.csv');
  }
  // 表示文字列取得
  // ログ系か時間の文字列を戻す
  static String getGpsLogTime()
  {
    if (_gpsLogSartFlg == true)
    {
      return DateTime.now().difference(_gpsLogStartTime).toString();
    }
    return "00:00:00";
  }
  // ログの移動距離文字列を戻す
  static String getGpsLogDistance()
  {
    if (_gpsLogSartFlg == true)
    {
      double distance = _coordinateTable.getDistance();
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