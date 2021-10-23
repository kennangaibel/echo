// The Cloud Functions for Firebase SDK to create Cloud Functions and set up triggers.
const functions = require('firebase-functions');
const vision = require('@google-cloud/vision');
// The Firebase Admin SDK to access Firestore.
const admin = require('firebase-admin');
admin.initializeApp();

const fs = require('fs');
const util = require('util');

const textToSpeech = require('@google-cloud/text-to-speech');

// any time storage is updated this function will run
exports.analyzeImage = functions.storage.object().onFinalize(async (object) => {
    const client = new vision.ImageAnnotatorClient();

    let data = {
        "requests": [
            {
                "image": {
                    "source": {
                        "imageUri": object.name
                    }
                },
                "features":[
                    {
                        "type": "LABEL_DETECTION",
                        "maxResults": 1
                    }
                ]
            }
        ]
    }

    try {
        console.log(client.annotateImage(JSON.parse(JSON.stringify(data))));
    } catch (e) {
        throw new functions.https.HttpsError("internal", e.message, e.details);
    }
    // Taking the image and feed it into VISION API

    // Get json string from vision API

    // Parse json string to text-to-audio format

    // text to speech reads inputted value,

    // text to speech outputs mp3

    // flutter reads mp3

    // convert JSON string to audio (mp3)
});

