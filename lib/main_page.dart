import 'dart:async';
import 'dart:ffi';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_solution_challange/main_button.dart';
import 'package:google_solution_challange/settings_page.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_solution_challange/styled_text.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:osm_nominatim/osm_nominatim.dart';
import 'package:flutter_map_math/flutter_geo_math.dart';
import 'package:geolocator/geolocator.dart';

class PositionData {
  final double latitude;
  final double longitude;

  PositionData(this.latitude, this.longitude); // for find nearest feature >>
}

User? currentUser = FirebaseAuth.instance.currentUser;
GeoPoint currentPoint = GeoPoint(latitude: 0, longitude: 0);
Color mainColor = Color.fromRGBO(55, 235, 115, 1);

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
  List<String> contributor = [];
  String roadName = '';
  double distance = 0;
  bool showWindow = false;
  bool? green = true;
  bool? red = true;
  bool? orange = true;
  int requests = 0;
  bool find_nearest_button_pressed = false;

  List<GeoPoint> userPoints = [];
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
    DatabaseReference userId = userRef.child(currentUser!.uid);
    DatabaseReference userCredibility =
        userId.child('credibility'); //added "user" to avoid collisions

    int realtime_credibility = 0;
    int locations_limit = 5;
    int calc_location_limit() {
      if (realtime_credibility == 0) {
        locations_limit = 0;
      } else if (realtime_credibility < 3) {
        switch (realtime_credibility) {
          case 2:
            locations_limit -= 2;
            break;
          case 1:
            locations_limit -= 4;
            break;
        }
      } else if (realtime_credibility > 3) {
        if (realtime_credibility > 10) {
          locations_limit = 10;
        }
      }
      return locations_limit;
    }

    userCredibility.onValue.listen((event) {
      setState(() {
        realtime_credibility = event.snapshot.value as int;
        calc_location_limit();
      });
    });

    List<GeoPoint> userPoints = [];
    List<GeoPoint> greenPoints = [];
    List<GeoPoint> redPoints = [];
    List<GeoPoint> orangePoints = [];

    void removeLocation() async {
      controller.removeMarker(currentPoint);
      await locationRef.child(currentLocationKey).remove();
      setState(() {
        canShowDetails = false;
      });
    }

    void applyFilter() {
      (green == false)
          ? controller.setStaticPosition([], 'green')
          : controller.setStaticPosition(greenPoints, 'green');
      (red == false)
          ? controller.setStaticPosition([], 'red')
          : controller.setStaticPosition(redPoints, 'red');
      (orange == false)
          ? controller.setStaticPosition([], 'orange')
          : controller.setStaticPosition(orangePoints, 'orange');
    }

    void displayError(String message, {int duration = 5}) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: Duration(seconds: duration),
        ),
      );
    }

    String _determineMarkerColor(int found, int notFound, String uid) {
      if (uid == currentUser?.uid) {
        return 'user';
      } else if (notFound > 0) {
        return 'red';
      } else if (found >= 3) {
        return 'green';
      } else {
        return 'orange';
      }
    }

    void reportLocation(bool found) async {
      bool alreadyReported = false;
      final uidSnapshot =
          await locationRef.child(currentLocationKey).child('uid').get();
      String uid = uidSnapshot.value as String;
      if (currentUser?.uid == uid) {
        displayError('Can\'t report locations added by you');
        return;
      }
      try {
        final reportsSnapshot = await reportRef.get();
        final reports = reportsSnapshot.value as Map<dynamic, dynamic>;
        reports.forEach((key, value) {
          if (key == currentUser?.uid && value == currentLocationKey) {
            alreadyReported = true;
            return;
          }
        });
      } catch (e) {
        print(e);
      }
      if (alreadyReported) {
        displayError('Can only report location once');
        return;
      }
      reportRef.set({currentUser?.uid: currentLocationKey});
      final currLocationSnapshot =
          await locationRef.child(currentLocationKey).get();
      final currentLocationValue =
          currLocationSnapshot.value as Map<dynamic, dynamic>;
      int foundValue = 0;
      if (found) {
        foundValue = currentLocationValue['found'] + 1;
        final userSnapshot = await userRef.child(uid).get();
        final user = userSnapshot.value as Map<dynamic, dynamic>;
        final credValue = user['credibility'];
        if (foundValue == 3) {
          locationRef.child(currentLocationKey).update({'exists': true});
        }
        await locationRef
            .child(currentLocationKey)
            .update({'found': foundValue});
        await userRef.child(uid).update({'credibility': credValue + 1});
      } else {
        foundValue = currentLocationValue['not_found'] + 1;
        bool exists = currentLocationValue['exists'];
        if (foundValue == 3) {
          if (!exists) {
            final credibilitySnapshot =
                await userRef.child(uid).child('credibility').get();
            int credibility = credibilitySnapshot.value as int;
            await userRef.child(uid).update({'credibility': credibility - 1});
          }
          await locationRef.child(currentLocationKey).remove();
          return;
        }
        await locationRef
            .child(currentLocationKey)
            .update({'not_found': foundValue});
      }
    }

    void showDetails(GeoPoint point) async {
      // get road name
      await controller.goToLocation(point);
      final reverseSearchResult = await Nominatim.reverseSearch(
        lat: point.latitude,
        lon: point.longitude,
        addressDetails: true,
      );
      roadName = reverseSearchResult.address?['road'];
      // get distance between user and location
      GeoPoint userLocation = await controller.myLocation();
      distance = FlutterMapMath().distanceBetween(userLocation.latitude,
          userLocation.longitude, point.latitude, point.longitude, 'meters');

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
                  contributor = [userKey, userValue['name']];
                  return;
                }
              })
            }
        },
      );
      if ((userLocation.latitude - currentPoint.latitude).abs() <= 0.0001 &&
          (userLocation.longitude - currentPoint.longitude).abs() <= 0.0001) {
        canReport = true;
      } else {
        canReport = false;
      }
      setState(() {
        canShowDetails = true;
      });
    }

// --------------------------------------------------------------------------------------------
    void removeRoads() async {
      await controller.clearAllRoads();
    }

    PositionData minDistanceCalc(
      Position currentPosition,
      List<PositionData> positions,
    ) {
      double minDistance = double.infinity;
      PositionData nearestPosition = PositionData(0, 0);

      for (PositionData otherPosition in positions) {
        final distance = Geolocator.distanceBetween(
          currentPosition.latitude,
          currentPosition.longitude,
          otherPosition.latitude,
          otherPosition.longitude,
        );

        if (distance < minDistance) {
          minDistance = distance;
          nearestPosition = otherPosition;
        }
      }
      return nearestPosition;
    }

    void findNearestLocation() async {
      List<PositionData> basketsLocations = [];
      final locationsSnapshot = await locationRef.get();
      final locations = locationsSnapshot.value as Map<dynamic, dynamic>;
      locations.forEach((key, value) {
        PositionData targetBasket =
            PositionData(value['latitude'], value['longitude']);
        basketsLocations.add(targetBasket);
      });
      Position currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      double currentLatitude = currentPosition.latitude;
      double currentLongitude = currentPosition.longitude;
      PositionData nearestBasket =
          minDistanceCalc(currentPosition, basketsLocations);

      RoadInfo roadInfo = await controller.drawRoad(
        GeoPoint(latitude: currentLatitude, longitude: currentLongitude),
        GeoPoint(
            latitude: nearestBasket.latitude,
            longitude: nearestBasket.longitude),
        roadType: RoadType.car,
        intersectPoint: [
          GeoPoint(latitude: currentLatitude, longitude: currentLongitude),
          GeoPoint(
              latitude: nearestBasket.latitude,
              longitude: nearestBasket.longitude)
        ],
        roadOption: RoadOption(
          roadWidth: 10,
          roadColor: Color.fromARGB(255, 57, 224, 42),
          zoomInto: true,
        ),
      );
//  print("${roadInfo.distance}km");
//  print("${roadInfo.duration}sec");
//  print("${roadInfo.instructions}");
    }
// ----------------------------------------------------- find nearest function >>

    void fetchLocations() async {
      controller.setStaticPosition([], 'green');
      controller.setStaticPosition([], 'red');
      controller.setStaticPosition([], 'orange');
      controller.removeMarkers(userPoints);
      fetchedLocations = true;
      final locationsSnapshot = await locationRef.get();
      final locations = locationsSnapshot.value as Map<dynamic, dynamic>;
      locations.forEach((key, value) {
        final found = value['found'] as int;
        final notFound = value['not_found'] as int;
        final updatedMarker =
            _determineMarkerColor(found, notFound, value['uid']);
        GeoPoint point = GeoPoint(
            latitude: value['latitude'], longitude: value['longitude']);
        switch (updatedMarker) {
          case 'user':
            userPoints.add(point);
            controller.addMarker(point);
          case 'green':
            greenPoints.add(point);
            break;
          case 'red':
            redPoints.add(point);
            break;
          case 'orange':
            orangePoints.add(point);
            break;
        }
      });
      await controller.setStaticPosition(greenPoints, 'green');
      await controller.setMarkerOfStaticPoint(
          id: 'green',
          markerIcon: MarkerIcon(
            iconWidget: Image(
              image:
                  Image(image: AssetImage('assets/Colored_Markers/green.png'))
                      .image,
              width: 25,
            ),
          ));

      await controller.setStaticPosition(redPoints, 'red');
      await controller.setMarkerOfStaticPoint(
          id: 'red',
          markerIcon: MarkerIcon(
            iconWidget: Image(
              image: Image(image: AssetImage('assets/Colored_Markers/red.png'))
                  .image,
              width: 25,
            ),
          ));

      await controller.setStaticPosition(orangePoints, 'orange');
      await controller.setMarkerOfStaticPoint(
          id: 'orange',
          markerIcon: MarkerIcon(
            iconWidget: Image(
              image:
                  Image(image: AssetImage('assets/Colored_Markers/orange.png'))
                      .image,
              width: 25,
            ),
          ));
    }

    void addLocation() async {
      final locationsSnapshot =
          await userRef.child(currentUser!.uid).child('locations').get();
      int locations = locationsSnapshot.value as int;
      if (locations == 0) {
        bool upToDate = true;
        final currDate = DateTime.now();
        String currDateFormatted =
            DateFormat('yMd').format(currDate); // month/day/year
        List<String> currDateList = currDateFormatted.split('/');
        final lastUpdatedSnapshot =
            await userRef.child(currentUser!.uid).child('last_updated').get();
        final lastUpdated = lastUpdatedSnapshot.value as String;
        List<String> lastUpdatedList = lastUpdated.split('/');
        for (int i = 0; i < 3; i++) {
          if (int.parse(currDateList[i]) - int.parse(lastUpdatedList[i]) >= 1) {
            upToDate = false;
            break;
          }
        }
        if (upToDate) {
          displayError('Can only add $locations_limit locations per day');
          return;
        } else {
          locations = locations_limit;
          await userRef
              .child(currentUser!.uid)
              .update({'last_updated': currDateFormatted});
          await userRef
              .child(currentUser!.uid)
              .update({'locations': locations});
        }
      }
      bool locationAlreadyExists = false;
      await controller.currentLocation();
      GeoPoint point = await controller.myLocation();
      try {
        final locationKeysSnapshot = await locationRef.get();
        final locationKeys =
            locationKeysSnapshot.value as Map<dynamic, dynamic>;
        locationKeys.forEach((key, value) {
          if ((value['latitude'] - point.latitude).abs() <= 0.0001 &&
              (value['longitude'] - point.longitude).abs() <= 0.0001) {
            displayError('Can\'t add multiple locations at the same point');
            locationAlreadyExists = true;
          }
        });
        if (locationAlreadyExists) {
          return;
        }
      } catch (e) {
        print(e);
      }

      try {
        final location = {
          'latitude': point.latitude,
          'longitude': point.longitude,
          'uid': currentUser?.uid,
          'found': 0,
          'not_found': 0,
          'exists': false,
        };
        locationRef.push().set(location);
        controller.addMarker(point);
        await userRef
            .child(currentUser!.uid)
            .update({'locations': locations - 1});
      } catch (e) {
        print(e);
      }
    }

    if (!fetchedLocations) {
      fetchLocations();
    }
    return Scaffold(
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              setState(() {
                controller.currentLocation();
              });
            },
            backgroundColor: Colors.white,
            child: SvgPicture.asset(
              'assets/Colored_Markers/target_location.svg',
            ),
          ),
          SizedBox(
            height: 20,
          ),
          FloatingActionButton(
              backgroundColor: Colors.white,
              child: SvgPicture.asset(
                'assets/Colored_Markers/filter.svg',
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                    return AlertDialog(
                      backgroundColor: Colors.white,
                      surfaceTintColor: mainColor,
                      title: Text('Filter'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CheckboxListTile(
                            overlayColor: MaterialStatePropertyAll(
                                Color.fromRGBO(44, 186, 91, 1)),
                            fillColor: MaterialStatePropertyAll(mainColor),
                            title: Text('Likely To Find'),
                            value: green,
                            onChanged: (newBool) {
                              setState(
                                () {
                                  green = newBool;
                                },
                              );
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                          CheckboxListTile(
                            overlayColor: MaterialStatePropertyAll(
                                Color.fromARGB(255, 211, 127, 0)),
                            fillColor: MaterialStatePropertyAll(Colors.orange),
                            title: Text('Not Confirmed'),
                            value: orange,
                            onChanged: (newBool) {
                              setState(
                                () {
                                  orange = newBool;
                                },
                              );
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                          CheckboxListTile(
                            overlayColor: MaterialStatePropertyAll(
                                const Color.fromARGB(255, 154, 40, 32)),
                            fillColor: MaterialStatePropertyAll(Colors.red),
                            title: Text('Not Likely To Find'),
                            value: red,
                            onChanged: (newBool) {
                              setState(
                                () {
                                  red = newBool;
                                },
                              );
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                          MainButton('Apply Filter', applyFilter),
                        ],
                      ),
                    );
                  }),
                );
              }),
          SizedBox(
            height: 20,
          ),
          FloatingActionButton(
              backgroundColor: Colors.white,
              child: SvgPicture.asset(
                'assets/Colored_Markers/refresh.svg',
              ),
              // a waiting time is needed to prevent spam, as it results in bugs and lag
              onPressed: () async {
                requests++;
                print(requests);
                await Future.delayed(Duration(seconds: requests * 1));
                if (requests >= 5) {
                  requests = 1;
                }
                setState(() {
                  fetchLocations();
                });
              })
        ],
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
              color: Colors.orange,
              size: 32,
            ),
          )),
          enableRotationByGesture: true,
        ),
      ),
      bottomNavigationBar: (canAddLocation)
          ? Container(
              padding: EdgeInsets.all(0),
              height: 92,
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        canAddLocation = false;
                        addLocation();
                      });
                    },
                    child: Container(
                      width: 72,
                      child: Column(
                        children: [
                          SvgPicture.asset('assets/sign_up/confirm.svg',
                              width: 48),
                          StyledText('Confirm', 'normal', 16),
                        ],
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        canAddLocation = false;
                      });
                    },
                    child: Container(
                      width: 72,
                      child: Column(
                        children: [
                          SvgPicture.asset(
                            'assets/Colored_Markers/cancel.svg',
                            width: 48,
                          ),
                          StyledText('Cancel', 'normal', 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          : (canShowDetails)
              ? Container(
                  height: 200,
                  child: Center(
                    child: ListView(
                      shrinkWrap: true,
                      padding: EdgeInsets.only(right: 10, left: 10, bottom: 10),
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              canShowDetails = false;
                            });
                          },
                          child: StyledText('Done', 'normal', 16),
                        ),
                        StyledText(roadName, 'bold', 24),
                        StyledText(
                            'Distance: ${distance.toInt()}m', 'normal', 16),
                        StyledText(
                            'Added by ${(contributor[0] == currentUser?.uid) ? 'you' : contributor[1]}',
                            'normal',
                            16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: (contributor[0] == currentUser?.uid)
                              ? [
                                  Container(
                                    margin: const EdgeInsets.only(top: 8),
                                    width: 200,
                                    height: 49,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: const Color.fromRGBO(
                                            55, 235, 115, 1)),
                                    child: TextButton(
                                      onPressed: removeLocation,
                                      child: StyledText(
                                          'Remove Location', 'bold', 16),
                                    ),
                                  ),
                                ]
                              : [
                                  Container(
                                    margin: const EdgeInsets.only(top: 8),
                                    width: 100,
                                    height: 49,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: const Color.fromRGBO(
                                            55, 235, 115, 1)),
                                    child: TextButton(
                                      onPressed: (canReport)
                                          ? () => reportLocation(true)
                                          : () => displayError(
                                              'Please go near the marker to report'),
                                      child: StyledText('Found', 'bold', 16),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 8),
                                    width: 100,
                                    height: 49,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: const Color.fromRGBO(
                                            55, 235, 115, 1)),
                                    child: TextButton(
                                      onPressed: (canReport)
                                          ? () => reportLocation(false)
                                          : () => displayError(
                                              'Please go near the marker to report'),
                                      child:
                                          StyledText('Not Found', 'bold', 16),
                                    ),
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
                      showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return SizedBox(
                              height: 120,
                              child: Row(children: [
                               SizedBox(
                                  width: 16,
                                ),
                                 SizedBox(
                                  child: Center(
                                      child: Text(
                                    'Find\nNearest\nBasket',
                                    style: TextStyle(
                                      fontSize: 25,
                                      height: 1,
                                      fontWeight: FontWeight.bold,
                                      color:  Color.fromRGBO(71, 71, 71, 1)
                                    ),
                                    textAlign: TextAlign.center
                                  )),
                                  width: 100,
                                  height: 100,
                                ),
                                Lottie.asset('assets/drawroad.json',
                                    width: 100),
                                SizedBox(width: 30,),
                                SizedBox(
                                  height: 50,
                                  width: 100,
                                  child: ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          find_nearest_button_pressed =
                                              !(find_nearest_button_pressed);
                                        });
                                        if (find_nearest_button_pressed) {
                                          findNearestLocation();
                                        } else {
                                          removeRoads();
                                        }
                                        Navigator.pop(context);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            find_nearest_button_pressed
                                                ? Colors.red
                                                : Colors.green,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20.0)),
                                        elevation: 0.0,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: Text(
                                        find_nearest_button_pressed
                                            ? 'Finish'
                                            : 'Start',
                                        style: TextStyle(
                                          fontSize: 19,
                                        ),
                                      )),
                                ),
                              ]),
                            );
                          });
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
