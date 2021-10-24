# Echo

Echo is an iOS application that takes an image of your surroundings and echoes back (audibly reads out) the objects that are included in the image. It aids visually impaired individuals by informing them of their surroundings. The UI of the application is a camera with shutter audio when the user captures images.

## What inspired us?

There are approximately 6.6 million people in the United States who are visually impaired and 1.3 million people who are legally blind (US EEOC 2014). Although accommodations exist for the visually impaired, a lot of the available technology is either incomprehensive or inaccessible for certain demographics. 

As the world progresses with technology, so too can applications that aid the physically disabled. Visual detection software on mobile devices can provide a cheap and accessible aid that helps the blind/severely impaired effectively navigate and understand their surroundings.

## How we built it?

The logo was made using Figma. We built the app as a Flutter application with a serverless Firebase backend, implemented in conjunction with the Google Cloud APIs Cloud Vision and Cloud Text-to-Speech. Images taken with Echo are sent to the Google Cloud Vision API, and the resulting JSON objects are then parsed by a Firebase cloud function into a single string that is transformed into an mp3 file by the Google Cloud Text-to-Speech API. Then, the audio is read to the user by the Flutter application. 
