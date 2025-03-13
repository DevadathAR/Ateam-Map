import 'package:ateam_map_task/service/services.dart';
import 'package:ateam_map_task/util/commonWidgets/tripMap.dart';
import 'package:ateam_map_task/util/textStyle.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Box box;
  final MapServices _mapboxService = MapServices();

  @override
  void initState() {
    super.initState();
    box = Hive.box('searchHistory');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _topBox(),
            _map(),
            _bottomBox(context),
          ],
        ),
      ),
    );
  }

  Expanded _map() {
    return Expanded(
      child: box.isEmpty
          ? const Center(child: Text('No saved trips'))
          : ListView.builder(
              itemCount: box.length,
              itemBuilder: (context, index) {
                var search = box.getAt(index);
                var startCoords = search['start'].split(',');
                var endCoords = search['end'].split(',');

                LatLng startLocation = LatLng(
                  double.parse(startCoords[0]),
                  double.parse(startCoords[1]),
                );
                LatLng endLocation = LatLng(
                  double.parse(endCoords[0]),
                  double.parse(endCoords[1]),
                );

                return TripMapCard(
                  tripNumber: index + 1,
                  start: startLocation,
                  end: endLocation,
                  mapboxService: _mapboxService,
                );
              },
            ),
    );
  }

  Container _bottomBox(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
      width: double.infinity,
      decoration: const BoxDecoration(color: Colors.blue),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.blue,
          padding: const EdgeInsets.symmetric(vertical: 15),
          textStyle: const TextStyle(fontSize: 16),
        ),
        child: Text(
          'Go Back',
          style: AppTextStyle.mediumText(size: 18),
        ),
      ),
    );
  }

  Container _topBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: const BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child:  Row(
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 50, color: Colors.blue),
          ),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                    "Devadath",
                    style: AppTextStyle.boldText(size: 22,color: Colors.white)
                  ),
                   Text(
                    "dev@gmail.com",
                    style:AppTextStyle.mediumText(size: 16,color: Colors.white)
                  ),
            ],
          ),
        ],
      ),
    );
  }
}
