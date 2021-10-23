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
    const vision_client = new vision.ImageAnnotatorClient();

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
        console.log(vision_client.annotateImage(JSON.parse(JSON.stringify(data))));
    } catch (e) {
        throw new functions.https.HttpsError("internal", e.message, e.details);
    }
    // Taking the image and feed it into VISION API

    // Get json string from vision API

    // Parse json string to text-to-audio format

    // text to speech outputs mp3

    // The text to synthesize
    const client = new textToSpeech.TextToSpeechClient();

    const text = "temp"//parsed json string;
    const request = {
        input: {text: text},
        voice: {languageCode: 'en-US', ssmlGender: 'NEUTRAL'},
        audioConfig: {audioEncoding: 'MP3'},
    };

    // Performs the text-to-speech request
    async function parseAudio() {
        const [response] = await client.synthesizeSpeech(request);
        // Write the binary audio content to a local file
        const writeFile = util.promisify(fs.writeFile);
        await writeFile('output.mp3', response.audioContent, 'binary');
        console.log('Audio content written to file: output.mp3');
    }
    parseAudio();
    // flutter reads mp3
});