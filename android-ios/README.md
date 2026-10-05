# EventNeo - Event Equipment Rental Mobile App

A premium, modern Flutter mobile application for peer-to-peer event equipment rental in Rwanda. Built with Flutter, Riverpod, and NestJS backend.

## Features

- **Authentication**: Phone + OTP login, password-based login, National ID verification
- **Equipment Listing**: Browse, search, and filter event equipment (chairs, tables, tents, speakers, etc.)
- **Booking System**: Request rentals, manage bookings, track status
- **Real-time Chat**: In-app messaging between renters and owners
- **Reviews & Ratings**: Rate equipment and users after completed rentals
- **Owner Dashboard**: Manage listings, bookings, and earnings
- **Notifications**: Real-time alerts for bookings, payments, and messages
- **Favorites**: Save equipment for later
- **Premium UI**: Modern, clean design with Satoshi font and sophisticated grey color palette

## Tech Stack

- **Framework**: Flutter (latest stable)
- **State Management**: Riverpod
- **Networking**: Dio with JWT interceptors
- **Local Storage**: Hive + Flutter Secure Storage
- **Real-time**: Socket.io Client
- **Image Caching**: Cached Network Image
- **Code Generation**: json_serializable, freezed, build_runner

## Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / Xcode (for mobile development)
- Backend API running at `http://localhost:3000/api/v1`

## Installation

1. **Clone the repository** (if not already done):
   ```bash
   cd android-ios
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Generate code** (required for models and providers):
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Add Satoshi font files**:
   - Download the Satoshi font family from [FontShare](https://www.fontshare.com/fonts/satoshi)
   - Place the font files in `assets/fonts/`:
     - `Satoshi-Light.ttf`
     - `Satoshi-Regular.ttf`
     - `Satoshi-Medium.ttf`
     - `Satoshi-Bold.ttf`
     - `Satoshi-Black.ttf`

5. **Configure backend URL**:
   - Edit `lib/core/config/app_config.dart`
   - Update `baseUrl` to your backend API URL
   - Update `websocketUrl` to your WebSocket URL

   Example:
   ```dart
   static const String baseUrl = 'http://YOUR_IP:3000/api/v1';
   static const String websocketUrl = 'http://YOUR_IP:3000';
   ```

   For production, use your actual domain:
   ```dart
   static const String baseUrl = 'https://api.eventneo.rw/api/v1';
   static const String websocketUrl = 'https://api.eventneo.rw';
   ```

## Running the App

### Android

1. **Start an Android emulator or connect a physical device**
2. **Run the app**:
   ```bash
   flutter run
   ```

### iOS

1. **Start an iOS simulator**
2. **Run the app**:
   ```bash
   flutter run
   ```

### Web (Development Only)

```bash
flutter run -d chrome
```

## Project Structure

```
lib/
├── core/
│   ├── config/          # App configuration
│   ├── constants/       # App constants
│   ├── theme/           # App theme and colors
│   ├── utils/           # Utility functions
│   └── errors/          # Custom exceptions
├── data/
│   ├── models/          # Data models (DTOs)
│   ├── repositories/    # Data repositories
│   └── services/        # API client, storage, etc.
├── domain/
│   ├── entities/        # Domain entities
│   ├── repositories/    # Repository interfaces
│   └── usecases/        # Business logic use cases
├── presentation/
│   ├── pages/           # Screen widgets
│   ├── widgets/         # Reusable widgets
│   └── providers/       # Riverpod providers
└── main.dart            # App entry point
```

## Design System

### Colors

- **Primary Accent**: `#0A84FF` (Vibrant Blue)
- **Neutral Palette**: Pure greys from `#FAFAFA` to `#171717`
- **Semantic Colors**: Success (`#22C55E`), Warning (`#F59E0B`), Error (`#EF4444`)

### Typography

- **Font Family**: Satoshi (Light, Regular, Medium, Bold, Black)
- **Hierarchy**: Display, Headline, Title, Body, Label sizes

### Components

- **Rounded Corners**: 12-16px
- **Elevation**: Subtle shadows for depth
- **Spacing**: Generous white space for clean layout

## API Integration

The app integrates with the NestJS backend API located at `/api`. Key endpoints:

- **Auth**: `/auth/register`, `/auth/login`, `/auth/send-otp`, `/auth/verify-otp`
- **Equipment**: `/equipment`, `/equipment/:id`, `/equipment/my`
- **Bookings**: `/bookings`, `/bookings/:id/accept`, `/bookings/:id/reject`
- **Chat**: `/chat/conversations`, `/chat/send`
- **Reviews**: `/reviews`, `/reviews/equipment/:id`
- **Payments**: `/payments/initiate`, `/payments/confirm`

See the backend Swagger documentation at `http://localhost:3000/docs` for complete API reference.

## State Management

The app uses Riverpod for state management:

- **Auth Provider**: Manages authentication state
- **Equipment Provider**: Manages equipment listings
- **Booking Provider**: Manages booking state
- **Chat Provider**: Manages chat messages

## Local Storage

- **Hive**: Used for caching and settings
- **Flutter Secure Storage**: Used for sensitive data (tokens, user ID)

## Image Upload

Images are uploaded to the backend and stored as URLs. The app uses:
- `image_picker` for selecting images
- `cached_network_image` for caching

## Payment Integration

Placeholder integration for:
- MTN MoMo
- Airtel Money

Actual payment integration requires API keys from mobile money providers.

## Development

### Code Generation

After modifying models or adding new providers, run:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Linting

```bash
flutter analyze
```

### Formatting

```bash
flutter format .
```

## Testing

```bash
flutter test
```

## Building for Production

### Android APK

```bash
flutter build apk --release
```

### Android App Bundle

```bash
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

## Troubleshooting

### Code generation errors

If you encounter errors after adding new models:

```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Font not found

Ensure all Satoshi font files are in `assets/fonts/` and match the names in `pubspec.yaml`.

### Backend connection issues

1. Ensure the backend is running at the configured URL
2. Check network connectivity
3. Verify CORS settings on the backend
4. For Android emulator, use `10.0.2.2` instead of `localhost`

## Backend Setup

The backend is located in the `/api` folder. To set it up:

1. Navigate to the `/api` folder
2. Install dependencies: `npm install`
3. Set up environment variables in `.env`
4. Run database migrations: `npm run prisma:migrate`
5. Seed the database: `npm run prisma:seed`
6. Start the server: `npm run start:dev`

The backend will be available at `http://localhost:3000` with Swagger docs at `http://localhost:3000/docs`.

## Contributing

1. Follow the existing code style
2. Use Riverpod for state management
3. Add proper error handling
4. Write unit tests for new features
5. Update documentation

## License

Proprietary - All rights reserved

## Support

For issues or questions, contact the development team.
