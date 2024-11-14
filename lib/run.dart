
import 'package:flutter/material.dart';
import 'model/gps.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';
import 'dart:async';
import 'package:fl_chart/fl_chart.dart';

// info.plistに以下を追加
// 	<key>MinimumOSVersion</key>
//	<string>14.5</string>
//

class MyRun extends StatelessWidget {
  const MyRun({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyRunPage(),
    );
  }
}

class MyRunPage extends StatefulWidget {
  const MyRunPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyRunPageState createState() => _MyRunPageState();
}

class _MyRunPageState extends State<MyRunPage> {
  // 位置情報の初期値
  double _lat = 33.12;
  double _lon = 131.789;
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
        final pos = await getLocation() ;
        _lat = pos.latitude;
        _lon = pos.longitude;
        //実態がある場合のみ、画面を更新する
        if (mounted == true)
        {
          setState(() {
          });
        }
      },
    );
  }
  //  
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double btnSize = screenWidth * 0.95;
    double btnHight = screenWidth * 0.1;
    final styl0 = TextButton.styleFrom(
      fixedSize: Size(btnSize,btnHight),// 幅,高さ
      foregroundColor: Colors.white,
      backgroundColor: Colors.black,
    );
    final styl1 = TextButton.styleFrom(
      fixedSize: Size(btnSize/4,btnHight),// 幅,高さ
      foregroundColor: Colors.white,
      backgroundColor: Colors.black,
    );
    final styl2 = TextButton.styleFrom(
      fixedSize: Size(btnSize/7,btnHight),// 幅,高さ
      foregroundColor: Colors.white,
      backgroundColor: Colors.black,
    );
    return Scaffold(
     body: Column(children: [
          TextButton(
              style: styl0,
            onPressed: () => {print("Timeボタンが押されたよ")},
            child: const Text("00:00:00"),
          ),
          TextButton(
              style:  styl0,   
            onPressed: () => {print("Resultボタンが押されたよ")},
            child: const Text("0.0km"),
          ),
          Row(
             mainAxisAlignment: MainAxisAlignment.spaceAround,
             children: [
                TextButton(
                  style: styl1,         
                  onPressed: () => {print("Startボタンが押されたよ")},
                  child: const Text("Start"),
                ),
                TextButton(
                  style: styl1,  
                  onPressed: () => {print("Stopタンが押されたよ")},
                  child: const Text("Stop"),
                ),
                TextButton(
                  style: styl1,  
                  onPressed: () => {print("RunTypeタンが押されたよ")},
                  child: const Text("RunType"),
                ),
             ]),
          SizedBox(
            width: screenWidth * 0.95,
            height: screenWidth * 0.95 * 0.4,
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(1, 0),
                      FlSpot(2, 400),
                      FlSpot(3, 650),
                      FlSpot(4, 800),
                      FlSpot(5, 870),
                      FlSpot(6, 920),
                      FlSpot(7, 960),
                      FlSpot(8, 980),
                      FlSpot(9, 990),
                      FlSpot(10, 995),
                    ],
                    isCurved: true,
                    color: Colors.blue,
                  ),
                ],
                titlesData: const FlTitlesData(
                  topTitles: AxisTitles(
                    axisNameWidget: Text(
                      "速度",
                    ),
                    axisNameSize: 35.0,
                  ),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                maxY: 1000,
                minY: 0,
              ),
            ),
          ),
          SizedBox(
            width: screenWidth * 0.95,
            height: screenWidth * 0.95 * 0.4,
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(1, 0),
                      FlSpot(2, 400),
                      FlSpot(3, 650),
                      FlSpot(4, 800),
                      FlSpot(5, 870),
                      FlSpot(6, 920),
                      FlSpot(7, 960),
                      FlSpot(8, 980),
                      FlSpot(9, 990),
                      FlSpot(10, 995),
                    ],
                    isCurved: true,
                    color: Colors.blue,
                  ),
                ],
                titlesData: const FlTitlesData(
                  topTitles: AxisTitles(
                    axisNameWidget: Text(
                      "標高",
                    ),
                    axisNameSize: 35.0,
                  ),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                maxY: 1000,
                minY: 0,
              ),
            ),
          ),
          Row(
             mainAxisAlignment: MainAxisAlignment.spaceAround,
             children: [
                TextButton(
                  style: styl2,    
                  onPressed: () => {print("<<が押されたよ")},
                  child: const Text("<<"),
                ),
                TextButton(
                  style:  styl2,   
                  onPressed: () => {print("<が押されたよ")},
                  child: const Text("<"),
                ),
                TextButton(
                  style:  styl2,   
                  onPressed: () => {print("allが押されたよ")},
                  child: const Text("al"),
                ),
                TextButton(
                  style:  styl2,  
                  onPressed: () => {print(">が押されたよ")},
                  child: const Text(">"),
                ),
                TextButton(
                  style:  styl2,  
                  onPressed: () => {print(">>が押されたよ")},
                  child: const Text(">>"),
                ),
             ]),
    ]),

    );
  }
}
