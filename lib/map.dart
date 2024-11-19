import 'package:flutter/material.dart';
import 'model/gps.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';
import 'dart:async';

// info.plistに以下を追加
// 	<key>MinimumOSVersion</key>
//	<string>14.5</string>

class MyMap extends StatelessWidget {
  const MyMap({super.key});

  //const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyMapPage(),
    );
  }
}

// 実際のMAP画面定義
class MyMapPage extends StatefulWidget {
  const MyMapPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyMapPageState createState() => _MyMapPageState();
}

class _MyMapPageState extends State<MyMapPage> {
// 位置情報の初期値
  double _zoom = 20;
  double _lat = 35.7052;
  double _lon = 139.572;
  // 地図の種類
  MapType _currentMapType = MapType.normal;
  // マーカーのリスト
  final Map<int, Marker> _markTerable = {};
  int _markerNo = 0;
  //
  late double btnWidth1;
  late double btnHight1;
  // 表示様変数データ
  String _timeStr = "00:00:00";
  String _distanceStr = "0.0km";
  // 地図コントローラ
  late PlatformMapController _controller;
  //
  // 初期化処理
  @override
  void initState() {
    super.initState();
    // 1. Timer.periodic : 新しい繰り返しタイマーを作成します
    // 1秒ごとに _counterを1ずつ足していく
    Timer.periodic(
      // 第一引数：繰り返す間隔の時間を設定
      const Duration(seconds: 1),
      // 第二引数：その間隔ごとに動作させたい処理を書く
      (Timer timer) async {
        // 位置情報を記録する
        final pos = Gps.currentPos;
        _lat = pos.latitude;
        _lon = pos.longitude;
        // マーカーを追加する
        Marker mak = Marker(
          markerId: MarkerId('$_markerNo'),
          position: LatLng(_lat, _lon), //
          infoWindow: InfoWindow(title: '$_markerNo'),
          icon: BitmapDescriptor.defaultMarker,
        );
        _markTerable[_markerNo] = mak;
        _markerNo++;
        if (_markerNo >= 20) {
          _markerNo = 0;
        }

        //実態がある場合のみ、画面を更新する
        if (mounted == true) {
          // 表示文字の更新
          _timeStr = Gps.getGpsLogTime();
          _distanceStr = Gps.getGpsLogDistance();
          // 画面を更新する
          setState(() {
            _controller.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: LatLng(_lat, _lon),
                  zoom: _zoom,
                ),
              ),
            );
          });
        }
      },
    );
  }
  //

  void _changeMap() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  void zoomIn() {
    setState(() {
      _zoom += 1.0;
      _controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(_lat, _lon),
            zoom: _zoom,
          ),
        ),
      );
    });
  }

  void zoomOut() {
    setState(() {
      _zoom -= 1.0;
      _controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(_lat, _lon),
            zoom: _zoom,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double btnSize = screenWidth * 0.95;
    btnWidth1 = btnSize / 3.2;
    btnHight1 = btnSize * 0.1;

    return Scaffold(
        body: Stack(children: [
      PlatformMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(_lat, _lon),
            zoom: _zoom,
          ),
          markers: _markTerable.values.toSet(),
          //mapType: MapType.satellite,
          mapType: _currentMapType,
          // ignore: avoid_print
          onTap: (location) => print('onTap: $location'),
          // ignore: avoid_print
          onMapCreated: (PlatformMapController controller) {
            _controller = controller;
            //compassEnabled: true,
            //onMapCreated: (controller) {
            Future.delayed(const Duration(seconds: 2)).then(
              (_) {
                controller.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: LatLng(_lat, _lon),
                      tilt: 30.0,
                      zoom: _zoom,
                    ),
                  ),
                );
                controller
                    .getVisibleRegion()
                    // ignore: avoid_print
                    .then((bounds) => print("bounds: ${bounds.toString()}"));
              },
            );
          }),
      Positioned(
        bottom: 20, // 下から20ピクセルの位置
        right: 20, // 右から20ピクセルの位置
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            FloatingActionButton(
              onPressed: _changeMap,
              tooltip: '地図変更',
              child: const Icon(Icons.layers),
            ),
            FloatingActionButton(
              onPressed: zoomIn,
              tooltip: '拡大',
              child: const Icon(Icons.add),
            ),
            FloatingActionButton(
              onPressed: zoomOut,
              tooltip: '縮小',
              child: const Icon(Icons.remove),
            ),
          ],
        ),
      ),
      Positioned(
        top: 10, // 上から10ピクセルの位置
        left: 10, // 肥大から20ピクセルの位置
        child: Column(children: [
          SizedBox(
            width: btnSize, // 希望の幅
            height: btnHight1,
            child: FloatingActionButton(
              onPressed: Gps.logSartFlg
                  ? null
                  : () => {
                        Gps.gpsLogStart(),
                      },
              backgroundColor: Gps.logSartFlg ? Colors.cyan : Colors.grey,
              child: Text("走行時間: $_timeStr"),
            ),
          ),
          const SizedBox(height: 10), // 10ピクセルのスペース
          SizedBox(
            width: btnSize, // 希望の幅
            height: btnHight1,
            child: FloatingActionButton(
              onPressed: Gps.logSartFlg
                  ? null
                  : () => {
                        Gps.gpsLogStart(),
                      },
              backgroundColor: Gps.logSartFlg ? Colors.cyan : Colors.grey,
              child: Text("走行距離: $_distanceStr"),
            ),
          ),
          const SizedBox(height: 10), // 10ピクセルのスペース
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              SizedBox(
                width: btnWidth1, // 希望の幅
                height: btnHight1,
                child: FloatingActionButton(
                  onPressed: Gps.logSartFlg
                      ? null
                      : () => {
                            Gps.gpsLogStart(),
                          },
                  backgroundColor: Gps.logSartFlg ? Colors.grey : Colors.blue,
                  child: const Text("Start"),
                ),
              ),
              SizedBox(
                width: btnWidth1, // 希望の幅
                height: btnHight1,
                child: FloatingActionButton(
                  onPressed: Gps.logSartFlg
                      ? () => {
                            Gps.gpsLogStop(),
                          }
                      : null,
                  backgroundColor: Gps.logSartFlg ? Colors.blue : Colors.grey,
                  child: const Text("Stop"),
                ),
              ),
              SizedBox(
                width: btnWidth1, // 希望の幅
                height: btnHight1,
                child: FloatingActionButton(
                  onPressed: () => {},
                  child: const Text("RunType"),
                ),
              ),
            ],
          ),
        ]),
      ),
    ]));
  }
}
