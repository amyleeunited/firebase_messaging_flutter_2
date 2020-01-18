/*// The Cloud Functions for Firebase SDK to create Cloud Functions and setup triggers.
const functions = require('firebase-functions');

// The Firebase Admin SDK to access the Firebase Realtime Database.
const admin = require('firebase-admin');
admin.initializeApp();

// Take the text parameter passed to this HTTP endpoint and insert it into the
// Realtime Database under the path /messages/:pushId/original
exports.addMessage = functions.https.onRequest(async (req, res) => {
  // Grab the text parameter.
  const original = req.query.text;
  // Push the new message into the Realtime Database using the Firebase Admin SDK.
  const snapshot = await admin.database().ref('/messages').push({original: original});
  // Redirect with 303 SEE OTHER to the URL of the pushed object in the Firebase console.
  res.redirect(303, snapshot.ref.toString());
});

// Listens for new messages added to /messages/:pushId/original and creates an
// uppercase version of the message to /messages/:pushId/uppercase
exports.makeUppercase = functions.database.ref('/messages/{pushId}/original')
    .onCreate((snapshot, context) => {
      // Grab the current value of what was written to the Realtime Database.
      const original = snapshot.val();
      console.log('Uppercasing', context.params.pushId, original);
      const uppercase = original.toUpperCase();
      // You must return a Promise when performing asynchronous tasks inside a Functions such as
      // writing to the Firebase Realtime Database.
      // Setting an "uppercase" sibling in the Realtime Database returns a Promise.
      return snapshot.ref.parent.child('uppercase').set(uppercase);
    });

    // Listen for changes in all documents in the 'users' collection and all subcollections
    exports.notifyOwner2 = functions.firestore
        .document('/fcm-token/{fcm-token}')
        .onWrite((change, context) => {
          // If we set `/users/marie/incoming_messages/134` to {body: "Hello"} then
          // context.params.userId == "marie";
          // context.params.messageCollectionId == "incoming_messages";
          // context.params.messageId == "134";
          // ... and ...
          // change.after.data() == {body: "Hello"}
          console.log('ok');
        });
        */

        const functions = require('firebase-functions');
        const admin = require('firebase-admin');
        admin.initializeApp(functions.config().firebase);

    exports.helloWorld2 = functions.firestore
        .document('fcm_token/{fcm_token}')
        .onWrite((change, context) => {
            console.log(change.after.data());
            const payload = change.after.data();

            return null;
        });


    exports.notifyOwner = functions.firestore
        .document('fcm_token/{fcm_token}/{subcollector}/{subdocument}')
        .onWrite((change, context) => {
            console.log(change.after.data());
            const notification = change.after.data();
            const owner = context.params.fcm_token;

            console.log(notification["slogan"]);
            console.log(context.params.subcollector);
            console.log(context.params.subdocument);
            console.log(owner);

                        const payload = {
                            notification:{title:"Will this  work?", body:notification["slogan"], data: "must be string too"},
                        };

//            owner='e8iKEom59bY:APA91bGyf2JGPtvPo-7nylkNcOkiRHWr22XgVMRkpEXHljgsUua4Wn5oWX7Vb6p5HCKQ_XIaQsmo-xWQe3KUw8TwXbyxyzsHZVraY1lYq5Zp8JHzS1FJZnKvgoVrgOPhEs0o61ZTXwDN';
            return admin.messaging().sendToDevice(owner,payload);
            return admin.database().ref('fcm_token').once('value').then(allToken => {
                if(allToken.val()){
                    console.log('token available');
                    const token = Object.keys(allToken.val());
                    return admin.messaging().sendToDevice(token,payload);
                }else{
                    console.log('No token available');
                }
            });

        });

        exports.addMessage = functions.https.onRequest(async (req, res) => {
          // Grab the text parameter.
          const original = req.query.text;
          // Push the new message into the Realtime Database using the Firebase Admin SDK.
          const snapshot = await admin.database().ref('/messages').push({original: original});
          // Redirect with 303 SEE OTHER to the URL of the pushed object in the Firebase console.
          res.redirect(303, snapshot.ref.toString());
        });

        // Listens for new messages added to /messages/:pushId/original and creates an
        // uppercase version of the message to /messages/:pushId/uppercase
        exports.makeUppercase = functions.database.ref('/messages/{pushId}/original')
            .onCreate((snapshot, context) => {
              // Grab the current value of what was written to the Realtime Database.
              const original = snapshot.val();
              console.log('Uppercasing', context.params.pushId, original);
              const uppercase = original.toUpperCase();
              // You must return a Promise when performing asynchronous tasks inside a Functions such as
              // writing to the Firebase Realtime Database.
              // Setting an "uppercase" sibling in the Realtime Database returns a Promise.
              return snapshot.ref.parent.child('uppercase').set(uppercase);
            });
//        exports.helloWorld2 = functions.database.ref('notification/{id}').onWrite(evt => {
//            const payload = {
//                notification:{
//                    title : 'Message from Cloud',
//                    body : 'This is your body',
//                    badge : '1',
//                    sound : 'default'
//                }
//            };
//
//            return admin.database().ref('fcm-token').once('value').then(allToken => {
//                if(allToken.val()){
//                    console.log('token available');
//                                   const token = Object.keys(allToken.val());
//                                   return admin.messaging().sendToDevice(token,payload);
//                               }else{
//                                   console.log('No token available');
//                               }
//                           });
//        });