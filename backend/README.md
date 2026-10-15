# 🏍️ Bodaboda Express — Seva ya Seva (Node.js Backend Guide)

Karibu kwenye mfumo wa Backend wa **Bodaboda Express**! Huu ni mwongozo rasmi na maelekezo kamili kwa ajili ya Msanidi wa Backend (Backend Developer) kuanza kazi mara moja.

---

## 🏗️ 1. Muundo wa Faili (Directory Structure)

```text
backend/
├── src/
│   ├── config/              # Mipangilio ya Database (MongoDB / PostgreSQL)
│   ├── controllers/         # Logic ya biashara ya kila huduma
│   │   ├── authController.js    # Usajili & OTP kwa mteja na dereva
│   │   ├── rideController.js    # Nauli, maelezo ya safari, kughairi
│   │   ├── driverController.js  # Online/Offline, mapato, heatmap
│   │   └── paymentController.js # M-Pesa, Tigo Pesa, Wallet
│   ├── middleware/          # JWT Auth & Error Handling
│   │   ├── authMiddleware.js
│   │   └── errorHandler.js
│   ├── routes/              # Njia zote za REST API
│   │   ├── authRoutes.js
│   │   ├── rideRoutes.js
│   │   ├── driverRoutes.js
│   │   └── paymentRoutes.js
│   ├── services/            # Huduma za hesabu & WebSocket
│   │   ├── pricingService.js   # Hesabu ya nauli ya Bodaboda vs Bajaji
│   │   └── websocketService.js # Mawasiliano ya moja kwa moja (Real-time)
│   └── server.js            # Seva Kuu (Express + WebSocket Gateway)
├── .env.example             # Mfano wa vigezo vya mazingira (Environment variables)
├── package.json             # Maktaba na maagizo (Dependencies & Scripts)
└── README.md                # Mwongozo huu
```

---

## ⚡ 2. Jinsi ya Kuanzisha Kwenye Kompyuta Yako (Local Setup)

### Mahitaji:
- **Node.js**: v18.0.0 au zaidi (inasaidia ES Modules)
- **NPM**: v9.0 au zaidi

### Hatua za Kuanzisha:
1. Ingia ndani ya folda ya `backend/`:
   ```bash
   cd backend
   ```
2. Sakinisha maktaba (dependencies):
   ```bash
   npm install
   ```
3. Tengeneza faili la `.env` kwa kunakili kutoka `.env.example`:
   ```bash
   cp .env.example .env
   # Kwenye Windows PowerShell:
   Copy-Item .env.example .env
   ```
4. Anzisha seva katika mazingira ya kazi (Development mode na auto-reload):
   ```bash
   npm run dev
   ```
5. Seva itakuwa hewani kwenye:
   - **HTTP API:** `http://localhost:3000/api/v1`
   - **WebSocket Gateway:** `ws://localhost:3000/ws`
   - **Dashboard ya Hali:** `http://localhost:3000/`

---

## 📡 3. Mawasiliano ya Moja kwa Moja (WebSocket Protocol - `ws://localhost:3000/ws`)

Apps za Flutter (`bodaboda_customer` na `bodaboda_driver`) zinatumia **WebSocket ya moja kwa moja** kwa mawasiliano ya haraka:

### 1. Mteja Kuomba Safari (`new_ride`)
Mteja anapotafuta dereva, app inatuma:
```json
{
  "type": "new_ride",
  "data": {
    "rideId": "TRIP-4912",
    "pickupAddress": "Kariakoo Msimbazi, Dar es Salaam",
    "destinationAddress": "Posta Mpya, Dar es Salaam",
    "pickupLatLng": { "lat": -6.8197, "lng": 39.2743 },
    "destinationLatLng": { "lat": -6.8162, "lng": 39.2905 },
    "vehicleType": "bodaboda", // au "bajaji"
    "serviceType": "ride",     // au "delivery" (mzigo)
    "fare": 3500,
    "paymentMethod": "cash",   // au "mpesa", "wallet"
    "customerPhone": "+255712345678",
    "customerName": "Amina Said",
    "otpPin": "4921"
  }
}
```
*Seva inaitangaza kwa madereva wote waliopo Online.*

### 2. Dereva Kukubali Safari (`ride_accepted`)
Dereva anapobonyeza kitufe cha kukubali safari (ndani ya sekunde 15):
```json
{
  "type": "ride_accepted",
  "rideId": "TRIP-4912",
  "driverId": "DRV-102",
  "driverName": "Juma Shabani",
  "driverPhone": "+255755123456",
  "driverPlate": "MC 582 DFB"
}
```
*Seva inatuma taarifa kwa mteja kuwa safari imekubaliwa na kufunga ombi hilo kwa madereva wengine.*

### 3. Dereva Kubadili Hali ya Online/Offline (`driver_status_update`)
```json
{
  "type": "driver_status_update",
  "status": "online" // au "offline"
}
```

### 4. Kurusha Mahali Dereva Alipo (Live GPS Update) (`location_update`)
```json
{
  "type": "location_update",
  "rideId": "TRIP-4912",
  "lat": -6.8190,
  "lng": 39.2750,
  "heading": 45.0
}
```

### 5. Kuthibitisha PIN ya Mteja Kuanza Safari (`verify_pin`)
Dereva anapofika na kuanzisha safari, mteja anampa PIN ya tarakimu 4 (mfano: `4921`):
```json
{
  "type": "verify_pin",
  "rideId": "TRIP-4912",
  "pin": "4921"
}
```
*Kama PIN ni sahihi, seva inatuma tukio la `ride_started` kwa mteja na dereva.*

### 6. Kukamilisha Safari (`ride_completed`)
```json
{
  "type": "ride_completed",
  "rideId": "TRIP-4912",
  "finalFare": 3500
}
```

---

## 🌐 4. Orodha ya REST API Endpoints (`/api/v1`)

### 🔐 A. Huduma za Utambulisho (Authentication)
| Method | Endpoint | Maelezo |
| :--- | :--- | :--- |
| `POST` | `/api/v1/auth/customer/request-otp` | Kutuma OTP ya tarakimu 4 kwa simu ya mteja |
| `POST` | `/api/v1/auth/customer/verify-otp` | Kuhakiki OTP na kutoa JWT Token |
| `POST` | `/api/v1/auth/driver/login` | Dereva kuanzisha mchakato wa kuingia |
| `POST` | `/api/v1/auth/driver/verify-otp` | Kuhakiki OTP ya dereva |
| `POST` | `/api/v1/auth/driver/upload-documents` | Kupakia Selfie ya sura & Kitambulisho (NIDA/Kura/Sheha) |
| `POST` | `/api/v1/auth/social` | Kuingia kwa Google / Apple Sign-In |

### 🏍️ B. Huduma za Safari & Nauli (Rides)
| Method | Endpoint | Maelezo |
| :--- | :--- | :--- |
| `POST` | `/api/v1/rides/estimate` | Kukadiria nauli kwa Bodaboda au Bajaji kulingana na km |
| `GET` | `/api/v1/rides/:rideId` | Kupata taarifa za safari mahususi |
| `POST` | `/api/v1/rides/:rideId/cancel` | Kughairi safari (pamoja na fidia ya TZS 1,500 kama dereva alishasogea > 0.5km) |
| `GET` | `/api/v1/rides/history` | Historia ya safari zilizopita |

### 🧭 C. Huduma za Dereva (Driver Operations)
| Method | Endpoint | Maelezo |
| :--- | :--- | :--- |
| `POST` | `/api/v1/drivers/status` | Kubadili Online / Offline |
| `GET` | `/api/v1/drivers/earnings` | Mapato ya leo, wiki, na mwezi (TZS) |
| `GET` | `/api/v1/drivers/demand-heatmap` | Maeneo yenye abiria wengi Dar (Kariakoo, Ubungo, Mwenge, Posta) |
| `PUT` | `/api/v1/drivers/profile-documents` | Kusasisha leseni ya udereva na namba ya LATRA |

### 💳 D. Huduma za Malipo & Pochi (Payments & Wallet)
| Method | Endpoint | Maelezo |
| :--- | :--- | :--- |
| `POST` | `/api/v1/payments/initiate` | Kuanzisha malipo (Cash, M-Pesa USSD Push, Tigo Pesa, Airtel) |
| `POST` | `/api/v1/payments/callback` | Webhook ya kupokea majibu ya mitandao ya simu |
| `GET` | `/api/v1/payments/wallet/balance` | Kuangalia salio la Main Wallet & Fuel Wallet ya dereva |
| `POST` | `/api/v1/payments/wallet/topup` | Kuongeza salio kwenye pochi |

---

## 🗄️ 5. Hifadhidata Inayopendekezwa (Database Schema)

Unaweza kutumia **MongoDB (Mongoose)** au **PostgreSQL (Prisma / TypeORM)**:

### 1. `User` (Wateja)
- `id`, `phone`, `fullName`, `profilePhotoUrl`, `role`, `walletBalance`, `debtAmount`, `lastRideDate`, `createdAt`

### 2. `Driver` (Madereva)
- `id`, `phone`, `fullName`, `faceSelfieUrl`, `idType` (NIDA/Voter/LocalGov), `idNumber`, `idDocumentUrl`
- `vehicleType` ('bodaboda' | 'bajaji'), `plateNumber`
- `drivingLicenseNumber`, `latraRegistrationNumber`
- `isOnline`, `currentLocation` (`lat`, `lng`, `heading`)
- `rating`, `totalTrips`, `fuelWalletBalance`

### 3. `Ride` (Safari)
- `id`, `customerId`, `driverId`, `vehicleType`, `serviceType` ('ride' | 'delivery')
- `pickupAddress`, `pickupLocation`, `destinationAddress`, `destinationLocation`
- `distanceKm`, `durationMins`, `fare`, `status` ('searching', 'accepted', 'in_progress', 'completed', 'cancelled')
- `otpPin`, `paymentMethod`, `paymentStatus`

---

## 🚀 6. Kazi Zinazofuata za Backend (Next Milestones)
1. Unganisha hifadhidata halisi (MongoDB au PostgreSQL).
2. Unganisha SMS Gateway (k.m. Beem Africa au Twilio) kwa ajili ya kutuma OTP halisi za simu za Tanzania (`+255`).
3. Unganisha M-Pesa Daraja API au Selcom/DPO kwa malipo ya mtandaoni moja kwa moja.
4. Tuma maboresho yako kwa njia ya Git Branch:
   ```bash
   git checkout -b feature/database-integration
   git add .
   git commit -m "feat: integrate database and SMS provider"
   git push -u origin feature/database-integration
   ```
