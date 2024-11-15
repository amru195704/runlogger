
import 'package:flutter/material.dart';
import 'model/gps.dart';
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
  // 表示様変数データ
  String _time = "00:00:00";
  String _distance = "0.0km";
  //
  List<FlSpot> _spdGraphList = [];
  List<FlSpot> _altGraphList = [];
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
        final pos = Gps.currentPos ;
        _lat = pos.latitude;
        _lon = pos.longitude;
        //実態がある場合のみ、画面を更新する
        if (mounted == true)
        {
          // 表示の更新　
          _time = Gps.getGpsLogTime();
          _distance = Gps.getGpsLogDistance();
          _spdGraphList = Gps.getGpsLogGraphData(0);
          _altGraphList = Gps.getGpsLogGraphData(1);
          //
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
            child: Text(_time),
          ),
          TextButton(
              style:  styl0,   
            onPressed: () => {print("Resultボタンが押されたよ")},
            child: Text(_distance),
          ),
          Row(
             mainAxisAlignment: MainAxisAlignment.spaceAround,
             children: [
                TextButton(
                  style: styl1,         
                  onPressed: () => {
                    print("Startタンが押されたよ"),
                    Gps.gpsLogStart(),
                  },
                  child: const Text("Start"),
                ),
                TextButton(
                  style: styl1,  
                  onPressed: () => {
                    print("Stopタンが押されたよ"),
                    Gps.gpsLogStop(),},
                  child: const Text("Stop"),
                ),
                TextButton(
                  style: styl1,  
                  onPressed: () => {print("RunTypeタンが押されたよ")},
                  child: const Text("RunType"),
                ),
             ]),
          SizedBox(
            width: screenWidth * 0.90,
            height: screenWidth * 0.95 * 0.4,
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: _spdGraphList, //速度グラフ m/s
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
                maxY: 10,
                minY: 0,
              ),
            ),
          ),
          SizedBox(
            width: screenWidth * 0.90,
            height: screenWidth * 0.95 * 0.4,
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots:_altGraphList,  //標高グラフ
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
                maxY: 10,
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
