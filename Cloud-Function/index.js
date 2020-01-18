const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);

exports.helloWorld = functions.database.ref('notification/{id}').onWrite(evt => {
    const payload = {
        notification:{
            title : 'Message from Cloud',
            body : 'This is your body',
            badge : '1',
            sound : 'default'
        }
    };

    return admin.database().ref('fcm-token').once('value').then(allToken => {
        if(allToken.val()){
            console.log('token available');
            const token = Object.keys(allToken.val());
            return admin.messaging().sendToDevice(token,payload);
        }else{
            console.log('No token available');
        }
    });
});
// get update and token
exports.notifyOwner = functions.firestore.document('/fcm-token/{fcm-token}').onWrite((change, context) => {
  const beforeData = change.before.val();
  const afterData = change.after.val();

  let id = context.params["fcm-token"]
  console.log(afterData);
  console.log(id);

//  const payload = {
//      notification: {
//        messsage : 'No Tow',
//        timestamp : afterData,
//      }
//  };

  // get fcm-token
//  admin.firestore.document('/fcm-token/');
//  return admin.messaging().sendToDevice(token, payload);
});