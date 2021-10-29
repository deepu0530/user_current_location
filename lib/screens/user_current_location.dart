import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';

import 'package:geolocator/geolocator.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CurrentLocation extends StatefulWidget {
  const CurrentLocation({Key? key}) : super(key: key);

  @override
  _CurrentLocationState createState() => _CurrentLocationState();
}

class _CurrentLocationState extends State<CurrentLocation> {
  MapController mapController = MapController();

  

  String latitude1 = 'Latitude';
  String longtitude1 = 'Longtitude';
  String address = 'Address';
  double? lat;
  double? long;

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();

      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> getAddress(Position position) async {
    List<Placemark> placemark =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    print(placemark);
    Placemark place = placemark[0];
    address = '${place.street}, ${place.thoroughfare}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.administrativeArea}, ${place.country}(${place.isoCountryCode})';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "User Current Location",
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.green,
            child: FlutterMap(
              options: MapOptions(
                 center: LatLng(51.5, -0.09),
                //center: LatLng(lat!,long!), // London
                zoom: 16.0,
                minZoom: 10,
              ),
              layers: [
                new TileLayerOptions(
                  urlTemplate:
                      'https://api.mapbox.com/styles/v1/deepika1999/ckvcak22z0m0i15tf1q3kfvah/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiZGVlcGlrYTE5OTkiLCJhIjoiY2t1dzgzbHNlMDNzZTJ1cXc2NjJuejBoYSJ9.A9vUCVG4TnhAPvxSPosu-g',
                  additionalOptions: {
                    'accessToken': 'YOUR accessToken',
                  },
                ),
                MarkerLayerOptions(
                  markers: [
          Marker(
            width: 80.0,
            height: 80.0,
            point: LatLng(51.5, -0.09),
            builder: (ctx) =>
            Container(
              child: Icon(Icons.location_on,color: Colors.red,size: 25,)
            ),
          ),
        ],
                ),
              ],
              mapController: mapController,
            ),
          ),
          Positioned(
            top: 10,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.all(20),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        offset: Offset(0, 4),
                        blurRadius: 6,
                        spreadRadius: 0,
                        color: Colors.grey.withOpacity(0.2))
                  ]),
              child: Column(
                children: [
                  Text(
                    address,
                   textAlign: TextAlign.center,
                    style: TextStyle(
                      
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 16),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    latitude1,
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 16),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    longtitude1,
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 16),
                  )
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: GestureDetector(
              onTap: () async {
                Position position = await _determinePosition();
                print(position.latitude);
                print(position.longitude);
                latitude1 = 'Latitude : ${position.latitude}';
                longtitude1 = 'Latitude : ${position.longitude}';
                getAddress(position);
                lat = position.latitude;
                long = position.longitude;
                setState(() {

                });
              },
              child: Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Center(child: Icon(Icons.gps_fixed,size: 25,))),
            ),
          ),
        ],
      ),
    );
  }


}
