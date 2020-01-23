import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';

import 'package:quiver/strings.dart';

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
      'sdffds dsffds',
      "CHANNLE NAME",
      "channelDescription",
    );
    var iOS = new IOSNotificationDetails();
    var platform = new NotificationDetails(android, iOS);
    await flutterLocalNotificationsPlugin.show(
        0, "This is title", "this is notification demo", platform,
        payload: msg['msg']);
  }

  Future onSelectNotification(String payload) async {
    debugPrint("payload : $payload");
    showDialog(
      context: context,
      builder: (_) {
        return new AlertDialog(
          title: Text("Notification"),
          content: Text("Payload : $payload"),
        );
      },
    );
  }

  Widget _showDialog() {
    showDialog(
      context: context,
      builder: (_) {
        return new AlertDialog(
          title: Text("Notification"),
          content: Text("Payload : Testing..."),
        );
      },
    );
  }

  showAlertDialog(BuildContext context) {

    // set up the button
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () { },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("My title"),
      content: Text("This is my message."),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
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

// TODO: getToken()
  final databaseReference = Firestore.instance;
  String token;

  getToken() {
    firebaseMessaging.getToken().then((fcm_token) {
      token = fcm_token;
      print("fcm_token = " + token);
      databaseReference.collection("fcm_token").document("1").setData({
        'fcm_token': token,
      });
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Push Notification'),
        ),
        body: new Center(
          child: new Column(
            children: <Widget>[
              if (false)
                new Text(
                  textValue,
                ),
              if (false)
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
              Row(
                children: <Widget>[
                  Expanded(
                    child: RaisedButton(
                      child: Text('Add Record'),
                      onPressed: () {
                        addData();
                      },
                    ),
                  ),
                  Expanded(
                    child: RaisedButton(
                      child: Text('Get Device Info'),
                      onPressed: () {
                        getDeviceInfo();
                      },
                    ),
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
                    child: RaisedButton(
                      child: Text('Notify'),
                      onPressed: () {
                        showNotification({
                          'msg':
                              'Just testing flutter local notification plugin'
                        });
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
              Row(children: <Widget>[
                Expanded(
                  child: RaisedButton(
                    child: Text('Add My License Plate Number'),
                    onPressed: () {
                      addMyData();
                    },
                  ),
                ),
                Expanded(
                  child: RaisedButton(
                    child: Text('Contact Owner'),
                    onPressed: () async {
                      await contactOwner(myController.text);
                    },
                  ),
                ),
                Expanded(
                  child: RaisedButton(
                    child: Text('show Dialog'),
                    onPressed: () async {
                      await showAlertDialog(context);
                    },
                  ),
                ),
              ]),
              Center(
                child: Text(_homeScreenText),
              ),
            ],
          ),
        ),

    );
  }

  void createRecord() async {
    await databaseReference
        .collection("fcm_token")
        .document("1")
        .setData({'fcm_token': token, 'license-plate': 'ABCD1234Z'});

    await databaseReference.collection("books").document("1").setData({
      'title': 'Mastering Flutter',
      'description': 'Programming Guide for Dart'
    });

    DocumentReference ref = await databaseReference.collection("books").add({
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
      databaseReference.collection('books').document('1').delete();
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

// from onpressed callbacks are async?
  void addData() async {
    try {
//      databaseReference
//          .collection('fcm_token').add({"textInput":myController.text});
      databaseReference
          .collection('fcm_token')
          .document(fcmtoken)
          .setData({"license_plate": myController.text}, merge: true);
      await databaseReference
          .collection('fcm_token')
          .document(fcmtoken)
          .setData({"device_info": await _getDeviceInfo()}, merge: true);
      databaseReference.collection('fcm_token').document(fcmtoken).setData(
          {"timestamp": DateTime.now().millisecondsSinceEpoch},
          merge: true);
      await databaseReference
          .collection('fcm_token')
          .document(fcmtoken)
          .setData({"fcm_token": await fcmtoken}, merge: true);
      databaseReference
          .collection('fcm_token')
          .document(fcmtoken)
          .collection('message')
          .document('8Cc0R4m4aROYaOF9GrQo')
          .setData({"license_plate": myController.text}, merge: true);
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

  Future<void> printSomething() {
    print("await print");
    return Future.delayed(Duration(seconds: 3), () => print('Large Latte'));
  }

  contactOwner(String licensePlate) async {
//    if(licensePlate.isEmpty || licensePlate == null) { print('please enter text'); return;}
    if (isEmpty(licensePlate)) {
      print('please enter text');
      return;
    }

    var fcmTokenExist = true;
    print("pre:" + licensePlate ?? "XYZ9876W");
    var snapshots = await getDocument2(licensePlate);
    snapshots.documents.forEach((f) {
      print('doc is ${f["fcm_token"]}');
//      print('doc is ${f["school"]}');
      print('doc is ${f["license_plate"]}');

      print('docID is ${f.documentID}');
      databaseReference
          .collection('fcm_token')
          .document(f.documentID)
          .get()
          .then((DocumentSnapshot ds) {
//        print("something" + ds['school'] + ds.documentID);
        print("something" + ds['license_plate'] + ds.documentID);
        print(ds.data);
      });
      // how to set data?
      databaseReference
          .collection('fcm_token')
          .document(f.documentID)
          .setData({"year": "2021"}, merge: true);
      databaseReference
          .collection('fcm_token')
          .document(f.documentID)
          .updateData({
        "time_stamp": DateTime.now().millisecondsSinceEpoch
      }).catchError((e) {
        print(e);
      });
    });
    await printSomething();

    if (fcmTokenExist && false) {
      print('set timestamp');
      databaseReference
          .collection('fcm_token')
          .document(fcmTokenLocal)
          .updateData({
        "time_stamp": DateTime.now().millisecondsSinceEpoch
      }).catchError((e) {
        print(e);
      });
    }
    print(' after await fcmtokenlocal: $fcmTokenLocal');
  }

  Future<QuerySnapshot> getDocument2(String licensePlate) async {
    return databaseReference
        .collection("fcm_token")
//        .where("school", isEqualTo: "Westwood")
        .where("license_plate", isEqualTo: licensePlate)
        .getDocuments();
//        .then((QuerySnapshot snapshot){
//        print(snapshot.documents);
    //        docs = snapshot;
//    });
  }

  // TODO: Contact car owner usng cloud firestore trigger. automatically add time stamp
  contactOwner2(String licensePlate) async {
//    String owner2;
//    var docs;

//
    var fcmTokenExist = true;
    print("pre:" + licensePlate ?? "XYZ9876W");
    var testvar;

    await databaseReference
        .collection("fcm_token")
        .where("license_plate", isEqualTo: licensePlate)
        .snapshots()
        .listen((data) {
      print(testvar ?? "is null");
      testvar ??= "someval";
      print(testvar ?? "is null");

      fcmTokenLocal = data.documents[0]['fcm_token'] ?? "XYZ9876W";
      if (fcmTokenLocal != null) {
        print('during await fcmtokenlocal: $fcmTokenLocal');
        print('fcmToken exist');
      } else {
        fcmTokenExist = false;
        print('fcmToken does not exist');
      }
      print(licensePlate);
    });
    await printSomething();

    print(testvar);
    print("post:" + licensePlate);
    print(' before await fcmtokenlocal: $fcmTokenLocal');
    if (fcmTokenExist && false) {
      print('set timestamp');
      databaseReference
          .collection('fcm_token')
          .document(fcmTokenLocal)
          .updateData({
        "time_stamp": DateTime.now().millisecondsSinceEpoch
      }).catchError((e) {
        print(e);
      });
    }
    print(' after await fcmtokenlocal: $fcmTokenLocal');

//      databaseReference
//          .collection("fcm_token")
////          .where("license_plate", isEqualTo: licensePlate)
//          .getDocuments()
//          .then((QuerySnapshot snapshot){
////          print(snapshot.documents);
//        docs = snapshot;
//      });
//      print(docs.document[0]['fcm_token']);
//      print({docs.documents[0].data['fcm_token']});
//      print('Owner\'s fcm_token: ${docs.documents[0]['fcm_token']}');
//      owner2 = docs.documents[0]['fcm_token'];
//          print('during listen: ${owner2}');

//      print('Owner\'s fcm_token: ${data.documents[0]['time_stamp']}');
  }

//  databaseReference
//      .collection("fcm_token")
//      .where("license_plate", isEqualTo: licensePlate)
//      .snapshots()
//      .listen((data) {
//  print('Owner\'s fcm_token: ${data.documents[0]['fcm_token']}');
//  owner2 = data.documents[0]['fcm_token'];
//          data.documents[0].
//          databaseReference
//              .collection('fcm_token')
//              .document(data.documents[0]['fcm_token'])
//              .updateData({"time_stamp":DateTime.now().millisecondsSinceEpoch});
  // set trigger
//          data.documents;
  // documents ref?
//    print('after listen: ${owner2}');
//// how to retrieve all fields in a document?
//     Firestore.instance
//        .collection('fcm_token')
//        .where("license_plate", isEqualTo: licensePlate)
//        .snapshots()
//        .listen((data) =>
//        data.documents.forEach((doc) => print(doc["fcm_token"])));

  // TODO: Add my license plate. automatically add time stamp
  void addMyData() async {
    try {
//      databaseReference
//          .collection('fcm_token').add({"textInput":myController.text});
      databaseReference
          .collection('fcm_token')
          .document(fcmtoken)
          .setData({"license_plate": myController.text}, merge: true);
      await databaseReference
          .collection('fcm_token')
          .document(fcmtoken)
          .setData({"device_info": await _getDeviceInfo()}, merge: true);
      databaseReference.collection('fcm_token').document(fcmtoken).setData(
          {"timestamp": DateTime.now().millisecondsSinceEpoch},
          merge: true);
      await databaseReference
          .collection('fcm_token')
          .document(fcmtoken)
          .setData({"fcm_token": await fcmtoken}, merge: true);
      databaseReference
          .collection('fcm_token')
          .document(fcmtoken)
          .collection('message')
          .document('8Cc0R4m4aROYaOF9GrQo')
          .setData({"license_plate": myController.text}, merge: true);
    } catch (e) {
      print(e.toString());
    }
  }
}
