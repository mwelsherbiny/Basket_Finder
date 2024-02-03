import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_solution_challange/settings_page.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:firebase_database/firebase_database.dart';

User? currentUser = FirebaseAuth.instance.currentUser;

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: MapPage(),
    );
  }
}

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  DatabaseReference database = FirebaseDatabase.instance.ref();
  bool canAddLocation = false;
  bool fetchedLocations = false;
  bool canShowDetails = false;
  MapController controller = MapController(
    initPosition: GeoPoint(latitude: 47.4358055, longitude: 8.4737324),
    areaLimit: BoundingBox(
      east: 10.4922941,
      north: 47.8084648,
      south: 45.817995,
      west: 5.9559113,
    ),
  );

  Widget build(BuildContext context) {
    DatabaseReference locationRef = database.child('location');

    void showDetails() {
      setState(() {
        canShowDetails = true;
      });
    }

    void fetchLocations() async {
      final locationsSnapshot = await locationRef.get();
      final locations = locationsSnapshot.value as Map<dynamic, dynamic>;
      locations.forEach((key, value) {
        GeoPoint point = GeoPoint(
            latitude: value['latitude'], longitude: value['longitude']);
        controller.addMarker(
          point,
          markerIcon: MarkerIcon(
            icon: Icon(Icons.verified_user),
          ),
        );
      });
      fetchedLocations = true;
    }

    void addLocation() async {
      await controller.currentLocation();
      GeoPoint point = await controller.myLocation();
      try {
        final location = {
          'latitude': point.latitude,
          'longitude': point.longitude,
          'uid': currentUser?.uid,
          'found': 0,
          "not_found": 0,
        };
        locationRef.push().set(location);
        controller.addMarker(
          point,
          markerIcon: MarkerIcon(
            icon: Icon(
              Icons.verified_user,
            ),
          ),
          iconAnchor: IconAnchor(anchor: Anchor.top),
        );
      } catch (e) {
        print('error');
        print(e);
      }
    }

    if (!fetchedLocations) {
      fetchLocations();
    }
    return Scaffold(
      floatingActionButton: FloatingActionButton(
              onPressed: () {
                setState(() {
                  controller.currentLocation();
                });
              },
              backgroundColor: Colors.white,
              child: SvgPicture.asset(
                'assets/main/location.svg',
              ),
            ),
      backgroundColor: Colors.white,
      body: OSMFlutter(
        onGeoPointClicked: (p) => showDetails(),
        controller: controller,
        osmOption: OSMOption(
          userTrackingOption: const UserTrackingOption(
            enableTracking: true,
            unFollowUser: true,
          ),
          zoomOption: const ZoomOption(
            initZoom: 15,
            minZoomLevel: 3,
            maxZoomLevel: 19,
            stepZoom: 1.0,
          ),
          userLocationMarker: UserLocationMaker(
            personMarker: const MarkerIcon(
              icon: Icon(
                Icons.location_history_rounded,
                color: Colors.blue,
                size: 48,
              ),
            ),
            directionArrowMarker: const MarkerIcon(
              icon: Icon(
                Icons.double_arrow,
                size: 48,
              ),
            ),
          ),
          roadConfiguration: const RoadOption(
            roadColor: Colors.grey,
          ),
          markerOption: MarkerOption(
              defaultMarker: const MarkerIcon(
            icon: Icon(
              Icons.person_pin_circle,
              color: Colors.blue,
              size: 56,
            ),
          )),
          enableRotationByGesture: true,
        ),
      ),
      bottomNavigationBar: (canAddLocation)
          ? Container(
              height: 60,
              color: Colors.white,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    canAddLocation = false;
                    addLocation();
                  });
                },
                child: Column(
                  children: [
                    SvgPicture.asset('assets/sign_up/confirm.svg'),
                    Text('Select Location'),
                  ],
                ),
              ),
            )
          : (canShowDetails)
              ? Container(
                  height: 150,
                  child: Column(
                    children: [
                      Text('Added by ........'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: null,
                            child: Text('Found'),
                          ),                           
                          TextButton(
                            onPressed: null,
                            child: Text('Not Found'),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              : BottomNavigationBar(
                  items: [
                    BottomNavigationBarItem(
                      label: 'Add Location',
                      icon: SvgPicture.asset('assets/main/add_location.svg'),
                    ),
                    BottomNavigationBarItem(
                      label: 'Find Nearest',
                      icon: SvgPicture.asset('assets/main/find_nearest.svg'),
                    ),
                    BottomNavigationBarItem(
                      label: 'Settings',
                      icon: SvgPicture.asset('assets/main/settings.svg'),
                    ),
                  ],
                  onTap: (int index) {
                    if (index == 2) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => settingsPage(),
                        ),
                      );
                    } else if (index == 1) {
                      // TODO: find nearest
                    } else if (index == 0) {
                      setState(() {
                        canAddLocation = true;
                        controller.currentLocation();
                      });
                    }
                  },
                ),
    );
  }
}
