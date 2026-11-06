# Neo mobile app: project status

Flutter client for the Neo peer-to-peer event-equipment rental marketplace
(Rwanda). It is fully wired to the NestJS backend in `../api`.

For run commands, see [`../starter-cmds.md`](../starter-cmds.md).

## Verified

- `flutter analyze` reports **0 errors and 0 warnings**.
- `flutter test` passes **23 tests**: illustrations in light/dark mode, the reduce-motion setting, and model parsing (including the map payloads).
- The debug APK and the release web build both compile.
- These flows were checked against the live API in Chrome and on the Android
  emulator (via `10.0.2.2`):
  - onboarding
  - sign-in
  - Explore, including the Popular and Near you rails
  - Profile
  - every admin-console tab
  - the owner's booking list, booking detail and dispute response
  - the nearby map: the real Android location prompt, the device location, pins
    and carousel kept in sync, the layer switch, and the "Show me on the map" toggle

## Features

| Area | Screens / behaviour |
| --- | --- |
| Onboarding & auth | Three animated onboarding scenes. Sign in, register, OTP and forgot/reset password, each with its own animated illustration. |
| Explore | Search, category chips and a filter sheet (price, location, date). Popular and Near you rails above an infinite grid. |
| Equipment | Detail with image carousel, availability calendar, reviews and report. Create/edit listing with **real photo upload** from camera or gallery, a cover photo and upload progress. Availability management and boost. |
| Booking | Multi-step booking flow with price breakdown and MTN MoMo / Airtel Money payment. My bookings (renting / my items) with status filters. Booking detail with timeline, accept/reject/start/complete/cancel, extension and review. |
| Disputes | Open a dispute from a booking. **Dispute screen** with a three-step timeline (opened → response → Neo's decision); the other party responds in-app. |
| Owner | Dashboard with earnings, breakdown chart, withdrawals and listings. |
| Nearby map | Map of **lenders** and **borrowers** around you. Lenders are owners with live listings, one coral pin per pickup area. Borrowers are renters who opted in, shown as graphite pins at an approximate (about 1 km) position, with an optional "what I need" note. Includes All/Lenders/Borrowers filter, radius (5–50 km), "Search this area", "My location", a swipeable result carousel synced with the pins, Profile/Message actions, and the **Show me on the map** privacy sheet. |
| Payments | **Payment history**: a ledger of rentals, payouts, boosts and withdrawals with totals. |
| Social | Favourites, chat (REST and polling) with an **unread badge** on the Messages tab, and notifications with settings. |
| Profile | Edit profile, **avatar upload**, change password, National ID verification, become an owner, **My reports**, theme (light/dark/system) and language. |
| Admin console (ADMIN role only) | Overview: revenue, KPIs, items needing attention, last 30 days and top listings. Users: verify, ban/unban. Listings: approve/reject. Money: transactions and bookings. Trust: resolve or dismiss reports, resolve or close disputes with a decision. Reviews: delete. |
| Languages | English and Kinyarwanda, for every string. |

## Architecture

```
android-ios/
├── assets/
│   ├── fonts/satoshi/        Satoshi font family (.otf, all weights + italics)
│   ├── icons/
│   └── images/
└── lib/
    ├── main.dart / app.dart  Bootstrap, theme, router, localisation
    ├── core/
    │   ├── location/         LocationService (geolocator wrapper that never throws)
    │   ├── config/           AppConfig (per-platform API URL, poll intervals)
    │   ├── l10n/             Strings (EN + RW) and the locale model
    │   ├── network/          Dio ApiClient (JWT, refresh, multipart upload) and ApiPaths
    │   ├── storage/          Token store and preferences
    │   ├── theme/            Colours (single coral accent + true greys), typography, theme
    │   ├── utils/            Formatters, parsing, validators
    │   └── widgets/          Design-system widgets plus illustrations/ (animated CustomPainter scenes)
    ├── data/
    │   ├── models/           API models (models.dart, admin_models.dart, pagination)
    │   ├── repositories/     One repository per backend module, including media and admin
    │   └── providers.dart    Riverpod providers and the session state machine
    └── features/             One folder per feature (screens + feature widgets)
```

Every route in `ApiPaths` is used by the app.

## Backend changes made for full integration

- `POST /api/v1/uploads`: authenticated multipart image upload. It is served
  statically at `/uploads/*`, and the limits come from `UPLOAD_DIR` and
  `MAX_FILE_SIZE_MB`.
- Booking payloads now include a `dispute { id, status }` summary, so the app can
  link to a dispute.
- Opening a dispute now writes a `DISPUTED` entry to the booking timeline.
- The API binds to `0.0.0.0`, so emulators and phones on the LAN can reach it.
- `api/.env.example` added.
- **Map module** (`/api/v1/map`):
  - `GET /map/nearby?latitude&longitude&radiusKm&layer=all|lenders|borrowers`
  - `GET /map/me`, `PATCH /map/me` (location, area label, note, `showOnMap`)
  - `DELETE /map/me` (hide and erase the stored location)
- User table: new opt-in presence fields (migration `20261106150000_user_map_location`).
- Privacy rules:
  - Borrowers are published only after opting in.
  - Positions are rounded to about 1 km, and distances are measured from the rounded point.
  - Borrowers drop off the map after 30 days.
  - Banned and deleted users never appear.
  - Public profiles never return coordinates.
- Seed: two extra lenders and two extra borrowers around Kigali for the map demo.

## Known limitations and next steps

- Payments use the backend's MoMo/Airtel **placeholder** flow. Real provider
  credentials and webhooks are needed for production.
- Chat uses REST polling because the backend exposes no websocket gateway.
- The "Near you" rail on Explore is still centred on Kigali. The map itself uses
  the device location.
- Map tiles default to the public OpenStreetMap server, which is fine for development.
  Set `MAP_TILES_LIGHT` / `MAP_TILES_DARK` to a tile provider for production
  (see `starter-cmds.md` §6).
- Uploaded images are stored on the API's local disk. Use S3/Cloudinary in
  production.
- Push notifications (FCM) are not set up yet.
