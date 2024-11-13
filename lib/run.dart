
import 'package:flutter/material.dart';
import 'gps.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';
import 'dart:async';

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
    return Scaffold(
     body: Column(children: [
          const Text("HelloWorld"),
          const Text("ハローワールド"),
          TextButton(
            onPressed: () => {print("ボタンが押されたよ")},
            child: const Text("テキストボタン"),
          ),
         Row(
             mainAxisAlignment: MainAxisAlignment.spaceAround,
             children: const [
               Icon(
                 Icons.favorite,
                 color: Colors.pink,
                 size: 24.0,
               ),
               Icon(
                 Icons.audiotrack,
                 color: Colors.green,
                 size: 30.0,
               ),
               Icon(
                 Icons.beach_access,
                 color: Colors.blue,
                 size: 36.0,
               ),
             ]),
        ])
      ,      
      floatingActionButton:  Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            FloatingActionButton(
              onPressed:  () => {print("ボタンが押されたよ")},
              tooltip: 'ChangeMap',
              child: const Icon(Icons.layers),
            ),
            FloatingActionButton(
              onPressed:  () => {print("ボタンが押されたよ")},
              tooltip: 'Increment',
              child: const Icon(Icons.add),
            ),
            FloatingActionButton(
              onPressed:  () => {print("ボタンが押されたよ")},
              tooltip: 'Decrement',
              child: const Icon(Icons.remove),
            ),
          ],
        ),
      );
  }
}
