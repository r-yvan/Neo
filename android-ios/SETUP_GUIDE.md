# Setup guide

The full step-by-step commands (backend, Android emulator, Chrome and a real
device) are in [`../starter-cmds.md`](../starter-cmds.md). This page is a quick
summary.

## Quick start

```bash
# 1. Backend (terminal 1)
cd api
npm install
cp .env.example .env            # set DATABASE_URL + JWT secrets
npm run db:setup                # migrate + seed demo data
npm run start:dev               # http://localhost:3000/docs

# 2. App (terminal 2)
cd android-ios
flutter pub get
flutter run -d chrome           # or an emulator id from `flutter devices`
```

Demo logins (password `Password123!`):

| Role | Phone |
| --- | --- |
| Admin | `0780000001` |
| Owner | `0780000002` |
| Renter | `0780000003` |

## Notes

- **Fonts:** the Satoshi font is bundled in `assets/fonts/satoshi/`. Nothing to download.
- **Code generation:** none required. Models are hand-written in `lib/data/models/`.
- **API URL:** the app picks it automatically (web/iOS → `localhost`, Android
  emulator → `10.0.2.2`). For a real phone, add
  `--dart-define=API_BASE_URL=http://<LAN_IP>:3000/api/v1`.
- **Project layout and feature list:** see [`PROJECT_STATUS.md`](PROJECT_STATUS.md).

## Troubleshooting

| Problem | Fix |
| --- | --- |
| Backend connection failed | Check `http://localhost:3000/api/v1/system/health`. On a phone, use your LAN IP and open port 3000 in the firewall. |
| Build errors after pulling | `flutter clean && flutter pub get` |
| No devices found | `flutter doctor`, then `flutter emulators --launch <name>` or use `-d chrome`. |
