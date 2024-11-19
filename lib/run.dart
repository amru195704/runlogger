
import 'package:flutter/material.dart';
import 'model/gps.dart';
import 'dart:async';
import 'package:fl_chart/fl_chart.dart';

// info.plistに以下を追加
// 	<key>MinimumOSVersion</key>
//	<string>14.5</string>
//

/// <summary>
/// ランニングの種類を定義する。種類に応じて
/// 各種パラメータを設定する。（予定）
/// </summary>
enum RunType { run, bike, walk, other }
/// <summary>
/// グラフ描画方法を定義する。
/// firstは最初の２０データを表示。
/// lastは最後の２０データを表示。
/// allは全データを表示。
/// </summary>
enum GraphType { first, last, all}

// 画面定義
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

// 実際のRUN画面定義
class MyRunPage extends StatefulWidget {
  const MyRunPage({super.key});

  @override
  _MyRunPageState createState() => _MyRunPageState();
}

class _MyRunPageState extends State<MyRunPage> {
  // 表示様変数データ
  String _timeStr = "00:00:00";
  String _distanceStr = "0.0km";
  String _speedStr = "0.0m/s";
  String _altStr = "0.0m";
  //　グラフデータ
  List<FlSpot> _altGraphList = [];
  List<FlSpot> _spdGraphList = [];
  GraphType _graphType = GraphType.all;

  //　グラフ最大最小値範囲変数
  double _minAlt = 0, _maxAlt = 0;
  double _minSpd = 0, _maxSpd = 0;
  double _minGraphX = 0;
  final double _xMaxDefault = 20;
  double _maxGraphX = 20 ;
  int _intervalVal = 5;

  /// <summary>
  /// グラフのY軸の値をキリの良い値に変換する
  /// </summary>
  double convGraphValue(double value, bool upFlg, int scale ) {
    int digit = (value / scale).toInt();
    if (upFlg == true) {
      return ((digit + 1) * scale).toDouble();
    } else {
      return (digit * scale).toDouble();
    }
  }

  /// <summary>
  /// 初期化処理
  /// </summary>    
  @override
  void initState() {
    super.initState();

    // 1. Timer.periodic : 新しい繰り返しタイマーを作成します
    // 1秒ごとに run状況を更新していきます
    Timer.periodic(
      // 第一引数：繰り返す間隔の時間を設定
      const Duration(seconds: 1),
      // 第二引数：その間隔ごとに動作させたい処理を書く
      (Timer timer) async {
        //実態がある場合のみ、画面を更新する
        if (mounted == true) 
        {
          // １座標データの取得
          final oneCod = Gps.currentCoordinate;
          // グラフの表示範囲を設定
          // [first]の場合は最初の20データを表示
          if (_graphType == GraphType.first) {
            _minGraphX = 0;
            _maxGraphX = _xMaxDefault;
          } else 
          // [last]の場合は最後の20データを表示
          if (_graphType == GraphType.last) {
            _minGraphX = Gps.getCoordinateCount().toDouble() - _xMaxDefault;
            _maxGraphX = Gps.getCoordinateCount().toDouble();
            if (_minGraphX < 0) {
              _minGraphX = 0;
              _maxGraphX = _xMaxDefault;
            }
          } else 
          // [all]の場合は全データを表示
          {
            _minGraphX = 0;
            _maxGraphX = Gps.getCoordinateCount().toDouble();
            if (_maxGraphX < _xMaxDefault) {
              _maxGraphX = _xMaxDefault;
            }
          }
           // 速度のmin/max/data取得 (スケール２)
           _minSpd  = convGraphValue(Gps.getSpeedMin(), false,2);
           _maxSpd  = convGraphValue(Gps.getSpeedMax(), true,2);   
           _spdGraphList = Gps.getGpsLogGraphData(0,_minGraphX,_maxGraphX,_xMaxDefault);   
          // 標高のmin/max/data取得　(スケール５)
          _minAlt = convGraphValue(Gps.getAltMin(), false,5);
          _maxAlt = convGraphValue(Gps.getAltMax(), true,5);
          _altGraphList = Gps.getGpsLogGraphData(1,_minGraphX,_maxGraphX,_xMaxDefault);  
          // 表示文字を取得
          _timeStr = Gps.getGpsLogTime();
          _distanceStr = Gps.getGpsLogDistance();
          _speedStr = "${oneCod.dltSpeed.toStringAsFixed(2)}m/s";
          _altStr = "${oneCod.altitude.toStringAsFixed(2)}m";
          //
          //画面を更新する　
          setState(() {});  //buildメソッドを呼び出す
       }
      },
    );
  }
  /// <summary>
  /// 速度グラフデータを取得する
  /// timer-->setState-->build-->spdlineChartDataーー＞呼ばれる
  /// データがない場合、グラフエラーになるので、FlSpot(0,0)を返す
  /// </summary>
  List<FlSpot> get spdGraphList
  {
    if (_spdGraphList.isEmpty) {
      return [const FlSpot(0,0)];
    }
    return _spdGraphList;
  }
  LineChartData get spdlineChartData {
    _intervalVal = 5;
    if (spdGraphList.length > _xMaxDefault)
    {
      _intervalVal = 1+ (spdGraphList.length /4.0).toInt();
    }
    var linechart = LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: spdGraphList, //速度グラフ m/s
                    color: Colors.blue,
                    dotData: const FlDotData(show: false), // 点を非表示にする
                  ),
                ],
                titlesData: FlTitlesData(
                  topTitles: AxisTitles(
                    axisNameWidget: Text(
                      "速度($_speedStr)",
                    ),
                    axisNameSize: 35.0,
                  ),
                  rightTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                     showTitles: true,
                     interval: _intervalVal.toDouble(),
                     getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            fontSize: 14, // フォントサイズを12に設定
                          ),
                        );
                      },
                    ),
                  ),
                ),
                minY: _minSpd,
                maxY: _maxSpd,
                minX: _minGraphX,
                maxX: _maxGraphX,
              );
    return linechart;
  }
  /// <summary>
  /// 標高グラフデータを取得する
  /// timer-->setState-->build-->altlineChartDataーー＞呼ばれる
  /// データがない場合、グラフエラーになるので、FlSpot(0,0)を返す
  /// </summary>
  List<FlSpot> get altGraphList
  {
    if (_altGraphList.isEmpty) {
      return [const FlSpot(0,0)];
    }
    return _altGraphList;
  }
  LineChartData get altlineChartData {
    _intervalVal = 5;
    if (altGraphList.length > _xMaxDefault)
    {
      _intervalVal = 1+ (altGraphList.length /4.0).toInt();
    }
    var linechart = LineChartData(   
                lineBarsData: [
                  LineChartBarData(
                    spots: altGraphList, //速度グラフ m/s
                    //isCurved: true,
                    color: Colors.blue,
                    dotData: const FlDotData(show: false), // 点を非表示にする
                  ),
                ],
                titlesData: FlTitlesData(
                  topTitles: AxisTitles(
                    axisNameWidget: Text(
                      "標高($_altStr)"
                    ),
                    axisNameSize: 35.0,
                  ),
                  rightTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                     showTitles: true,
                     interval: _intervalVal.toDouble(),
                     getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            fontSize: 14, // フォントサイズを12に設定
                          ),
                        );
                      },
                    ),
                  ),
                ),
                minY: _minAlt,
                maxY: _maxAlt,
                minX: _minGraphX,
                maxX: _maxGraphX,
              );
    return linechart;
  }
  //  
  @override
  Widget build(BuildContext context) {
    // 配置部品用の基本サイズを求める
    var screenWidth = MediaQuery.of(context).size.width;
    var btnSize = screenWidth * 0.95;
    var btnHight = screenWidth * 0.1;
    //　常時ONボタンのスタイルを設定
    var style1On = TextButton.styleFrom(
      fixedSize: Size(btnSize/4,btnHight),// 幅,高さ
      foregroundColor: Colors.black,
      backgroundColor:const Color.fromARGB(195, 255, 255, 255),
    );
    //
    var styl0 = TextButton.styleFrom(
      fixedSize: Size(btnSize,btnHight),// 幅,高さ
      foregroundColor: Colors.black,
      backgroundColor: Gps.logSartFlg ? Colors.cyan : Colors.grey,
    );
    var styl1Start = TextButton.styleFrom(
      fixedSize: Size(btnSize/4,btnHight),// 幅,高さ
      foregroundColor: Colors.white,
      backgroundColor: Gps.logSartFlg ? Colors.grey : Colors.blue,
    );
    var styl1 = TextButton.styleFrom(
      fixedSize: Size(btnSize/4,btnHight),// 幅,高さ
      foregroundColor: Colors.white,
      backgroundColor: Gps.logSartFlg ? Colors.blue : Colors.grey,
    );
    //
    return Scaffold(
     body: Column(children: [
          TextButton(
            style: styl0,
            onPressed: () => {print("Timeボタンが押されたよ")},
            child: Text("走行時間: $_timeStr"),
          ),
          TextButton(
            style:  styl0,   
            onPressed: () => {print("Distanceボタンが押されたよ")},
            child: Text("走行距離: $_distanceStr"),
          ),
          Row(
             mainAxisAlignment: MainAxisAlignment.spaceAround,
             children: [
                TextButton(
                  style: styl1Start,         
                  onPressed: Gps.logSartFlg ? null : () => {
                    print("Startタンが押されたよ"),
                    Gps.gpsLogStart(),
                  } ,
                  child: const Text("Start"),
                ),
                TextButton(
                  style: styl1,  
                  onPressed: Gps.logSartFlg ? () => {
                    print("Stopタンが押されたよ"),
                    Gps.gpsLogStop() ,
                    } : null,
                  child: const Text("Stop"),
                ),
                TextButton(
                  style: style1On,  
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
                  style: styl1,    
                  onPressed: () => {
                    _graphType = GraphType.first,
                    print("<<が押されたよ")},
                  child: const Text("<<"),
                ),
                TextButton(
                  style:  styl1,   
                  onPressed: () => {
                    _graphType = GraphType.all,
                    print("allが押されたよ")},
                  child: const Text("all"),
                ),
                TextButton(
                  style:  styl1,  
                  onPressed: () => {
                    _graphType = GraphType.last,
                    print(">>が押されたよ")},
                  child: const Text(">>"),
                ),
             ]),
    ]),

    );
  }
}
