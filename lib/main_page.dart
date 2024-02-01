import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_solution_challange/button.dart';
import 'package:google_solution_challange/sign_in.dart';
import 'package:google_solution_challange/input.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_solution_challange/settings_page.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:firebase_database/firebase_database.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;
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
  bool canAddLocation = false;
  bool locationAdded = false;
  MapController controller = MapController(
    initPosition: GeoPoint(latitude: 47.4358055, longitude: 8.4737324),
    areaLimit: BoundingBox(
      east: 10.4922941,
      north: 47.8084648,
      south: 45.817995,
      west: 5.9559113,
    ),
  );

  void addLocation() async {
    await controller.currentLocation();
    await controller.advancedPositionPicker();
    if (locationAdded) {
      GeoPoint point = await controller.getCurrentPositionAdvancedPositionPicker();

      controller.addMarker(
        point,
        markerIcon: MarkerIcon(
          icon: Icon(Icons.verified_user, ),
        ),
        iconAnchor: IconAnchor(anchor: Anchor.top),
      );
      controller.currentLocation();
      locationAdded = false;
      await controller.cancelAdvancedPositionPicker();
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: (canAddLocation)? null : FloatingActionButton(
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
                    locationAdded = true;
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
                    addLocation();
                  });
                }
              },
            ),
    );
  }
}
