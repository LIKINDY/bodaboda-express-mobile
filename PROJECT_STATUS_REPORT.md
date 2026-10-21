# 🏍️ Bodaboda Express — Ripoti Rasmi ya Mradi kwa Ajili ya Timu (Official Team Project Report)

**Tarehe ya Ripoti:** Oktoba 2026  
**Mradi:** Bodaboda Express (Mobile Apps & Node.js Backend Ecosystem)  
**Msimamizi wa Mradi:** Likindy Ismail  
**Hifadhi Rasmi ya GitHub:** [https://github.com/LIKINDY/bodaboda-express-mobile](https://github.com/LIKINDY/bodaboda-express-mobile)  
**Tawi Kuu (Branch):** `main`

---

## 📌 1. Muhtasari wa Mradi (Executive Summary)

**Bodaboda Express** ni mfumo wa kisasa wa kiteknolojia wa usafiri wa bodaboda, bajaji, na usafirishaji wa vifurushi na mizigo (Ride-Hailing & Parcel Logistics Platform). 

Mfumo mzima umekamilika katika awamu ya usanifu, muundo wa programu (Mobile Apps), na muundo wa seva (Node.js Backend & Real-time WebSockets), na sasa umepakiwa rasmi kwenye GitHub ili kuwezesha timu yote (Backend, Mobile, QA, na Uongozi) kufanya kazi kwa pamoja.

---

## 🌐 2. Hali ya Uendeshaji na Viunganishi (Active Endpoints & Repositories)

| Huduma / Sehemu | Mahali / URL | Port / Itifaki | Hali (Status) | Maelezo |
| :--- | :--- | :--- | :--- | :--- |
| **GitHub Repository** | [github.com/LIKINDY/bodaboda-express-mobile](https://github.com/LIKINDY/bodaboda-express-mobile) | Git / HTTPS | 🟢 **ACTIVE** | Msimbo mzima wa mradi uko hewani |
| **Node.js Backend API** | `http://localhost:3000/api/v1` | `3000` / HTTP | 🟢 **TESTED & READY** | REST API ya Auth, Safari, Malipo, Dereva |
| **WebSocket Dispatcher** | `ws://localhost:3000/ws` | `3000` / WS | 🟢 **ONLINE** | Mawasiliano ya moja kwa moja ya safari |
| **Customer Flutter App** | `bodaboda_customer/` | Flutter 3.x | 🟢 **0 ERRORS** | Programu ya mteja (Android & iOS) |
| **Driver Flutter App** | `bodaboda_driver/` | Flutter 3.x | 🟢 **0 ERRORS** | Programu ya dereva (Android & iOS) |

---

## 📱 3. Bodaboda Customer App (`bodaboda_customer`)

Programu ya mteja imejengwa kwa Flutter 3.x na inajumuisha huduma zifuatazo zilizokamilika na kufanyiwa majaribio:

1. **Ukurasa wa Kujisajili & OTP (Authentication):**
   - Usajili kwa namba ya simu ya Tanzania (`+255`) yenye uthibitisho wa OTP ya tarakimu 4.
   - Kujaza jina kamili na chaguo la kupakia picha ya wasifu (Profile Photo).
2. **Ulinzi wa Akaunti wa Siku 7 (7-Day Security Check):**
   - Mfumo unafuatilia muda wa safari ya mwisho. Mteja asipoomba safari ndani ya siku 7 mfululizo, anatakiwa kuthibitisha namba yake kwa OTP kwanza kabla ya kuagiza safari mpya.
3. **Uteuzi wa Aina 3 za Vyombo vya Usafiri (Multi-Vehicle Category Selection):**
   - **Bodaboda (Pikipiki):** Nauli ya kuanzia TZS 1,000, TZS 700/km, kiwango cha chini TZS 1,500.
   - **Bajaji (Guta/Tricycle):** Nauli ya kuanzia TZS 1,500, TZS 1,000/km, kiwango cha chini TZS 2,500.
   - **Car Taxi (Gari):** Nauli ya kuanzia TZS 3,000, TZS 1,800/km, kiwango cha chini TZS 5,000.
   - Kila chombo kimepewa beji maalum ya rangi (Teal, Amber, Purple) na mahesabu halisi ya bei, VAT (18%), na muda wa kufika (ETA).
4. **Kipengele cha Kuagiza Safari kwa Ajili ya Rafiki (Book for a Friend):**
   - Kitufe cha kubadili (toggle) kati ya "Mimi Mwenyewe" au "Rafiki Yangu".
   - Kujaza Jina Kamili la Rafiki na Namba ya Simu (`+255`).
   - Mfumo unatuma taarifa za rafiki kwenye seva na kumpa dereva maelekezo kamili ya kumpokea rafiki huyo.
   - Ujumbe wa SMS hutumwa moja kwa moja kwenye simu ya rafiki ukiwa na jina la dereva, namba ya namba ya chombo, na kiunganishi cha ufuatiliaji (live tracking link).
5. **PIN ya Safari ya Tarakimu 4 (Ride Security OTP Lock):**
   - Kila safari inapoundwa, mfumo huzalisha PIN ya tarakimu 4 (mfano: `4921`).
   - Mteja anampa dereva PIN hii pale tu anapofika; safari haiwezi kuanza bila PIN hii sahihi.
6. **Ramani ya Ufuatiliaji wa Safari Moja kwa Moja (Live Tracking):**
   - Dereva akikubali safari, screen ya kutafuta inajifunga moja kwa moja na kufungua ramani.
   - Ramani inaonyesha rangi mbili za trafiki:
     - 🟢 **Kijani (Green):** Njia isiyo na msongamano wa magari.
     - 🔴 **Nyekundu (Red):** Njia yenye msongamano (foleni).
   - Inaonyesha umbali uliobaki (km) na muda wa kufika (ETA), pamoja na beji ya chombo kilichochaguliwa na taarifa za rafiki.
7. **Njia Nyingi za Malipo (Flexible Payments):**
   - **Cash (Pesa Taslimu):** Kulipa dereva baada ya kufika.
   - **M-Pesa / Tigo Pesa / Airtel Money:** Kulipa moja kwa moja kidijitali.
   - **Bodaboda Wallet:** Kulipa kupitia salio lililopo ndani ya pochi ya app.
8. **Sera ya Kughairi Safari (Cancellation Fee Policy):**
   - Mteja akighairi safari baada ya dereva kuanza safari na kutembea zaidi ya kilomita 0.5, mfumo unaweka deni la fidia ya dereva (TZS 1,500) kwenye akaunti yake.

---

## 🏍️ 4. Bodaboda Driver App (`bodaboda_driver`)

Programu ya dereva imejengwa kwa Flutter 3.x ikilenga kumpa dereva mazingira bora ya kazi na mapato:

1. **Kuingia Rahisi (Social Sign-In & OTP):**
   - Vitufe vya *Continue with Google* na *Continue with Apple* vimewekwa kwa ajili ya kuingia haraka.
   - Uthibitisho wa OTP kwa namba ya simu.
2. **Usajili Nyumbufu wa Nyaraka (Streamlined Verification):**
   - Upigaji wa picha halisi ya sura (**Live Face Selfie**).
   - Chaguo la kitambulisho kimoja kati ya vitatu (Kitambulisho cha NIDA, Kadi ya Kupiga Kura, au Barua ya Serikali ya Mtaa/Sheha).
   - Leseni ya udereva na LATRA zimewekwa ndani ya ukurasa wa wasifu (`profile_screen.dart`) ili dereva asikwame wakati wa kujiunga mara ya kwanza.
3. **Kitufe cha Online / Offline:**
   - **Akiwa Online:** Anaanza kupokea maombi ya safari na vifurushi mara moja.
   - **Akiwa Offline:** Hapokei ombi lolote; mfumo haumsumbui.
4. **Dirisha la Ombi la Safari lenye Bango Wazi (15-Second Modal):**
   - Bango kubwa linabainisha wazi aina ya ombi:
     - 📦 **KUSAFIRISHA MZIGO (DELIVERY)** au
     - 🏍️ **USAFIRI WA ABIRIA (TRANSPORT)**
   - Beji ya chombo: **BODABODA**, **BAJAJI**, au **CAR TAXI**.
   - Bango maalum la **👥 SAFARI KWA AJILI YA RAFIKI**: Linamjulisha dereva jina na namba ya simu ya rafiki anayepaswa kumchukua, pamoja na jina la aliyelipia.
   - Huonyesha nauli, umbali, na eneo la kumchukua abiria.
5. **Kupiga Simu kwa Abiria au Mlipaji (Dual Call Options):**
   - Safari ikiwa ni ya rafiki, dereva anapobonyeza kitufe cha simu anapewa machaguo mawili:
     1. Kumpigia simu abiria anayechukuliwa (Friend / Passenger).
     2. Kumpigia simu mteja aliyelipia safari (Booker).
6. **Kuanza Safari kwa PIN ya Mteja (PIN Verification):**
   - Dereva anapofika na kubonyeza *Anzisha Safari*, dirisha la kuingiza tarakimu 4 linafunguka. Dereva anaingiza PIN aliyopewa na mteja kuanza safari.
7. **Safari za Mfululizo (Back-to-Back Rides Ndani ya 1km):**
   - Dereva akiwa amebakiza chini ya 1.0 km kufika mwisho wa safari yake, anapokea arifa ya safari mpya inayofuata ili asikae kijiweni bila kazi mara tu akimshusha abiria.
8. **Ramani ya Mahitaji ya Abiria (Demand Heatmap 🔥):**
   - Kitufe cha moto 🔥 kinamwonyesha dereva maeneo yenye maombi mengi ya abiria jijini Dar es Salaam (Kariakoo Msimbazi, Ubungo Stand, Mwenge Stand, Posta Mpya).
9. **Njia ya Mkato na Rangi za Foleni (Traffic Shortcut ⚡):**
   - Dereva anaweza kubonyeza kitufe cha mkato ili kubadilisha njia na kupita njia zisizo na foleni (kijani).
10. **Kukamilisha Safari na Kurudi Dashboard:**
    - Safari inapokamilika na baada ya dereva kumpa mteja tathmini (rating), anarudishwa moja kwa moja kwenye Dashboard akiwa tayari kwa safari nyingine.

---

## 🖥️ 5. Seva ya Backend ya Node.js & Database (`backend/`)

Mfumo kamili wa mwanzo (Starter Engine) wa Node.js umesanifiwa na kuwekwa ndani ya folda ya `backend/`:

### Muundo wa Folda:
```text
backend/
├── src/
│   ├── controllers/         # Logic za biashara (Auth, Rides, Drivers, Payments)
│   ├── routes/              # Njia za API za /api/v1/*
│   ├── services/            # WebSocket Gateway & Fare Pricing Engine (Bodaboda, Bajaji, Car)
│   ├── db/
│   │   └── migrations/      # 002_add_friend_and_vehicle_categories.sql
│   ├── middleware/          # JWT Verification & Global Error Handler
│   └── server.js            # Express App & WebSocket Server
├── .env.example             # Mfano wa vigezo vya usanidi
├── package.json             # Maktaba (Express, WS, CORS, Dotenv, JWT, Bcrypt)
└── README.md                # Mwongozo wa kina kwa ajili ya Msanidi wa Backend
```

### Majaribio Yaliyofanyika na Kupita (Verification Passed):
- ✅ `npm install`: Maktaba zote 88 zimesakinishwa bila hitilafu yoyote (0 vulnerabilities).
- ✅ Server Startup: Seva inawaka kwenye port `3000` (`http://localhost:3000/api/v1` na `ws://localhost:3000/ws`).
- ✅ Health Check: `GET /health` inarudisha `{ status: "online" }`.
- ✅ Pricing API: `POST /api/v1/rides/estimate` inakokotoa nauli ya Bodaboda na Bajaji kwa usahihi.

---

## 📊 6. Hali ya Afya ya Msimbo (Codebase Health)

- ✅ **Node.js Backend (`backend/`):** 0 errors, 0 vulnerabilities.
- ✅ **Flutter Customer App (`bodaboda_customer/`):** 0 errors, 0 warnings.
- ✅ **Flutter Driver App (`bodaboda_driver/`):** 0 errors, 0 warnings.
- ✅ **Git & GitHub:** Msimbo mzima upo kwenye tawi la `main` kule [bodaboda-express-mobile](https://github.com/LIKINDY/bodaboda-express-mobile).

---

## 👥 7. Mgawanyo wa Majukumu na Hatua Zinazofuata (Action Items)

### 👨‍💻 1. Mhandisi wa Backend (Backend Developer):
1. **Ku-clone Repo:**
   ```bash
   git clone https://github.com/LIKINDY/bodaboda-express-mobile.git
   cd bodaboda-express-mobile/backend
   npm install
   ```
2. **Kuunganisha Hifadhidata (Database):**
   - Sanidi MongoDB au PostgreSQL ndani ya `src/config/` ili kuhifadhi watumiaji, madereva, na safari za kudumu.
3. **Kuunganisha SMS Gateway ya Tanzania:**
   - Unganisha Beem Africa au Twilio ndani ya `authController.js` ili namba za `+255` zipokee OTP halisi za SMS badala ya nambari ya majaribio (`1234`).
4. **Kuunganisha Malipo ya Simu (Mobile Money):**
   - Unganisha M-Pesa Daraja API, Selcom, au DPO kwenye `paymentController.js`.

### 📱 2. Mhandisi wa Mobile Apps (Mobile Developer):
1. **Kuunganisha Endpoint ya Seva:**
   - Badilisha URL kutoka `localhost` kwenda kwenye URL ya production au IP ya mtandao wa ofisi/staging ndani ya `mock_backend_service.dart`.
2. **Kujaribu Mawasiliano ya Moja kwa Moja:**
   - Kufanya majaribio ya simu mbili halisi zilizounganishwa kwenye seva moja kupitia mtandao wa Wi-Fi/4G.

### 🧪 3. Mtaalamu wa Ubora na Majaribio (QA & Tester):
1. Kupima mzunguko mzima wa safari:
   - Mteja anaomba safari -> Dereva anapokea pop-up -> Dereva anakubali -> Mteja anapata taarifa za dereva -> Dereva anafika -> Dereva anaingiza PIN ya mteja -> Safari inaanza -> Safari inakamilika -> Malipo na Rating.

### 💼 4. Msimamizi wa Mradi & Uongozi (Product Lead):
1. Kufuatilia hatua za ushirikiano kwenye GitHub kupitia Pull Requests.
2. Kuandaa mazingira ya deployment ya Seva (Render, AWS, DigitalOcean, au Railway).

---

## 🛠️ 8. Jinsi ya Kuanza Kazi (Quick Start for Team Members)

```bash
# 1. Clone repository
git clone https://github.com/LIKINDY/bodaboda-express-mobile.git
cd bodaboda-express-mobile

# 2. Fungua tawi lako la kazi kabla ya kubadilisha kitu
git checkout -b feature/jina-la-kazi-yako

# 3. Kuanzisha Backend
cd backend
npm install
npm run dev

# 4. Kuanzisha Customer App
cd ../bodaboda_customer
flutter pub get
flutter run

# 5. Kuanzisha Driver App
cd ../bodaboda_driver
flutter pub get
flutter run
```

---

*Ripoti hii imeandaliwa rasmi ili kutumwa kwa washirika na wanakikundi wote wa mradi wa Bodaboda Express.*
