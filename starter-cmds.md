# Neo — starter commands

Copy-paste commands to run the **backend** (`api/`, NestJS + PostgreSQL) and the
**mobile app** (`android-ios/`, Flutter) on an Android emulator, in Chrome, and
on a real phone.

> Run every command from the repository root (the folder that holds `api/` and
> `android-ios/`) unless a step says otherwise.

---

## 0. One-time prerequisites

| Tool | Check | Notes |
| --- | --- | --- |
| Node.js 20+ | `node -v` | Backend runtime |
| PostgreSQL 14+ | `pg_isready` | Must be running locally |
| Flutter (stable) | `flutter --version` | Mobile app |
| Android SDK + emulator | `flutter doctor` | For emulator / real Android device |
| Google Chrome | `google-chrome --version` | For the web build |

```bash
flutter doctor            # fix anything marked ✗ before continuing
```

---

## 1. Backend (API)

### 1.1 First-time setup

```bash
cd api
npm install

# Environment: copy the template, then edit DATABASE_URL and the JWT secrets
cp .env.example .env

# Create the database (name must match DATABASE_URL), run migrations, seed demo data
createdb neo-db                 # skip if it already exists
npx prisma generate
npm run db:setup                # = prisma migrate dev + seed
cd ..
```

### 1.2 Start the API

```bash
cd api
npm run start:dev               # watch mode — restarts on every change
```

Production-style run instead:

```bash
cd api
npm run build && npm run start:prod
```

The API listens on **all interfaces, port 3000**:

| What | URL |
| --- | --- |
| REST base | http://localhost:3000/api/v1 |
| Swagger docs | http://localhost:3000/docs |
| Health check | http://localhost:3000/api/v1/system/health |
| Uploaded images | http://localhost:3000/uploads/… |

```bash
curl http://localhost:3000/api/v1/system/health      # → {"status":"ok",…}
```

### 1.3 Seeded demo accounts

Password for all: **`Password123!`** (in the app, type the phone as `07…`)

| Role | Phone |
| --- | --- |
| Admin (+ owner, renter) | `0780000001` |
| Owner | `0780000002` |
| Renter | `0780000003` |

OTP codes are printed in the API terminal in development.

### 1.4 Useful backend commands

```bash
cd api
npm test                        # unit tests
npm run test:e2e                # end-to-end tests
npx prisma studio               # browse the database in the browser
npm run prisma:seed             # re-seed demo data
npx prisma migrate reset        # ⚠ wipes the DB, re-applies migrations and seeds
```

---

## 2. Mobile app — shared setup

```bash
cd android-ios
flutter pub get
flutter devices                 # lists Chrome, emulators and connected phones
```

The app picks the API address automatically when no override is given:

| Target | Default API URL |
| --- | --- |
| Chrome (web) | `http://localhost:3000/api/v1` |
| Android emulator | `http://10.0.2.2:3000/api/v1` (the emulator's alias for your computer) |
| iOS simulator | `http://localhost:3000/api/v1` |
| **Real phone** | **must be passed with `--dart-define`** (see section 5) |

Any target can be pointed somewhere else with
`--dart-define=API_BASE_URL=http://HOST:3000/api/v1`.

> Keep the backend (step 1.2) running in its own terminal while you use the app.

---

## 3. Android emulator

```bash
# List and start an emulator (example AVD name: Pixel_10_Pro)
flutter emulators
flutter emulators --launch Pixel_10_Pro
# …or: ~/Android/Sdk/emulator/emulator -avd Pixel_10_Pro

# Run the app on it (the API is reached through 10.0.2.2 automatically)
cd android-ios
flutter run -d emulator-5554     # use the id shown by `flutter devices`
```

While `flutter run` is attached: `r` = hot reload · `R` = hot restart · `q` = quit.

---

## 4. Chrome (web)

```bash
cd android-ios
flutter run -d chrome
```

Fixed port, handy for bookmarking:

```bash
flutter run -d chrome --web-port 5000
```

Release build served locally:

```bash
cd android-ios
flutter build web --release
cd build/web && python3 -m http.server 8088      # open http://localhost:8088
```

> Camera capture on the web depends on the browser. Gallery uploads work everywhere.

---

## 5. Real device (Android phone)

A phone cannot reach `localhost`, so it needs your computer's **LAN IP**, and both
devices must be on the **same Wi-Fi**.

### 5.1 Find your computer's LAN IP

```bash
hostname -I | awk '{print $1}'          # Linux   (e.g. 192.168.1.97)
ipconfig getifaddr en0                  # macOS
ipconfig                                # Windows → "IPv4 Address"
```

### 5.2 Allow port 3000 through the firewall (if enabled)

```bash
sudo ufw allow 3000/tcp                 # Ubuntu/Debian with ufw
```

Check from the phone's browser: `http://<LAN_IP>:3000/api/v1/system/health`.

### 5.3 Connect the phone

1. On the phone: **Settings → About phone → tap "Build number" 7×** to unlock
   Developer options.
2. **Developer options → USB debugging: ON**, plug in the USB cable and accept the
   "Allow USB debugging" prompt.

```bash
adb devices                             # phone should be listed as "device"
```

Wireless instead of USB (Android 11+): **Developer options → Wireless debugging → Pair
device with pairing code**, then:

```bash
adb pair <PHONE_IP>:<PAIR_PORT>          # enter the 6-digit code
adb connect <PHONE_IP>:<PORT>
```

### 5.4 Run on the phone

```bash
cd android-ios
flutter run -d <DEVICE_ID> \
  --dart-define=API_BASE_URL=http://<LAN_IP>:3000/api/v1
```

Example on this machine:

```bash
flutter run -d <DEVICE_ID> --dart-define=API_BASE_URL=http://192.168.1.97:3000/api/v1
```

### 5.5 Install a standalone APK (no cable needed afterwards)

```bash
cd android-ios
flutter build apk --release \
  --dart-define=API_BASE_URL=http://<LAN_IP>:3000/api/v1
adb install -r build/app/outputs/flutter-apk/app-release.apk
# or copy build/app/outputs/flutter-apk/app-release.apk to the phone and open it
```

### iPhone (macOS + Xcode only)

```bash
cd android-ios/ios && pod install && cd ..
open ios/Runner.xcworkspace              # set your Team under Signing & Capabilities once
flutter run -d <IPHONE_ID> --dart-define=API_BASE_URL=http://<LAN_IP>:3000/api/v1
```

---

## 6. Quality checks

```bash
cd android-ios
flutter analyze                          # static analysis
flutter test                             # widget + model tests
flutter build apk --debug                # make sure Android compiles

cd ../api
npm run build && npm test
```

---

## 7. Troubleshooting

| Symptom | Fix |
| --- | --- |
| App shows "network error" on the emulator | Make sure the API is running; the emulator must use `10.0.2.2`, not `localhost`. |
| Real phone can't connect | Same Wi-Fi? Correct `--dart-define` IP? Port 3000 open in the firewall? Test the health URL in the phone's browser. |
| `Can't reach database server` | Start PostgreSQL and check `DATABASE_URL` in `api/.env`. |
| Login says "Invalid credentials" for demo users | Re-seed: `cd api && npm run prisma:seed`. |
| Photos don't upload | The API stores files in `api/uploads/` (max 5 MB, JPEG/PNG/WEBP/HEIC). |
| Strange build errors after pulling | `cd android-ios && flutter clean && flutter pub get` |
| Port 3000 already in use | `lsof -i :3000` then stop that process, or change `PORT` in `api/.env` (and the app URL). |
