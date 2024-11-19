import 'dart:convert';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

/// <summary>
/// ローカルファイルのパスを取得する
/// </summary>
Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

/// <summary>
/// CSV file 読み込み
/// </summary>
Future<List<List>> csvImport(String importPath) async {
  final File importFile = File(importPath);
  List<List> importList = [];
  Stream fread = importFile.openRead();

  // Read lines one by one, and split each ','
  await fread.transform(utf8.decoder).transform(const LineSplitter()).listen(
    (String line) {
      importList.add(line.split(','));
    },
  ).asFuture();

  return Future<List<List>>.value(importList);
}

/// <summary>
/// CSV file 書き込み
/// </summary>
/// <param name="List<List>">書き込みデータ</param>
/// <param name="String">書き込みファイル名</param>
/// <returns>Future<void></returns>
/// <example>
///  csvExport(importList, 'test.csv');
/// </example>
Future<void> csvExport(List<List> exportList, String exportPath) async {
  final path = await _localPath;
  final csvPath = '$path/$exportPath';

  final File exportFile = File(csvPath);
  print('exportPath: $csvPath');
  //
  IOSink iosink = exportFile.openWrite();
  for (List line in exportList) {
    iosink.writeAll(line, ',');
    iosink.write('\n');
  }

  await iosink.close();
}

// GPSデータのログ用保存クラス
class CoordinateTable {
  //内部データ
  List<Coordinate> _coordinates = [];
  //2点間の距離・時間計算用の１つ前の座標
  late Coordinate _oldCoordinate;
  //
  late Coordinate _minPos;
  late Coordinate _maxPos;
  // total距離
  late double _totalDistance;
  // データの取得用
  List<Coordinate> get coordinates => _coordinates;
  Coordinate get minPos => _minPos;
  Coordinate get maxPos => _maxPos;
  double get totalDistance => _totalDistance;
  // コンストラクタ
  CoordinateTable() {
    init();
  }
  //
  void init() {
    _coordinates = [];
    _totalDistance = 0;
    //
    _minPos = Coordinate.alt(latitude: 90, longitude: 90, altitude: 3000);
    _maxPos = Coordinate.alt(latitude: -90, longitude: -90, altitude: -3000);
  }

  // １座標データの追加
  Coordinate addCoordinate(Coordinate oneCod) {
    //2個目以上のデータの場合、前回の座標との距離・時間を計算
    if (_coordinates.isNotEmpty) {
      //時間計算
      oneCod.dltTime = oneCod.timestamp
              .difference(_oldCoordinate.timestamp)
              .inMilliseconds
              .toDouble() /
          1000;
      //print(
      //    'dltTime: ${oneCod.dltTime} ${_oldCoordinate.timestamp.toString()} ${oneCod.timestamp.toString()}');
      //距離計算
      oneCod.dltDistance = Geolocator.distanceBetween(
        _oldCoordinate.latitude,
        _oldCoordinate.longitude,
        oneCod.latitude,
        oneCod.longitude,
      );
      //速度計算
      if (oneCod.dltTime == 0) {
        oneCod.dltSpeed = 0;
      } else {
        oneCod.dltSpeed = oneCod.dltDistance / oneCod.dltTime;
        if (oneCod.dltSpeed.isNaN || oneCod.dltSpeed.isInfinite) {
          oneCod.dltSpeed = 0;
        } else if (oneCod.dltSpeed > 20) {
          // この最大２０はログタイプにより変更する
          oneCod.dltSpeed = 20;
        }
      }
      // total距離
      _totalDistance += oneCod.dltDistance;
    }
    // データの追加
    _coordinates.add(oneCod);
    // １つ前の座標を保存しておく
    _oldCoordinate = oneCod;
    // 最大・最小座標の更新
    // 緯度・経度
    _minPos.latitude = (_minPos.latitude > oneCod.latitude)
        ? oneCod.latitude
        : _minPos.latitude;
    _minPos.longitude = (_minPos.longitude > oneCod.longitude)
        ? oneCod.longitude
        : _minPos.longitude;
    _maxPos.latitude = (_maxPos.latitude < oneCod.latitude)
        ? oneCod.latitude
        : _maxPos.latitude;
    _maxPos.longitude = (_maxPos.longitude < oneCod.longitude)
        ? oneCod.longitude
        : _maxPos.longitude;
    // 標高
    _minPos.altitude = (_minPos.altitude > oneCod.altitude)
        ? oneCod.altitude
        : _minPos.altitude;
    _maxPos.altitude = (_maxPos.altitude < oneCod.altitude)
        ? oneCod.altitude
        : _maxPos.altitude;
    // start/end時間
    _minPos.timestamp = (_minPos.timestamp.isAfter(oneCod.timestamp))
        ? oneCod.timestamp
        : _minPos.timestamp;
    _maxPos.timestamp = (_maxPos.timestamp.isBefore(oneCod.timestamp))
        ? oneCod.timestamp
        : _maxPos.timestamp;
    // 2点間距離
    _minPos.dltDistance = (_minPos.dltDistance > oneCod.dltDistance)
        ? oneCod.dltDistance
        : _minPos.dltDistance;
    _maxPos.dltDistance = (_maxPos.dltDistance < oneCod.dltDistance)
        ? oneCod.dltDistance
        : _maxPos.dltDistance;
    // 2点間時間
    _minPos.dltTime =
        (_minPos.dltTime > oneCod.dltTime) ? oneCod.dltTime : _minPos.dltTime;
    _maxPos.dltTime =
        (_maxPos.dltTime < oneCod.dltTime) ? oneCod.dltTime : _maxPos.dltTime;
    // 2点間speed
    _minPos.dltSpeed = (_minPos.dltSpeed > oneCod.dltSpeed)
        ? oneCod.dltSpeed
        : _minPos.dltSpeed;
    _maxPos.dltSpeed = (_maxPos.dltSpeed < oneCod.dltSpeed)
        ? oneCod.dltSpeed
        : _maxPos.dltSpeed;
    //　追加した座標(dltDistance,dltTimeを追加した)を返す
    return oneCod;
  }

  // データの削除
  void removeCoordinate(int index) {
    _coordinates.removeAt(index);
  }

  // データのクリア
  void clearCoordinate() {
    _coordinates.clear();
    _totalDistance = 0;
  }

  // 距離計算
  double calcDistance() {
    if (_coordinates.length < 2) {
      print("*** ERROR *** calcDistance: no data");
      return 0.0;
    }
    _totalDistance = 0;
    for (int i = 0; i < _coordinates.length - 1; i++) {
      _totalDistance += _coordinates[i].dltDistance;
    }
    return _totalDistance;
  }

  // CSVファイルへの保存
  void saveCsv() {
    if (_coordinates.isEmpty) {
      print("*** ERROR *** saveCsv: no data");
      return;
    }
    // csv保存データ
    List<List> saveList = [];
    //
    var firstTime = _coordinates[0].timestamp;
    // フォーマットを作成
    DateFormat formatter = DateFormat('yyyy_MMdd_HHmmss');
    // フォーマットに基づいて文字列に変換
    String formattedDate = formatter.format(firstTime);
    String csvFileName = 'gpsLog_$formattedDate.csv';
    // ヘッダー
    saveList.add([
      'no',
      'timestamp',
      'latitude',
      'longitude',
      'altitude',
      'dltDistance',
      'dltTime',
      'dltSpeed'
    ]);
    // データ
    int no = 0;
    for (Coordinate oneCod in _coordinates) {
      saveList.add([
        no.toString(),
        oneCod.timestamp.toString(),
        oneCod.latitude.toString(),
        oneCod.longitude.toString(),
        oneCod.altitude.toString(),
        oneCod.dltDistance.toString(),
        oneCod.dltTime.toString(),
        oneCod.dltSpeed.toString(),
      ]);
      no++;
    }
    // ファイルへの保存
    csvExport(saveList, csvFileName);
  }
}

// ログ用GPSデータの座標クラス
class Coordinate {
  double latitude;
  double longitude;
  late double altitude;
  late DateTime timestamp;
  late double dltDistance;
  late double dltTime;
  late double dltSpeed;
  //　全指定：コンストラクタ（時間まで設定する）
  Coordinate(
      {required this.latitude,
      required this.longitude,
      required this.altitude,
      required this.timestamp}) {
    dltDistance = 0;
    dltTime = 0;
    dltSpeed = 0;
  }
  //　緯度経度高さ：コンストラクタ（時間以降を自動設定する）
  Coordinate.alt(
      {required this.latitude,
      required this.longitude,
      required this.altitude}) {
    timestamp = DateTime.now();
    dltDistance = 0;
    dltTime = 0;
    dltSpeed = 0;
  }
  //　緯度経度：コンストラクタ（高さ以降を自動設定する）
  Coordinate.now({required this.latitude, required this.longitude}) {
    altitude = 0;
    timestamp = DateTime.now();
    dltDistance = 0;
    dltTime = 0;
    dltSpeed = 0;
  }
}
