# Setup Guide

## Environment Variables

1. Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```

2. Fill in your environment variables in `.env`:

### MongoDB Setup

1. Create a MongoDB Atlas account at https://www.mongodb.com/cloud/atlas
2. Create a new cluster
3. Create a database user
4. Whitelist your IP address (or use `0.0.0.0/0` for development)
5. Get your connection string from "Connect" -> "Connect your application"
6. Replace the `MONGODB_URI` in `.env` with your connection string

Example:
```
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/database_name?retryWrites=true&w=majority
```

### Google Sign In Setup

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the Google+ API
4. Go to "Credentials" -> "Create Credentials" -> "OAuth 2.0 Client ID"
5. Create OAuth 2.0 Client IDs for:
   - **Web application** (for web support)
   - **iOS** (for iOS app)
   - **Android** (for Android app)
6. Copy the Client IDs to your `.env` file

For Android:
- Package name: `com.vofidevs.dejsipauzu` (from `android/app/build.gradle.kts`)
- SHA-1 certificate fingerprint: Get it using:
  ```bash
  keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
  ```

For iOS:
- Bundle ID: Check your `ios/Runner/Info.plist` or Xcode project settings

## Running the App

1. Install dependencies:
   ```bash
   flutter pub get
   ```

2. Make sure your `.env` file is properly configured

3. Run the app:
   ```bash
   flutter run
   ```

## Notes

- The `.env` file is gitignored and should never be committed
- Use `.env.example` as a template for your environment variables
- For production, use secure environment variable management (e.g., CI/CD secrets)

