import 'package:ateam_map_task/service/services.dart';
import 'package:ateam_map_task/util/textStyle.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:ateam_map_task/screen/resultPage.dart';
import 'package:ateam_map_task/screen/saved.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  LatLng? startLocation;
  LatLng? endLocation;
  MapboxMapController? startMapController;
  MapboxMapController? endMapController;

  final MapServices _mapboxService = MapServices();

  void _onStartMapCreated(MapboxMapController controller) {
    startMapController = controller;
  }

  void _onEndMapCreated(MapboxMapController controller) {
    endMapController = controller;
  }

  void _setStartLocation(LatLng point) {
    setState(() {
      startLocation = point;
      startMapController?.clearSymbols();
      startMapController?.addSymbol(SymbolOptions(
        geometry: point,
        iconImage: 'marker-15',
      ));
    });
  }

  void _setEndLocation(LatLng point) {
    setState(() {
      endLocation = point;
      endMapController?.clearSymbols();
      endMapController?.addSymbol(SymbolOptions(
        geometry: point,
        iconImage: 'marker-15',
      ));
    });
  }

  void _navigateToResults() async {
    if (startLocation != null && endLocation != null) {
      List<LatLng> route =
          await _mapboxService.getRoute(startLocation!, endLocation!);
      double? distance =
          await _mapboxService.getDistance(startLocation!, endLocation!);

      if (distance != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultsScreen(
              start: startLocation!,
              end: endLocation!,
              route: route,
              distance: '${distance.toStringAsFixed(2)} km',
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select locations')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _topBox(),
            Expanded(
              child: _buildMapSection(
                "Start Location",
                startLocation,
                _onStartMapCreated,
                _setStartLocation,
              ),
            ),
            Expanded(
              child: _buildMapSection(
                "End Location",
                endLocation,
                _onEndMapCreated,
                _setEndLocation,
              ),
            ),
            _bottomConatiner(context),
          ],
        ),
      ),
    );
  }

  Container _bottomConatiner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: const BoxDecoration(color: Colors.blue),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ElevatedButton(
            onPressed: _navigateToResults,
            child: Text(
              'Navigate',
              style: AppTextStyle.mediumText(size: 18),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HistoryScreen()),
              );
            },
            child: Text(
              'Saved',
              style: AppTextStyle.mediumText(size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Container _topBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: const BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: const Icon(Icons.person, size: 50, color: Colors.blue),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Devadath",
                  style: AppTextStyle.boldText(size: 22, color: Colors.white)),
              Text("devadathar001@gmail.com",
                  style:
                      AppTextStyle.mediumText(size: 16, color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection(
    String label,
    LatLng? location,
    Function(MapboxMapController) onMapCreated,
    Function(LatLng) onMapClick,
  ) {
    Size size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Container(
          height: size.height * 0.4,
          padding:
              const EdgeInsets.only(top: 35, bottom: 16, right: 16, left: 16),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(15)),
              border: Border.all(color: Colors.blue)),
          child: MapboxMap(
            accessToken: MapServices.accessToken,
            onMapCreated: onMapCreated,
            onMapClick: (point, latLng) => onMapClick(latLng),
            initialCameraPosition: const CameraPosition(
              target: LatLng(8.5241, 76.9366),
              zoom: 10,
            ),
          ),
        ),
        Positioned(
          top: 20,
          left: 20,
          child: Row(
            children: [
              const Icon(Icons.location_pin),
              Text(
                location != null
                    ? "$label: ${location.latitude}, ${location.longitude}"
                    : label,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
