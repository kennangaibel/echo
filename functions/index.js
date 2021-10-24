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
// Taking the image and feed it into VISION API

    // Get json string from vision API
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

    // Parse json string to text-to-audio format
    
    // Vision API will send a json string
    // Iterate through json Object

    // extract object.name
    // json will be the array of JSON_objects Nithin returns
    let json; // output from Nithin here;

    // json string becomes an object through parsing
    let obj = JSON.parse(json);
    
    // Array where names of identified objects will be stored
    var nameArray = [];
    // Need to figure out name of jsonArray and how to number through the different objects
    for (var i = 0; i < jsonArray.length; i++) {
        // unsure if it should be obj.labelAnnotations.description
        nameArray.push(obj[i].description);
    }

    // string that'll be sent to the text-to-speech
    let speechText = "";
    for (let i = 0; i < nameArray.length; i++) {
        speechText = "There is a " + nameArray[i] + " ";
    }

    // create string result

    // Result needs to be some thing like "this is a [1,2,3,4...]"

    // text to speech outputs mp3
    // The text to synthesize
    const client = new textToSpeech.TextToSpeechClient();
    const request = {
        input: {text: speechText},
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
    // Need to get the mp3 file thats parsed into the firebase storage


    
    // flutter reads mp3
});