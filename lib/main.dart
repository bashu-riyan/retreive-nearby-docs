import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nearbyloc/nearDocs.dart';
import 'package:units_converter/units_converter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: NearbyLocation(),
    );
  }
}

class NearbyLocation extends StatelessWidget {
  NearbyLocation({Key? key}) : super(key: key);

  final geo = GeoFlutterFire();
  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    // Create a geoFirePoint
    GeoFirePoint center =
        geo.point(latitude: 17.6187362, longitude: 77.9494144);
// get the collection reference or query
    var collectionReference = _firestore.collection('locations');
    double radius = 1;
    String field = 'position';

    Stream<List<DocumentSnapshot>> streamOfNearby = geo
        .collection(collectionRef: collectionReference)
        .within(center: center, radius: radius, field: field);
    return Scaffold(
      appBar: AppBar(
        title: Text('Nearby Documents'),
      ),
      body: SafeArea(
        child: StreamBuilder<List<DocumentSnapshot>>(
            stream: streamOfNearby,
            builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
              if (!snapshot.hasData) {
                return Container(
                  child: Text('No data'),
                );
              }
              return Container(
                child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: ((context, index) {
                      DocumentSnapshot data = snapshot.data![index];
                      GeoPoint documentLocation =
                          data.get('position')['geopoint'];
                      var distanceInMeters = Geolocator.distanceBetween(
                          center.latitude,
                          center.longitude,
                          documentLocation.latitude,
                          documentLocation.longitude);
                      return ListTile(
                        title: Text('${data.get('name')}'),
                        subtitle: Text('${distanceInMeters.convertFromTo(LENGTH.meters, LENGTH.kilometers)!.toStringAsFixed(2)} KM'),
                      );
                    })),
              );
            }),
      ),
    );
  }
}

          // try {
          //         GeoFirePoint myLocation =
          //             geo.point(latitude: 12.960632, longitude: 77.641603);
          //         await _firestore.collection('locations').add(
          //             {'name': 'random name', 'position': myLocation.data});
          //       } catch (e) {
          //         print(e);
          //       }