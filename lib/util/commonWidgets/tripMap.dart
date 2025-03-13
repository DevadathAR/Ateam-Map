import 'package:ateam_map_task/service/services.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class TripMapCard extends StatefulWidget {
  final int tripNumber;
  final LatLng start;
  final LatLng end;
  final MapServices mapboxService; 

  const TripMapCard({
    Key? key,
    required this.tripNumber,
    required this.start,
    required this.end,
    required this.mapboxService,
  }) : super(key: key);

  @override
  _TripMapCardState createState() => _TripMapCardState();
}

class _TripMapCardState extends State<TripMapCard> {
  MapboxMapController? mapController;
  List<LatLng> routeCoordinates = [];

  @override
  void initState() {
    super.initState();
    _fetchRoute();
  }

  Future<void> _fetchRoute() async {
    List<LatLng> route = await widget.mapboxService.getRoute(widget.start, widget.end);

    setState(() {
      routeCoordinates = route;
    });

    _updateMap();
  }

  void _updateMap() {
    if (mapController == null || routeCoordinates.isEmpty) return;

    mapController!.clearSymbols();
    mapController!.clearLines();

    mapController!.addSymbol(SymbolOptions(
      geometry: widget.start,
      iconImage: 'marker-15',
      iconSize: 1.8,
      iconColor: '#00FF00',
    ));
    mapController!.addSymbol(SymbolOptions(
      geometry: widget.end,
      iconImage: 'marker-15',
      iconSize: 1.8,
      iconColor: '#FF0000',
    ));

    mapController!.addLine(LineOptions(
      geometry: routeCoordinates,
      lineColor: "#00FFFF",
      lineWidth: 5.0,
    ));

    mapController!.animateCamera(CameraUpdate.newLatLngBounds(
      LatLngBounds(
        southwest: LatLng(
          widget.start.latitude < widget.end.latitude ? widget.start.latitude : widget.end.latitude,
          widget.start.longitude < widget.end.longitude ? widget.start.longitude : widget.end.longitude,
        ),
        northeast: LatLng(
          widget.start.latitude > widget.end.latitude ? widget.start.latitude : widget.end.latitude,
          widget.start.longitude > widget.end.longitude ? widget.start.longitude : widget.end.longitude,
        ),
      ),
      left: 50,
      right: 50,
      top: 50,
      bottom: 50,
    ));
  }

  void _onMapCreated(MapboxMapController controller) {
    setState(() {
      mapController = controller;
    });

    Future.delayed(const Duration(milliseconds: 800), _updateMap);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Stack(
        children: [
          Positioned(
            top: 25,
            left: 40,
            child: Text(
              "Trip ${widget.tripNumber}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),

          // Map
          Container(
            height: size.height * 0.3,
            padding: const EdgeInsets.only(top: 35, bottom: 16, right: 16, left: 16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.blue),
            ),
            child: MapboxMap(
              accessToken: MapServices.accessToken,
              initialCameraPosition: CameraPosition(target: widget.start, zoom: 10),
              onMapCreated: _onMapCreated,
            ),
          ),
        ],
      ),
    );
  }
}
