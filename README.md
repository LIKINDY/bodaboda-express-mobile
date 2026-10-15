# 🏍️ Bodaboda Express

**Bodaboda Express** ni mfumo kamili wa usafiri wa bodaboda (Ride-Hailing & Logistics Platform) unaojumuisha Application ya Mteja (Customer App), Application ya Dereva (Driver App), na Seva ya Backend.

---

## 📁 Muundo wa Mradi (Project Structure)

```text
Bodaboda Express/
├── backend/                  # Sehemu ya Backend (APIs, WebSockets, Database)
│   └── server.dart          # Seva ya sasa (Dart WebSocket & HTTP Server)
├── bodaboda_customer/        # Flutter App ya Mteja (Customer Application)
├── bodaboda_driver/          # Flutter App ya Dereva (Driver Application)
├── BODABODA_MALL_INTEGRATION_ROADMAP.md # Mpango wa maboresho na mifumo ya malipo/mall
├── PROJECT_STATUS_REPORT.md  # Ripoti ya hali ya mradi
└── README.md
```

---

## 👨‍💻 Maelekezo kwa Mhandisi wa Backend (Backend Developer Guide)

Hapa ni taarifa muhimu unazohitaji ili kuweka au kuendeleza Backend:

### 1. Eneo la Kazi:
Weka msimbo wako wote wa backend ndani ya folda ya `backend/`. Unaweza kuendeleza mfumo uliopo (`server.dart`) au kutumia teknolojia unayopendelea (k.m. Node.js/Express, Go, Python/FastAPI, au Dart/Shelf/Serverpod).

### 2. Mawasiliano na Apps za Simu (Mobile Apps Integration):
- **Real-time Ride Dispatching (WebSocket):**
  - Apps zinatumia WebSocket kwa ajili ya kutuma maombi ya usafiri (`new_ride`), dereva kupokea safari (`ride_accepted`), dereva kuanza safari (`ride_started`), na dereva kukamilisha safari (`ride_completed`).
  - Pia kuna live GPS location updates (`location_update`).
- **REST Endpoints / Services:**
  - **Auth:** Usajili na kuingia (Mteja & Dereva), OTP verification, upakiaji wa nyaraka za dereva (Driving License, NIDA/Kitambulisho).
  - **Rides & Pricing:** Kukadiria nauli, hesabu ya umbali (distance-based pricing), historia ya safari.
  - **Malipo & Wallet:** M-Pesa, Airtel Money, Tigo Pesa, Halopesa, Fuel Wallet ya madereva.
- **Mock Services zilizopo kwenye Flutter:**
  - Angalia `bodaboda_customer/lib/core/services/mock_backend_service.dart` na `bodaboda_driver/lib/core/services/mock_backend_service.dart` kuona muundo halisi wa data (JSON schemas) ambazo app inatarajia.

---

## 📱 Maelekezo ya Kuanzisha Apps (Mobile Apps Setup)

### Mahitaji (Prerequisites):
- Flutter SDK (v3.x au zaidi)
- Android Studio au VS Code na viendelezi vya Dart & Flutter

### Kuanzisha Customer App:
```bash
cd bodaboda_customer
flutter pub get
flutter run
```

### Kuanzisha Driver App:
```bash
cd bodaboda_driver
flutter pub get
flutter run
```

### Kuanzisha Seva ya Backend (iliyopo):
```bash
cd backend
dart run server.dart
```

---

## 📌 Hali ya Git & Tawi (Branch)
- **Main Branch:** `main`
- Faili nzito za binaries kama `.apk`, `build/` na `cache` zimezuiliwa kwenye `.gitignore` ili kulinda kasi na ukubwa wa repository.
