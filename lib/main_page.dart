import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_solution_challange/button.dart';
import 'package:google_solution_challange/settings_page.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

User? currentUser = FirebaseAuth.instance.currentUser;
GeoPoint currentPoint = GeoPoint(latitude: 0, longitude: 0);

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
  String currentLocationKey = ''; 
  bool canAddLocation = false;
  bool fetchedLocations = false;
  bool canShowDetails = false;
  bool canReport = false;
  String contributor = '';
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
    DatabaseReference database = FirebaseDatabase.instance.ref();
    DatabaseReference locationRef = database.child('location');
    DatabaseReference userRef = database.child('user');
    DatabaseReference reportRef = database.child('report');

    void displayError(String message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: Duration(seconds: 5),
        ),
      );
    }
    void reportLocation(bool found) async {
      bool alreadyReported = false;
      final uidSnapshot = await locationRef.child(currentLocationKey).child('uid').get();
      String uid = uidSnapshot.value as String;
      if (currentUser?.uid == uid)
      {
        displayError('Can\'t report locations added by you');
        return;
      }
      try
      {
        final reportsSnapshot = await reportRef.get();
        final reports = reportsSnapshot.value as Map<dynamic, dynamic>;
        reports.forEach((key, value) {
          if (key == currentUser?.uid && value == currentLocationKey)
          {
            alreadyReported = true;
            return;
          }
        });
      } 
      catch(e) { print(e); }    
      if (alreadyReported)
      {
        displayError('Can only report location once');
        return;
      }
      reportRef.set({currentUser?.uid: currentLocationKey});
      final currLocationSnapshot = await locationRef.child(currentLocationKey).get();
      final currentLocationValue = currLocationSnapshot.value as Map<dynamic, dynamic>;
      int foundValue = 0;
      if(found)
      {
        foundValue = currentLocationValue['found'] + 1;
        await locationRef.child(currentLocationKey).update({'found': foundValue});
      }
      else
      {
        foundValue = currentLocationValue['not_found'] + 1;
        await locationRef.child(currentLocationKey).update({'not_found': foundValue});
      }
    }

    void showDetails(GeoPoint point) async {
      await controller.goToLocation(point);
      currentPoint = point;
      final locationSnapshot = await locationRef.get();
      final userSnapshot = await userRef.get();
      final users = userSnapshot.value as Map<dynamic, dynamic>;
      final locations = locationSnapshot.value as Map<dynamic, dynamic>;
      locations.forEach(
        (locKey, locValue) => {
          if (locValue['latitude'] == point.latitude &&
              locValue['longitude'] == point.longitude)
            {
              currentLocationKey = locKey,
              users.forEach((userKey, userValue) {
                if (locValue['uid'] == userKey) {
                  contributor = userValue['name'];
                  return;
                }
              })
            }
        },
      );
      GeoPoint userLocation = await controller.myLocation();
      if ((userLocation.latitude - currentPoint.latitude).abs() <= 0.0001 &&
          (userLocation.longitude - currentPoint.longitude).abs() <= 0.0001)
      {
        canReport = true;
      }
      else
      {
        canReport = false;
      }
      setState(() {
        canShowDetails = true;
      });
    }

    void fetchLocations() async {
      fetchedLocations = true;
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
    }

    void addLocation() async {
      final locationsSnapshot = await userRef.child(currentUser!.uid).child('locations').get();
      final locations = locationsSnapshot.value as int;      
      if (locations == 0)
      {
        bool upToDate = true;
        final currDate = DateTime.now();
        String currDateFormatted = DateFormat('yMd').format(currDate); // month/day/year
        List<String> currDateList = currDateFormatted.split('/');
        final lastUpdatedSnapshot = await userRef.child(currentUser!.uid).child('last_updated').get();
        final lastUpdated = lastUpdatedSnapshot.value as String;
        List<String> lastUpdatedList = lastUpdated.split('/');
        for(int i = 0; i < 3; i++)
        {
          if (int.parse(lastUpdatedList[i]) - int.parse(currDateList[i]) >= 1)
          {
            upToDate = false;
            break;
          }
        }
        if (upToDate)
        {
          displayError('Can only add 5 locations per day');
          return;
        }
        else
        {
          await userRef.child(currentUser!.uid).update({'last_updated': currDateFormatted});
          await userRef.child(currentUser!.uid).update({'locations': 5});
        }
      }
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
        );
        await userRef.child(currentUser!.uid).update({'locations': locations - 1});
      } catch (e) {
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
        onGeoPointClicked: (p) => showDetails(p),
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
                  child: Center(
                    child: Column(
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              canShowDetails = false;
                            });
                          },
                          child: Text('Done'),
                        ),
                        Text('Added by $contributor'),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: (canReport)
                                  ? () => reportLocation(true)
                                  : () => displayError(
                                      'Please go near the marker to report'),
                              child: Text('Found'),
                            ),
                            TextButton(
                              onPressed: (canReport)
                                  ? () => reportLocation(false)
                                  : () => displayError(
                                      'Please go near the marker to report'),
                              child: Text('Not Found'),
                            ),
                          ],
                        ),
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
                        controller.currentLocation();
                      });
                    }
                  },
                ),
    );
  }
}
