import 'package:capicoopcomercial/googlemap.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fluttertoast/fluttertoast.dart';

Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      print("location denied");
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    print("location denied");
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  return await Geolocator.getCurrentPosition();
}

class Homepage extends StatefulWidget {
  Homepage({Key key}) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  Position position;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference users = FirebaseFirestore.instance.collection('Users');

  TextEditingController username = TextEditingController(),
      salonname = TextEditingController(),
      email = TextEditingController(),
      phonnumber = TextEditingController();
  @override
  void initState() {
    _determinePosition().then((value) => position = value);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Container(
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            TextFormField(
              controller: username,
              decoration: const InputDecoration(
                labelText: 'nom d etulisateur ',
              ),
              validator: (String value) {
                if (value.toString().trim().isEmpty) {
                  return 'username is required';
                }
              },
            ),
            TextFormField(
              controller: salonname,
              decoration: const InputDecoration(
                labelText: 'nom du salon',
              ),
              validator: (String value) {
                if (value.toString().trim().isEmpty) {
                  return 'nom du salon is required';
                }
              },
            ),
            TextFormField(
              keyboardType: TextInputType.emailAddress,
              controller: email,
              decoration: const InputDecoration(
                labelText: 'email',
              ),
              validator: (String value) {},
            ),
            TextFormField(
              controller: phonnumber,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'numero telephon',
              ),
              validator: (String value) {
                if (value.toString().trim().isEmpty) {
                  return 'numero telephon is required';
                }
              },
            ),
            ElevatedButton(
                onPressed: () {
                  setState(() {});
                },
                child: Text("refresh")),
            Row(
              children: [
                Text("latitude : " +
                    (position != null ? position.latitude.toString() : "")),
                Text("longitude : " +
                    (position != null ? position.longitude.toString() : ""))
              ],
            ),
            Expanded(
              child: Container(
                child: Googlemaps(),
              ),
            ),
            ElevatedButton(
                onPressed: () async {
                  if (salonname.text.isNotEmpty &&
                      username.text.isNotEmpty &&
                      phonnumber.text.isNotEmpty &&
                      position != null) {
                    await users.add({
                      'username': username.text,
                      'salon': salonname.text,
                      'email': email.text,
                      'phone': phonnumber.text,
                      'latitud': position.latitude.toString(),
                      'longtitude': position.longitude
                    }).whenComplete(() {
                      username.text = "";
                      salonname.text = "";
                      email.text = "";
                      phonnumber.text = "";
                    });
                  } else {
                    Fluttertoast.showToast(
                        msg: "fneed more details",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0);
                  }
                },
                child: Text("Add"))
          ],
        ),
      ),
    ));
  }
}
