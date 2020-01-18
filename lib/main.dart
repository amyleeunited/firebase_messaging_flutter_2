import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';

void main() => runApp(new MyApp());

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

  @override
  void initState() {
    super.initState();

    var android = new AndroidInitializationSettings('mipmap/ic_launcher');
    var ios = new IOSInitializationSettings();
    var platform = new InitializationSettings(android, ios);
    flutterLocalNotificationsPlugin.initialize(platform);

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
      'sdffds dsffds',
      "CHANNLE NAME",
      "channelDescription",
    );
    var iOS = new IOSNotificationDetails();
    var platform = new NotificationDetails(android, iOS);
    await flutterLocalNotificationsPlugin.show(
        0, "This is title", "this is demo", platform);
  }

  update(String token) {
    print(token);
    DatabaseReference databaseReference = new FirebaseDatabase().reference();
    databaseReference.child('fcm_token/${token}').set({"token": token});
    textValue = token;
    setState(() {});
  }
// TODO: getToken()
  final databaseReference = Firestore.instance;
  String token;

  getToken(){
    firebaseMessaging.getToken().then((fcm_token) {
      token = fcm_token;
      print("fcm_token = " + token);
      databaseReference.collection("fcm_token")
          .document("1")
          .setData({
        'fcm_token': token,
      });
    });

    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Push Notification'),
        ),
        body: new Center(
          child: new Column(
            children: <Widget>[
              new Text(
                textValue,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: RaisedButton(
                      child: Text('Create Record'),
                      onPressed: () {
                        createRecord();
                        getToken();
                      },
                    ),
                  ),
                  Expanded(
                    child: RaisedButton(
                      child: Text('View Record'),
                      onPressed: () {
                        getData();
                      },
                    ),
                  ),
                  Expanded(
                    child: RaisedButton(
                      child: Text('Update Record'),
                      onPressed: () {
                        updateData();
                      },
                    ),
                  ),
                  Expanded(
                    child: RaisedButton(
                      child: Text('Delete Record'),
                      onPressed: () {
                        deleteData();
                      },
                    ),
                  ),
                ],
              ),
              RaisedButton(
                child: Text('Add Record'),
                onPressed: () {
                  addData();
                },
              ),
              RaisedButton(
                child: Text('Get Device Info'),
                onPressed: () {
                  getDeviceInfo();
                },
              ),
              Expanded(
                child: RaisedButton(
                  child: Text('Get Owner'),
                  onPressed: () {
                    getOwner();
                  },
                ),
              ),
              Expanded(
                child: TextField(
                  controller: myController,
                ),
              ),
              Center(
                child: Text(_homeScreenText),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void createRecord() async {

    await databaseReference.collection("fcm_token")
        .document("1")
        .setData({
      'fcm_token': token,
      'license-plate': 'ABCD1234Z'
    });

    await databaseReference.collection("books")
        .document("1")
        .setData({
      'title': 'Mastering Flutter',
      'description': 'Programming Guide for Dart'
    });

    DocumentReference ref = await databaseReference.collection("books")
        .add({
      'title': 'Flutter in Action',
      'description': 'Complete Programming Guide to learn Flutter'
    });
    print(ref.documentID);
  }

  void getData() {
    databaseReference
        .collection("books")
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((f) => print('${f.data}}'));
    });
  }

  void updateData() {
    try {
      databaseReference
          .collection('books')
          .document('1')
          .updateData({'description': 'Head First Flutter'});
    } catch (e) {
      print(e.toString());
    }
  }

  void deleteData() {
    try {
      databaseReference
          .collection('books')
          .document('1')
          .delete();
    } catch (e) {
      print(e.toString());
    }
  }

  getDeviceInfo() async {
    String deviceId = await _getDeviceInfo();
//    print('deviceId is ${deviceId})';
  print(deviceId);
  return deviceId;
  }

  Future<String> _getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Theme.of(context).platform  == TargetPlatform.android) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      print('Running on ${androidInfo.model}'); // e.g. "Moto G (4)"
      return androidInfo.androidId;
    } else {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      print('Running on ${iosInfo.utsname.machine}'); // e.g. "iPod7,1"
      return iosInfo.identifierForVendor;
    }
  }
// from onpressed callbacks are async?
  void addData() async {
    try {
//      databaseReference
//          .collection('fcm_token').add({"textInput":myController.text});
      databaseReference
          .collection('fcm_token').document(fcmtoken).setData({"license_plate":myController.text},merge: true);
      await databaseReference
          .collection('fcm_token').document(fcmtoken).setData({"device_info":await _getDeviceInfo()},merge: true);
      databaseReference
          .collection('fcm_token').document(fcmtoken).setData({"timestamp": DateTime.now().millisecondsSinceEpoch},merge: true);
      await databaseReference
          .collection('fcm_token').document(fcmtoken).setData({"fcm_token":await fcmtoken},merge: true);
      databaseReference
          .collection('fcm_token').document(fcmtoken).collection('message').document('8Cc0R4m4aROYaOF9GrQo').setData({"license_plate":myController.text},merge: true);
    } catch (e) {
      print(e.toString());
    }
  }

  void getOwner() {
    databaseReference
        .collection("fcm_token")
        .where("license_plate", isEqualTo: myController.text)
        .snapshots()
        .listen((data) => print('Owner: ${data.documents[0]['device_info']}'));
      }
}
