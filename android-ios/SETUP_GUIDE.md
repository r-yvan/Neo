# How to Run the EventNeo Flutter Project - Step by Step

## Prerequisites

Before running the project, ensure you have:

1. **Flutter SDK installed** (version 3.6.0 or higher)
   - Download from: https://flutter.dev/docs/get-started/install
   - Verify installation: `flutter --version`

2. **Backend API running**
   - The backend is in the `/api` folder
   - Navigate to `/api` and run: `npm run start:dev`
   - Backend will be available at `http://localhost:3000`
   - Swagger docs at `http://localhost:3000/docs`

3. **An emulator or physical device** (for mobile) OR Chrome (for web)

---

## Step-by-Step Setup

### Step 1: Navigate to the Flutter Project

```bash
cd android-ios
```

### Step 2: Install Dependencies

```bash
flutter pub get
```

This will download all the packages listed in `pubspec.yaml`.

### Step 3: Enable Web Platform (for testing without emulator)

If you don't have an Android/iOS emulator, enable web support:

```bash
flutter create --platforms=web .
```

This will add web support to the project.

### Step 4: Download and Add Satoshi Font

The app requires the Satoshi font family. Follow these steps:

1. Download Satoshi font from: https://www.fontshare.com/fonts/satoshi
2. Extract the downloaded ZIP file
3. Copy these files to `android-ios/assets/fonts/`:
   - `Satoshi-Light.ttf`
   - `Satoshi-Regular.ttf`
   - `Satoshi-Medium.ttf`
   - `Satoshi-Bold.ttf`
   - `Satoshi-Black.ttf`

**Note**: The font files must be `.ttf` format as specified in pubspec.yaml.

### Step 5: Generate Code (Optional - for JSON serialization)

The project uses code generation for JSON serialization. Run this command:

```bash
dart run build_runner build --delete-conflicting-outputs
```

**Note**: If you see "Could not find package build_runner", first run:

```bash
flutter pub get
```

Then try the build_runner command again.

### Step 6: Configure Backend URL

Edit the backend URL in `lib/core/config/app_config.dart`:

```dart
static const String baseUrl = 'http://localhost:3000/api/v1';
static const String websocketUrl = 'http://localhost:3000';
```

**For Android Emulator**: Use `http://10.0.2.2:3000/api/v1` instead of `localhost`
**For Production**: Use your actual domain, e.g., `https://api.eventneo.rw/api/v1`

### Step 7: Run the Backend

In a separate terminal, navigate to the API folder and start the backend:

```bash
cd ../api
npm run start:dev
```

Keep this terminal open. The backend should start on `http://localhost:3000`.

### Step 8: Run the Flutter App

Now you can run the Flutter app. Choose one of the following:

#### Option A: Run on Web (Chrome)

```bash
flutter run -d chrome
```

This will open the app in Chrome browser.

#### Option B: Run on Android Emulator

1. Start Android Studio
2. Open AVD Manager and create/start an emulator
3. Run:

```bash
flutter run
```

#### Option C: Run on iOS Simulator (Mac only)

1. Open Xcode
2. Start an iOS simulator
3. Run:

```bash
flutter run
```

#### Option D: Run on Physical Device

1. Enable developer mode on your phone
2. Connect via USB
3. Run:

```bash
flutter run
```

---

## Troubleshooting

### Issue: "flutter: command not found"

**Solution**: Flutter is not installed or not in your PATH. Install Flutter from https://flutter.dev/docs/get-started/install

### Issue: "Could not find package build_runner"

**Solution**: Run `flutter pub get` first to install dev dependencies.

### Issue: "No supported devices connected"

**Solution**: Either:

- Start an Android/iOS emulator, OR
- Enable web support: `flutter create --platforms=web .`
- Then run: `flutter run -d chrome`

### Issue: Font not found error

**Solution**: Ensure all Satoshi font files are in `assets/fonts/` with exact names matching pubspec.yaml.

### Issue: Backend connection failed

**Solution**:

1. Ensure backend is running: Check if `http://localhost:3000/docs` is accessible
2. For Android emulator, use `10.0.2.2` instead of `localhost`
3. Check if CORS is enabled on the backend
4. Verify the baseUrl in `lib/core/config/app_config.dart`

### Issue: "Failed to update packages"

**Solution**: Run `flutter clean` then `flutter pub get`

### Issue: Code generation errors

**Solution**:

```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

---

## Quick Reference Commands

```bash
# Install dependencies
flutter pub get

# Clean build cache
flutter clean

# Run on web
flutter run -d chrome

# Run on connected device/emulator
flutter run

# Generate code
dart run build_runner build --delete-conflicting-outputs

# Analyze code
flutter analyze

# Format code
flutter format .
```

---

## Testing the App

Once the app is running:

1. **Splash Screen**: You should see the EventNeo logo with animation
2. **Login Screen**: If not logged in, you'll see the login form
3. **Register**: Click "Register" to create a new account
4. **Home Screen**: After login, you'll see the home page with search and categories

### Test Authentication

1. Click "Register"
2. Enter:
   - Phone: `0780000000`
   - Full Name: `Test User`
   - Password: `123456`
3. Click "Create Account"
4. You should be redirected to the home screen

### Test Backend Connection

1. Open browser to `http://localhost:3000/docs`
2. Verify backend is running
3. Try the "Send OTP" endpoint to test connectivity

---

## Project Structure Overview

```
android-ios/
├── lib/
│   ├── core/              # Configuration, theme, errors
│   ├── data/              # Models, repositories, services
│   ├── domain/            # Business logic (empty for now)
│   ├── presentation/      # UI screens and widgets
│   └── main.dart          # App entry point
├── assets/
│   └── fonts/             # Satoshi font files (add these)
├── pubspec.yaml           # Dependencies
├── README.md             # Full documentation
└── SETUP_GUIDE.md         # This file
```

---

## Next Steps After Running

Once the app is running successfully:

1. **Test Authentication Flow**: Register and login
2. **Test Backend Integration**: Verify API calls work
3. **Add Missing Screens**: Equipment detail, booking flow, chat, etc.
4. **Add Real Images**: Replace placeholder images
5. **Test on Real Device**: Test on actual phone for production feel

---

## Need Help?

- Check the main README.md for detailed documentation
- Review PROJECT_STATUS.md for remaining work
- Check backend Swagger docs at `http://localhost:3000/docs`
- Verify backend is running before starting the Flutter app

---

## Summary

1. Ensure Flutter is installed
2. `cd android-ios`
3. `flutter pub get`
4. `flutter create --platforms=web .` (if no emulator)
5. Download and add Satoshi font files to `assets/fonts/`
6. Configure backend URL in `lib/core/config/app_config.dart`
7. Start backend in `/api` folder
8. Run: `flutter run -d chrome` (or `flutter run` for emulator)

That's it! The app should now be running.
