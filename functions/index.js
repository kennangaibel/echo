// The Cloud Functions for Firebase SDK to create Cloud Functions and set up triggers.
const functions = require('firebase-functions');
// The Firebase Admin SDK to access Firestore.
const admin = require('firebase-admin');
admin.initializeApp();

const fs = require('fs');
const util = require('util');
const textToSpeech = require('@google-cloud/text-to-speech');

// any time storage is updated this function will run
exports.analyzeImage = functions.storage.object().onFinalize(async (object) => {
    // Taking the image and feed it into VISION API

    // Get json string from vision API

    // Parse json string to text-to-audio format

    // text to speech outputs mp3
    const client = new textToSpeech.TextToSpeechClient();
    async function quickStart() {
        // The text to synthesize
        const text = "temp"//parsed json string;
        const request = {
            input: {text: text},
            voice: {languageCode: 'en-US', ssmlGender: 'NEUTRAL'},
            audioConfig: {audioEncoding: 'MP3'},
        };

        // Performs the text-to-speech request
        const [response] = await client.synthesizeSpeech(request);
        // Write the binary audio content to a local file
        const writeFile = util.promisify(fs.writeFile);
        await writeFile('output.mp3', response.audioContent, 'binary');
        console.log('Audio content written to file: output.mp3');
    }
    quickStart();

    // flutter reads mp3
});