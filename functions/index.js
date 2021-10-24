// The Cloud Functions for Firebase SDK to create Cloud Functions and set up triggers.
const functions = require('firebase-functions');
// The Firebase Admin SDK to access Firestore.
const admin = require('firebase-admin');
admin.initializeApp();

const fs = require('fs');
const util = require('util');
const vision = require('@google-cloud/vision');
const textToSpeech = require('@google-cloud/text-to-speech');

// any time storage is updated this function will run
exports.visionAnalysis = functions.storage.object().onFinalize(async (object) => {
    const vision_client = new vision.ImageAnnotatorClient();
// Taking the image and feed it into VISION API

    // Get json string from vision API

    let response;

    try {
        const request = {
            image: {
                source: { imageUri: `gs://${object.bucket}/${object.name}` },
            },
            features:[
                {
                    type: "LABEL_DETECTION",
                    maxResults: 5
                }
            ]
        };
        response = await vision_client.annotateImage(request);
        functions.logger.log(response[0].labelAnnotations);
    } catch (e) {
        throw new functions.https.HttpsError("internal", e.message, e.details);
    }

    // Parse json string to text-to-audio format
    
    // Vision API will send a json stringy
    // Iterate through json Object

    // extract object.name
    // json will be the array of JSON_objects Nithin returns
    // let json = response.labelAnnotations; // output from Nithin here;

    // json string becomes an object through parsing
    // let obj = JSON.parse(json);
    
    // Array where names of identified objects will be stored
    let nameArray = [];
    // Need to figure out name of jsonArray and how to number through the different objects
    for (let i = 0; i < response.length; i++) {
        response[i].labelAnnotations.forEach(element => {
            functions.logger.log(element.description);
            nameArray.push(element.description);
        });
    }

    // string that'll be sent to the text-to-speech
    let speechText = "There is a ";
    for (let i = 0; i < nameArray.length - 1; i++) {
        speechText += nameArray[i] + ", ";
    }
    speechText += ", and " + nameArray[nameArray.length - 1] + ".";

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
        const {Storage} = require("@google-cloud/storage");
        const [response] = await client.synthesizeSpeech(request);
        const os = require('os');
        const path = require('path');
        const outputPath = path.join(os.tmpdir(), 'output.mp3');
        functions.logger.log(outputPath);
        // Write the binary audio content to a local file
        const writeFile = util.promisify(fs.writeFile);
        await writeFile(outputPath, response.audioContent);
        functions.logger.log(outputPath);

        const storage = new Storage();
        const bucket = storage.bucket('echo-11de8.appspot.com');
        const metadata = {
            contentType: 'audio/mpeg'
        }
        const options = {
            destination: 'sound/output.mp3',
            metadata: metadata
        };
        bucket.upload(outputPath, options).then(function(data) {
            const file = data[0];
        });
    }
    await parseAudio();

    // flutter reads mp3
});