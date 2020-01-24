import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';

import 'package:quiver/strings.dart';
import 'package:fluttertoast/fluttertoast.dart';

//void main() => runApp(new MyApp());
void main() => runApp(new MaterialApp(home: new MyApp()));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String textValue = 'Hello World !';
  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();
  final myController = TextEditingController();
  String _homeScreenText = "Waiting for token...";
  String fcmtoken;
  String fcmTokenLocal;

// TODO: getToken()
  final databaseReference = Firestore.instance;
  String token;

  bool _hover = false;

  @override
  void initState() {
    super.initState();

    var android = new AndroidInitializationSettings('mipmap/ic_launcher');
    var ios = new IOSInitializationSettings();
    var platform = new InitializationSettings(android, ios);
    flutterLocalNotificationsPlugin.initialize(platform,
        onSelectNotification: onSelectNotification);

    firebaseMessaging.configure(
      onLaunch: (Map<String, dynamic> msg) {
        print(" onLaunch called ${(msg)}");
      },
      onResume: (Map<String, dynamic> msg) {
        print(" onResume called ${(msg)}");
      },
      onMessage: (Map<String, dynamic> msg) {
        showNotification(msg);
        print(" onMessage called ${(msg)}");
      },
    );
    firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, alert: true, badge: true));
    firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings setting) {
      print('IOS Setting Registed');
    });
    firebaseMessaging.getToken().then((token) {
      update(token);
    });

    firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      setState(() {
        _homeScreenText = "Push Messaging token: $token";
      });
      print(_homeScreenText);
      fcmtoken = token;
    });
  }

  showNotification(Map<String, dynamic> msg) async {
    var android = new AndroidNotificationDetails(
        'channel id', 'channel NAME', 'CHANNEL DESCRIPTION',
        priority: Priority.High, importance: Importance.Max);
    var iOS = new IOSNotificationDetails();
    var platform = new NotificationDetails(android, iOS);
    await flutterLocalNotificationsPlugin.show(
        0, 'No Tow', 'Please move your car', platform,
        payload: msg['notification']['body']);
    print('msg is: ' + msg.toString());
  }

  Future onSelectNotification(String payload) async {
    debugPrint("payload : $payload");
    showDialog(
      context: context,
      builder: (_) {
        return new AlertDialog(
          title: Text("Notification"),
          content: Text("Payload : $payload"),
          actions: <Widget>[
            FlatButton(
              child: Text("OK"),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      },
    );
  }

  update(String token) {
    print(token);
    DatabaseReference databaseReference = new FirebaseDatabase().reference();
    databaseReference.child('fcm_token/${token}').set({"token": token});
    textValue = token;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('No Tow'),
      ),
      body: new Center(
        child: new Column(
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Row(
              children: <Widget>[
                if (false)
                  Expanded(
                    child: RaisedButton(
                      child: Text('Get Owner'),
                      onPressed: () {
                        getOwner();
                      },
                    ),
                  ),
              ],
            ),
            Container(
              child: TextField(
                controller: myController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'License Plate',
                ),
              ),
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  RaisedButton(
                    child: Text('Add/Edit License Plate Number'),
                    onPressed: () {
                      createData();
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _hover = true;
                      });
                    },
                    child: RaisedButton(
                      color: _hover? Colors.red: Colors.limeAccent,
                      child: Text('Contact Owner'),
                      onPressed: () async {
                        await contactOwner(myController.text);
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      hoverColor: Colors.red,
                    ),
                  ),
                ]),
            if (false)
              Center(
                child: Text(_homeScreenText),
              ),
            if (false)
              new Padding(
                padding: const EdgeInsets.all(10.0),
                child: new RaisedButton(
                    child: new Text('Show Short Toast'),
                    onPressed: showShortToast),
              ),
            if (false)
              new Padding(
                padding: const EdgeInsets.all(10.0),
                child: new RaisedButton(
                    child: new Text('Show Top Short Toast'),
                    onPressed: showTopShortToast),
              ),
          ],
        ),
      ),
    );
  }

  getDeviceInfo() async {
    String deviceId = await _getDeviceInfo();
//    print('deviceId is ${deviceId})';
    print(deviceId);
    return deviceId;
  }

  Future<String> _getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Theme.of(context).platform == TargetPlatform.android) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      print('Running on ${androidInfo.model}'); // e.g. "Moto G (4)"
      return androidInfo.androidId;
    } else {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      print('Running on ${iosInfo.utsname.machine}'); // e.g. "iPod7,1"
      return iosInfo.identifierForVendor;
    }
  }

  void getOwner() {
    databaseReference
        .collection("fcm_token")
        .where("license_plate", isEqualTo: myController.text)
        .snapshots()
        .listen((data) => print('Owner: ${data.documents[0]['device_info']}'));
  }

  contactOwner(String licensePlate) async {
//    if(licensePlate.isEmpty || licensePlate == null) { print('please enter text'); return;}
    if (isEmpty(licensePlate)) {
      print('please enter text');
      return;
    }

    const msg = {
      "available": "The owner for licensePlate has been notified.",
      "not available": "The owner for licensePlate is not registered here.",
    };
    databaseReference
        .collection("fcm_token")
        .where("license_plate", isEqualTo: licensePlate)
        .getDocuments()
        .then((QuerySnapshot snapshots) {
      if (snapshots.documents.isNotEmpty) {
        showOwnerContactStatusToast(
            licensePlate, "The owner for ${licensePlate} has been notified.");
        snapshots.documents.forEach((f) {
          databaseReference
              .collection('fcm_token')
              .document(f.documentID)
              .get()
              .then((DocumentSnapshot ds) {
            //        print(ds.documentID);
            print(ds.data);
          });
          // how to set data?

          databaseReference
              .collection('fcm_token')
              .document(f.documentID)
              .updateData({
            "time_stamp": DateTime.now().millisecondsSinceEpoch,
            "state": "notify",
          }).catchError((e) {
            print(e);
          });
        });
      } else {
        print(snapshots.documents.isEmpty);
        showOwnerContactStatusToast(licensePlate,
            "The owner for ${licensePlate} is not registered here.");
      }
    });
  }

  void showOwnerContactStatusToast(String licensePlate, String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  // TODO: Add my license plate. automatically add time stamp
  void createData() async {
    try {
      var licensePlate = myController.text;
      var data = {
        "fcm_token": await fcmtoken,
        "license_plate": licensePlate,
        "device_info": await _getDeviceInfo(),
        "time_stamp": DateTime.now().millisecondsSinceEpoch,
        "msg": "move it",
        "state": "create",
      };
      await databaseReference
          .collection('fcm_token')
          .document(fcmtoken)
          .setData(data, merge: true);

      Fluttertoast.showToast(
          msg: "Added/Edited License Plate number ${licensePlate}",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
//      databaseReference
//          .collection('fcm_token')
//          .document(fcmtoken)
//          .collection('message')
//          .document('8Cc0R4m4aROYaOF9GrQo')
//          .setData({"license_plate": myController.text}, merge: true);
    } catch (e) {
      print(e.toString());
    }
  }

  void showShortToast() {
    Fluttertoast.showToast(
        msg: "This is Short Toast",
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIos: 1);
  }

  void showTopShortToast() {
    Fluttertoast.showToast(
        msg: "This is Top Short Toast",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIos: 1);
  }
}
