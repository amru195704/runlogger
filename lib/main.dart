import 'package:flutter/material.dart';
import 'map.dart';
import 'model/gps.dart';
import 'run.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key})
  {
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
                Tab(icon: Icon(Icons.directions_car), text: "map"),
                Tab(icon: Icon(Icons.directions_transit), text: "run"),
                Tab(icon: Icon(Icons.directions_bike), text: "Bike"),
              ],
            ),
            title: const Text('RunLogger'),
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