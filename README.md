# WhatsApp Clone App

A full-featured WhatsApp-style chat application built with Flutter and Firebase, featuring real-time messaging, status updates, voice/video calls, and contact synchronization.

## 🚀 Features

### 🔐 Authentication
- **Firebase Email/Password Authentication**
- **Google Sign-In Integration**
- **User Profile Setup** (Display Name, Phone Number, Profile Picture)
- **Secure User Management**

### 👥 Contact Management
- **Device Contact Integration**
- **Phone Number Matching** with app users
- **Contact Permission Handling**
- **Real-time Contact Sync**

### 💬 Chat System
- **Real-time Messaging** using Firestore
- **Message Types**: Text, Images, Emojis
- **Message Status**: Sent, Delivered, Seen
- **Typing Indicators**
- **Online/Offline Status**
- **Message Timestamps**
- **Message Deletion**

### 📸 Status Feature
- **WhatsApp-style Status Updates**
- **Text and Image Status Support**
- **24-hour Auto-expiration**
- **Status View Tracking**
- **Base64 Image Storage**

### 📞 Voice/Video Calling
- **WebRTC Integration** for calls
- **Call Interface**: Accept, Reject, Mute, End
- **Call Logs** in Firestore
- **Call History Management**

### 🔔 Notifications
- **Firebase Cloud Messaging (FCM)**
- **Push Notifications** for:
  - New messages
  - Incoming calls
  - Status updates
- **Background/Foreground Support**

### 🔐 Privacy & Settings
- **User Blocking/Unblocking**
- **Privacy Controls** (Last Seen, Profile Pic, Status)
- **Account Management**
- **Theme Support** (Light/Dark)

## 🛠️ Tech Stack

- **Frontend**: Flutter 3.0+
- **Backend**: Firebase
- **Database**: Cloud Firestore
- **Authentication**: Firebase Auth
- **Real-time**: Firebase Realtime Database
- **Notifications**: Firebase Cloud Messaging
- **State Management**: Riverpod
- **Calls**: WebRTC (flutter_webrtc)
- **Storage**: Base64 in Firestore (no Firebase Storage)

## 📱 Screenshots

*Screenshots will be added after app completion*

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK
- Android Studio / VS Code
- Firebase Account
- Google Cloud Project

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/aarushgotlost/tearixreal.git
   cd tearixreal
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**

   a. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
   
   b. Enable the following services:
      - Authentication (Email/Password, Google)
      - Cloud Firestore
      - Realtime Database
      - Cloud Messaging
   
   c. Download configuration files:
      - `google-services.json` → `android/app/`
      - `GoogleService-Info.plist` → `ios/Runner/`

4. **Update Firebase Configuration**

   Replace placeholder values in:
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`

5. **Deploy Firestore Rules and Indexes**

   ```bash
   # Install Firebase CLI
   npm install -g firebase-tools
   
   # Login to Firebase
   firebase login
   
   # Initialize Firebase (if not done)
   firebase init firestore
   
   # Deploy security rules
   firebase deploy --only firestore:rules
   
   # Deploy indexes
   firebase deploy --only firestore:indexes
   ```

6. **Run the app**
   ```bash
   flutter run
   ```

## 📁 Project Structure

```
lib/
├── models/                 # Data models
│   ├── user_model.dart
│   ├── message_model.dart
│   ├── chat_model.dart
│   ├── status_model.dart
│   └── call_model.dart
├── services/              # Business logic
│   ├── auth_service.dart
│   ├── chat_service.dart
│   ├── status_service.dart
│   ├── contact_service.dart
│   └── notification_service.dart
├── screens/               # UI screens
│   ├── auth/
│   │   └── login_screen.dart
│   └── home/
│       └── home_screen.dart
├── widgets/               # Reusable widgets
├── providers/             # State management
└── main.dart             # App entry point
```

## 🔧 Configuration

### Firebase Security Rules

The app includes comprehensive Firestore security rules in `firestore.rules`:

- **User Access**: Users can only read/write their own data
- **Chat Access**: Only chat participants can access chat data
- **Message Access**: Only sender/receiver can access messages
- **Status Access**: Users can create their own status, read others'
- **Call Access**: Only call participants can access call data

### Firestore Indexes

Optimized indexes in `firestore.indexes.json` for:
- Messages by chat ID and timestamp
- Messages by sender/receiver and timestamp
- Status by user and creation time
- Status by expiration time
- Calls by caller/receiver and start time

## 🚀 Deployment

### Android

1. **Build APK**
   ```bash
   flutter build apk --release
   ```

2. **Build App Bundle**
   ```bash
   flutter build appbundle --release
   ```

### iOS

1. **Build iOS**
   ```bash
   flutter build ios --release
   ```

2. **Archive in Xcode**
   - Open `ios/Runner.xcworkspace`
   - Archive and upload to App Store Connect

## 🔒 Security Features

- **Firebase Security Rules** for data access control
- **User Authentication** with multiple providers
- **Phone Number Verification** for contact matching
- **Privacy Controls** for user data visibility
- **Message Encryption** (can be extended)

## 📊 Firebase Free Tier Limits

This app is designed to work within Firebase Free Tier limits:

- **Firestore**: 1GB storage, 50K reads/day, 20K writes/day
- **Authentication**: 10K users/month
- **Realtime Database**: 1GB storage, 10GB transfer/month
- **Cloud Messaging**: Unlimited

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

If you encounter any issues:

1. Check the [Firebase Documentation](https://firebase.flutter.dev/)
2. Review [Flutter Documentation](https://flutter.dev/docs)
3. Open an issue in this repository

## 🔮 Future Enhancements

- [ ] End-to-end encryption
- [ ] Group chats
- [ ] File sharing
- [ ] Voice messages
- [ ] Video status
- [ ] Custom themes
- [ ] Multi-language support
- [ ] Backup and restore
- [ ] Advanced search
- [ ] Message reactions

## 📞 Contact

- **Developer**: Aarush
- **GitHub**: [@aarushgotlost](https://github.com/aarushgotlost)
- **Project**: [WhatsApp Clone](https://github.com/aarushgotlost/tearixreal)

---

**Note**: This is a demonstration project. For production use, ensure proper security measures, testing, and compliance with relevant regulations. 