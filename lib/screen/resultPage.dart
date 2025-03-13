import 'package:ateam_map_task/service/services.dart';
import 'package:ateam_map_task/util/textStyle.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class ResultsScreen extends StatefulWidget {
  final LatLng start;
  final LatLng end;
  final List<LatLng> route;
  final String distance;

  ResultsScreen({
    required this.start,
    required this.end,
    required this.route,
    required this.distance,
  });

  @override
  _ResultsScreenState createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  MapboxMapController? mapController;

  void _onMapCreated(MapboxMapController controller) {
    setState(() {
      mapController = controller;
    });

    Future.delayed(const Duration(milliseconds: 800), _drawRoute);
  }

  void _drawRoute() {
    if (mapController == null) return;

    if (widget.route.isEmpty) {
      print("Error: Route is empty!");
      return;
    }

    print("Drawing route with ${widget.route.length} points");

    mapController!.addLine(LineOptions(
      geometry: widget.route,
      lineColor: "#00FFFF",
      lineWidth: 2.0,
    ));

    mapController!.addSymbol(SymbolOptions(
      geometry: widget.start,
      iconImage: 'marker-15',
      iconSize: 2,
      iconColor: '#00FF00',
    ));

    mapController!.addSymbol(SymbolOptions(
      geometry: widget.end,
      iconImage: 'marker-15',
      iconSize: 2,
      iconColor: '#FF0000',
    ));
  }

  void _saveSearch() {
    var box = Hive.box('searchHistory');
    box.add({
      'start': '${widget.start.latitude},${widget.start.longitude}',
      'end': '${widget.end.latitude},${widget.end.longitude}'
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Search saved!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _topBox(),
            _map(size),
            const Spacer(),
            _bottomBox(context),
          ],
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Your Location",
              style: AppTextStyle.regularText(size: 12, color: Colors.white)),
            Text(
  "${widget.start.latitude}, ${widget.start.longitude}", 
  style: AppTextStyle.semiboldText(size: 20, color: Colors.white),
),
          const Divider(color: Colors.white),
          Text(
  "${widget.end.latitude}, ${widget.end.longitude}", 
  style: AppTextStyle.semiboldText(size: 20, color: Colors.white),
),

          const SizedBox(height: 5),
          Text("Distance: ${widget.distance}",
              style: AppTextStyle.mediumText(size: 16, color: Colors.white)),
        ],
      ),
    );
  }

  Container _bottomBox(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 150),
      height: 100,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.blue,
      ),
      child: ElevatedButton(
        onPressed: () {
          _saveSearch();
          Navigator.pop(context);
        },
        child: Text(
          'Go Back',
          style: AppTextStyle.mediumText(size: 18),
        ),
      ),
    );
  }

  Expanded _map(Size size) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          height: size.height * 0.8,
          padding:
              const EdgeInsets.only(top: 35, bottom: 16, right: 16, left: 16),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(15)),
              border: Border.all(color: Colors.blue)),
          child: MapboxMap(
            accessToken:MapServices.accessToken,
                // 'pk.eyJ1IjoiYWtoaWxsZXZha3VtYXIiLCJhIjoiY2x4MDcwYzZ4MGl2aTJqcmFxbXZzc3lndiJ9.9sxfvrADlA25b1CHX2VuDA',
            initialCameraPosition:
                CameraPosition(target: widget.start, zoom: 12),
            onMapCreated: _onMapCreated,
          ),
        ),
      ),
    );
  }
}


// 