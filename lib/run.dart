
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
  String _timeStr = "00:00:00";
  String _distanceStr = "0.0km";
  String _speedStr = "0.0m/s";
  String _altStr = "0.0m";
  //　グラフデータ
  List<FlSpot> _altGraphList = [];
  List<FlSpot> _spdGraphList = [];
  //　最大最小値
  double _minAlt = 0, _maxAlt = 0;
  double _minSpd = 0, _maxSpd = 0;
  //グラフメモリー用の値をキリの良い値にする
  double convGraphValue(double value, bool upFlg, int scale ) {
    int digit = (value / scale).toInt();
    if (upFlg == true) {
      return ((digit + 1) * scale).toDouble();
    } else {
      return (digit * scale).toDouble();
    }
  }
        
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
        //実態がある場合のみ、画面を更新する
        if (mounted == true && Gps.logSartFlg)
        {
          if (Gps.getCoordinateCount() <0  ) {
            return;
          }
          //final pos = Gps.currentPos ;
          final oneCod = Gps.currentCoordinate;
          _lat = oneCod.latitude;
          _lon = oneCod.longitude;
           // 速度のmin/max取得
           _minSpd  = convGraphValue(Gps.getSpeedMin(), false,2);
           _maxSpd  = convGraphValue(Gps.getSpeedMax(), true,2);   
           _spdGraphList = Gps.getGpsLogGraphData(0);         
          // 標高のmin/max取得
          _minAlt = convGraphValue(Gps.getAltMin(), false,5);
          _maxAlt = convGraphValue(Gps.getAltMax(), true,5);
          _altGraphList = Gps.getGpsLogGraphData(1);
          // 表示の更新　
          _timeStr = Gps.getGpsLogTime();
          _distanceStr = Gps.getGpsLogDistance();
          _speedStr = "${oneCod.dltSpeed.toStringAsFixed(1)}m/s";
          _altStr = "${oneCod.altitude.toStringAsFixed(1)}m";
          //
          if (_altGraphList.isNotEmpty && _spdGraphList.isNotEmpty) {
            setState(() {});  //buildメソッドを呼び出す
          }
        }
      },
    );
  }
  LineChartData get spdlineChartData => LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: _spdGraphList, //速度グラフ m/s
                    //isCurved: true,
                    color: Colors.blue,
                    dotData: const FlDotData(show: false), // 点を非表示にする
                  ),
                ],
                titlesData: FlTitlesData(
                  topTitles: AxisTitles(
                    axisNameWidget: Text(
                      "速度("+_speedStr+")",
                    ),
                    axisNameSize: 35.0,
                  ),
                  rightTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: true)),
                ),
                minY: _minSpd,
                maxY: _maxSpd,
  );
    LineChartData get altlineChartData => LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: _altGraphList, //速度グラフ m/s
                    //isCurved: true,
                    color: Colors.blue,
                    dotData: const FlDotData(show: false), // 点を非表示にする
                  ),
                ],
                titlesData: FlTitlesData(
                  topTitles: AxisTitles(
                    axisNameWidget: Text(
                      "標高("+_altStr+")"
                    ),
                    axisNameSize: 35.0,
                  ),
                  rightTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: true)),
                ),
                minY: _minAlt,
                maxY: _maxAlt,
  );
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
            child: Text(_timeStr),
          ),
          TextButton(
              style:  styl0,   
            onPressed: () => {print("Resultボタンが押されたよ")},
            child: Text(_distanceStr),
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
            width: screenWidth * 0.85,
            height: screenWidth * 0.95 * 0.4,
            child:LineChart( spdlineChartData
              ),
            ),
          SizedBox(
            width: screenWidth * 0.85,
            height: screenWidth * 0.95 * 0.4,
            child: LineChart( altlineChartData
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
