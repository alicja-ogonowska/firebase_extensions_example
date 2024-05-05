# Firebase Extensions Example

A simple Flutter app showing the possible usage of Firebase Extensions.

## Getting Started
To run this app, you need to:
1. Create app in Firebase
2. Authenticate to Firebase on your machine
2. Activate Flutterfire CLI on your machine
3. Configure it to use the Firebase project you already created , enable the platforms of your choice (I was using Android, iOS and web).

>     curl -sL https://firebase.tools | bash
>
>     firebase login
>     dart pub global activate flutterfire_cli
>
>     flutterfire configure

4. In Firebase console, enable Authentication (anonymous authentication),
Cloud Firestore (don't forget about security rules!) and Storage.