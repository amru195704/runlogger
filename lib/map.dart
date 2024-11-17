
import 'package:flutter/material.dart';
import 'model/gps.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';
import 'dart:async';

// info.plistに以下を追加
// 	<key>MinimumOSVersion</key>
//	<string>14.5</string>

// 位置情報の初期値
  double _zoom = 20;
  double _lat = 35.7052;
  double _lon = 139.572;

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

class MyMapPage extends StatefulWidget {
  const MyMapPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyMapPageState createState() => _MyMapPageState();
}

class _MyMapPageState extends State<MyMapPage> {

  // 地図の種類
  MapType _currentMapType = MapType.normal;
  // マーカーのリスト
  Map<int,Marker> _markTerable = {};
  int _markerNo = 0;
  //

  late PlatformMapController _controller;
  //
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
        final pos = Gps.currentPos;
        _lat = pos.latitude;
        _lon = pos.longitude;
        Marker mak = Marker(
          markerId: MarkerId('${_markerNo}'),
          position: LatLng(_lat, _lon), //
          infoWindow: InfoWindow(title: '${_markerNo}'),
          icon: BitmapDescriptor.defaultMarker, 
          );
        _markTerable[_markerNo] = mak;
        _markerNo++;
        if (_markerNo >= 20) {
          _markerNo = 0;
        }
        //実態がある場合のみ、画面を更新する
        if (mounted == true)
        {
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

  void _incrementCounter() {
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
  void _decrementCounter() {
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
    return Scaffold(
      body:  
            PlatformMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(_lat, _lon ),
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
                          target: LatLng(_lat, _lon ),
                          tilt: 30.0,
                          zoom: _zoom,
                        ),
                      ),
                    );
                    controller
                        .getVisibleRegion()
                        // ignore: avoid_print
                        .then((bounds) => print("bounds: ${bounds.toString()}" ));
                  },
                );
              }
            )
      ,      
      floatingActionButton:  Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            FloatingActionButton(
              onPressed: _changeMap,
              tooltip: 'ChangeMap',
              child: const Icon(Icons.layers),
            ),
            FloatingActionButton(
              onPressed: _incrementCounter,
              tooltip: 'Increment',
              child: const Icon(Icons.add),
            ),
            FloatingActionButton(
              onPressed: _decrementCounter,
              tooltip: 'Decrement',
              child: const Icon(Icons.remove),
            ),
          ],
        ),
      );
  }
}
