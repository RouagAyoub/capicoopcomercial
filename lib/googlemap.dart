import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geocoder/services/base.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Googlemaps extends StatefulWidget {
  // Googlemaps({ Key key}) : super(key: key);

  @override
  _GooglemapsState createState() => _GooglemapsState();
}

Position position;
List<Address> adress;

class _GooglemapsState extends State<Googlemaps> {
  Completer<GoogleMapController> _controller = Completer();
  Geocoding geocoding = Geocoder.local;

  var placeMark;
  Widget _child;

  @override
  void initState() {
    _getCurrentLocation();
    getLocation();
    super.initState();
  }

  Future<void> getLocation() async {
    bool serviceEnabled;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
  }

  Set<Marker> createMarker(double posisionlat, double posotionlon) {
    return <Marker>[
      Marker(
          markerId: MarkerId('home'),
          position: LatLng(posisionlat, posotionlon),
          icon: BitmapDescriptor.defaultMarker,
          infoWindow: InfoWindow(title: 'Current Location'))
    ].toSet();
  }

  Widget _mapWidget() {
    return Stack(
      children: [
        GoogleMap(
          mapType: MapType.normal,
          markers: createMarker(position.latitude, position.longitude),
          initialCameraPosition: CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 12.0,
          ),
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
        ),
        ElevatedButton.icon(
          onPressed: () {
            _getCurrentLocation();
          },
          icon: Icon(Icons.replay_circle_filled),
          label: Container(
            height: 0,
            width: 0,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
          ),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                  Colors.black.withOpacity(0.0))),
        ),
      ],
    );
  }

  // ignore: unused_element
  void _getCurrentLocation() async {
    Position res = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    setState(() {
      position = res;
      _child = _mapWidget();
    });
    adress = await geocoding.findAddressesFromCoordinates(
        new Coordinates(position.latitude, position.longitude));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _child,
    );
  }
}
