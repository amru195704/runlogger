
import 'dart:convert';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// <summary>
/// CSV file 読み込み
/// </summary>
Future<List<List>> csvImport(String importPath) async {
  final File importFile = File(importPath);
  List<List> importList = [];

  Stream fread = importFile.openRead();

  // Read lines one by one, and split each ','
  await fread.transform(utf8.decoder).transform(LineSplitter()).listen(
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

  final File exportFile = File(exportPath);
  IOSink iosink = exportFile.openWrite();

  for (List line in exportList) {
    iosink.writeAll(line, ',');
    iosink.write('\n');
  }

  await iosink.close();
}

// Providerの例
class CoordinateTable {
  List<Coordinate> _coordinates = [];

  List<Coordinate> get coordinates => _coordinates;

  // データの全部追加
  set coordinates(List<Coordinate> value) {
    _coordinates = value;
  }
  // １座標データの追加
  void addCoordinate(Coordinate coordinate) {
    _coordinates.add(coordinate);
  }
  // データの削除
  void removeCoordinate(int index) {
    _coordinates.removeAt(index);
  }
  // データのクリア
  void clearCoordinate() {
    _coordinates.clear();
  }
}

class Coordinate {
  double latitude;
  double longitude;
  late double altitude;
  late DateTime timestamp;

  //
  Coordinate({required this.latitude, required this.longitude, required this.altitude, required this.timestamp});
  Coordinate.alt({required this.latitude, required this.longitude, required this.altitude}) {
    altitude = 0;
    timestamp = DateTime.now();
  }
  Coordinate.now({required this.latitude, required this.longitude, required this.altitude}) {
    timestamp = DateTime.now();
  }

}