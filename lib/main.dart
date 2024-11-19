import 'package:flutter/material.dart';
import 'map.dart';
import 'model/gps.dart';
import 'run.dart';

// info.plistに以下を追加
//	<key>MinimumOSVersion</key>
//	<string>14.5</string>
//    <!-- geolocator Section -->
//    <key>NSLocationWhenInUseUsageDescription</key>
//    <string>GPS座標をログの為に使用します</string>
//    <key>NSLocationAlwaysUsageDescription</key>
//    <string>GPS座標をログの為に使用します.</string>
//    <!-- End of the geolocator Section -->
//	<key>LSSupportsOpeningDocumentsInPlace</key>
//	<true/>
// [起動アイコン設定]
// % flutter pub run flutter_launcher_icons:main

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key}) {
    Gps.gpsStart();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            bottom: const TabBar(
              tabs: [
                Tab(icon: ImageIcon(AssetImage('assets/images/map-01.png'))),
                Tab(icon: ImageIcon(AssetImage('assets/images/run-01.png'))),
                Tab(icon: ImageIcon(AssetImage('assets/images/set-00.png'))),
              ],
            ),
            title: const Text('RunLogger Flutter Test'),
          ),
          body: const TabBarView(
            children: [
              MyMap(),
              MyRun(),
              Icon(Icons.directions_bike),
            ],
          ),
        ),
      ),
    );
  }
}
