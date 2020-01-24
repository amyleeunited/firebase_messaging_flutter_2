    const functions = require('firebase-functions');
    const admin = require('firebase-admin');
    admin.initializeApp(functions.config().firebase);

    exports.notifyOwner = functions.firestore
        .document('fcm_token/{fcm_token}')
        .onWrite((change, context) => {
            const notification = change.after.data();
            const fcm_token = context.params.fcm_token;
            console.log(notification);
            console.log(fcm_token);

                        const payload = {
                            notification:{title:"Will this  work?", body:notification['msg'], data: "must be string too"},
                        };

            const beforeChange = change.before.data();
            const afterChange = change.after.data();

            if (afterChange['state'] === "notify") { return admin.messaging().sendToDevice(fcm_token,payload);}
            if (afterChange['state'] === "create") {console.log("create"); return null;};
            if (false) return admin.database().ref('fcm_token').once('value').then(allToken => {
                if(allToken.val()){
                    console.log('token available');
                    const token = Object.keys(allToken.val());
                    return admin.messaging().sendToDevice(token,payload);
                }else{
                    console.log('No token available');
                }
            });

        });
