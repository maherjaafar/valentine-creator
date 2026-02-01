# Valentine Invite 💖

A playful and interactive web app to create and share custom Valentine's Day invitations with a sweet surprise. Built with Flutter and Firebase.

## Features

- **Custom Invites**: Pick a vibe, write a sweet message, and even add your own GIF or image.
- **Playful "No" Button**: A mischievous button that escapes when you try to click it!
- **Sweet Surprises**: Celebrate with confetti and a custom sound when they say "Yes".
- **Easy Sharing**: Generate a direct link to your invite and share it with your special someone.
- **Responsive Design**: Works beautifully on both mobile and desktop.

## Setup

1. **Firebase Configuration**:
   - Run `flutterfire configure` to link your project.
   - Enable Firestore Database in the Firebase Console.
   - Set up Firestore rules to allow public read/create access for the `valentine_invites` collection.

2. **Run the App**:

   ```bash
   flutter run -d chrome
   ```

3. **Deploy**:
   ```bash
   flutter build web --release
   firebase deploy --only hosting
   ```
# valentine-creator
