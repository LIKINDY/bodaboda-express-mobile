# 🏍️ Bodaboda Express — Ripoti Rasmi ya Hali ya Mradi (Project Status Report)
*Imeandaliwa na kusasishwa: Likindy Ismail & Antigravity*
*Tarehe ya Sasisho: Oktoba 2026*

---

## 📌 1. Muhtasari wa Mradi (Executive Summary)
**Bodaboda Express** ni mfumo kamili wa usafiri wa bodaboda, bajaji, na usafirishaji wa mizigo na vifurushi (Ride-hailing & Parcel Delivery Platform). Mfumo huu unajumuisha programu tatu (3) kuu zinazofanya kazi kwa ushirikiano wa moja kwa moja kupitia mtandao:

1. **📱 Bodaboda Customer App (`bodaboda_customer`)** — Programu ya mteja ya kuomba usafiri au kusafirisha mizigo, kuona nauli kamili, kuchagua njia za malipo, kupata PIN ya safari, na kufuatilia dereva kwenye ramani yenye rangi za foleni.
2. **🏍️ Bodaboda Driver App (`bodaboda_driver`)** — Programu ya dereva ya kupokea maombi ya safari na vifurushi, kubadili hali ya Online/Offline, kuthibitisha PIN ya mteja kuanza safari, kuona ramani ya mahitaji ya abiria (Heatmap), kutumia njia za mkato (Shortcuts), na kupokea safari za mfululizo akiwa ndani ya 1km.
3. **🖥️ Real-time Backend Engine (`backend/server.dart`)** — Seva ya WebSocket na API inayounganisha wateja na madereva moja kwa moja, kugawa safari, kuthibitisha PIN, na kutoa dashibodi ya ufuatiliaji wa mfumo kwa njia ya mtandao.

---

## 🌐 2. Hali ya Uendeshaji Sasa (Active Live Services)

| Huduma / App | Anwani ya Wavuti (URL) | Port | Hali (Status) | Maelezo |
| :--- | :--- | :--- | :--- | :--- |
| **Backend & WebSocket Gateway** | [http://localhost:3000/](http://localhost:3000/) | `3000` | 🟢 **ONLINE** | WebSocket: `ws://localhost:3000/ws` • Web Monitor & API |
| **Customer Web App** | [http://localhost:8080/](http://localhost:8080/) | `8080` | 🟢 **ONLINE** | App ya Mteja (Usafiri, Mzigo, Ramani ya Foleni) |
| **Driver Web App** | [http://localhost:8081/](http://localhost:8081/) | `8081` | 🟢 **ONLINE** | App ya Dereva (Online/Offline, OTP, Heatmap, Shortcut) |

---

## 📱 3. Bodaboda Customer App (`bodaboda_customer`)
**Mfumo wa Teknolojia:** Flutter 3.x | Dart | GoRouter | Google Maps Flutter | WebSockets | Shared Preferences

### ✅ Vipengele Vilivyoboreshwa na Kukamilika Katika Awamu Hii:
1. **Ukurasa wa Kujisajili (Sign Up Screen):**
   - Sehemu ya **Jina Kamili** la mteja.
   - Chaguo la kupakia **Picha ya Wasifu** (Profile Photo) yenye uhakiki.
   - Namba ya simu ya Tanzania (`+255`) yenye uthibitisho wa OTP.
   - Sera ya usalama ya ukumbusho wa uhakiki wa wiki 1.
2. **Ufuatiliaji wa Usalama wa Siku 7 (7-Day Inactivity Verification):**
   - Huduma ya `UserProfileService` inafuatilia muda wa safari ya mwisho ya mteja.
   - Mteja akikaa zaidi ya wiki moja (siku 7) pasipo kuomba usafiri, mfumo unazuia kuagiza safari na kutoa ujumbe wa kiusalama unaomtaka kuthibitisha namba yake kwa OTP kwanza.
3. **Uteuzi wa Huduma & Aina ya Chombo (Booking & Rides Screen):**
   - **Usafiri wa Abiria (Ride):** Kumpeleka mteja mahali fulani.
   - **Kusafirisha Mzigo (Delivery):** Kusafirisha vifurushi na mizigo.
   - Chaguo la **Bodaboda** au **Bajaji** lenye hesabu halisi ya bei (`estimateFare`) kulingana na eneo na umbali.
4. **Njia Tatu (3) za Malipo:**
   - **Cash (Pesa Mkononi):** Kulipa dereva baada ya kufika.
   - **M-Pesa / Tigo Pesa:** Kutuma moja kwa moja kwa dereva.
   - **Bodaboda Wallet:** Kulipa kupitia pochi ya app.
5. **Uzalishaji wa PIN ya Safari (4-Digit OTP Driver Lock):**
   - Kila safari inapoundwa, mfumo huzalisha PIN ya tarakimu 4 (mfano: `4921`).
   - Mteja anapewa PIN hii ili ampe dereva aliyekubali safari pekee, kuzuia dereva mwingine au mtu mwingine kupora safari.
6. **Mpito wa Moja kwa Moja kwenye Ramani ya Safari (Live Tracking Map):**
   - Dereva akikubali safari, screen ya kumtafuta dereva inajifunga moja kwa moja na kufungua ramani ya safari.
   - Ramani ina rangi mbili za foleni:
     - 🟢 **Kijani (Green):** Njia isiyo na foleni.
     - 🔴 **Nyekundu (Red):** Njia yenye foleni ya magari.
   - Inaonyesha umbali uliobaki (km) na dakika zilizobaki (ETA).
7. **Faini ya Kughairi Safari (Cancellation Fee & Debt):**
   - Mteja akighairi safari baada ya dereva kuanza safari na kutembea zaidi ya kilomita 0.5, mfumo huweka deni la fidia ya dereva (TZS 1,500) kwenye akaunti yake.

---

## 🏍️ 4. Bodaboda Driver App (`bodaboda_driver`)
**Mfumo wa Teknolojia:** Flutter 3.x | Dart | GoRouter | Google Maps Flutter | WebSockets | Riverpod

### ✅ Vipengele Vilivyoboreshwa na Kukamilika Katika Awamu Hii:
1. **Kuingia kwa Kutumia Google & Apple (Social Sign-In):**
   - Vitufe vya *Continue with Google* na *Continue with Apple* vimewekwa kwenye kurasa zote za kuingia za dereva (`driver_login_screen.dart` na `sign_in_screen.dart`).
2. **Upakiaji wa Nyaraka za Usajili (Document Upload):**
   - Picha sasa ni **Live Face Selfie (Sura Halisi)** badala ya picha ya kawaida ya pasipoti.
   - Dereva anachagua **kimoja wapo kati ya vitambulisho vitatu (3)**:
     1. Kitambulisho cha NIDA
     2. Kadi ya Kupiga Kura
     3. Barua ya Serikali ya Mtaa au Sheha
   - Leseni ya Udereva na LATRA zimeondolewa kwenye usajili wa awali ili kuondoa usumbufu wakati wa kujiunga.
3. **Leseni ya Udereva na LATRA Ndani ya Wasifu (Inner Profile):**
   - Ukurasa wa `profile_screen.dart` sasa una sehemu rasmi ya *Nyaraka za Udereva* ya kujaza namba ya Leseni, tarehe ya kuisha, na namba ya cheti cha LATRA.
4. **Kitufe cha Online / Offline (Kuondoa Vitufe vya Zamani vya Transport/Delivery):**
   - Vitufe vya zamani vya Transport na Delivery kwenye dashboard vimeondolewa kabisa.
   - Kitufe kipya cha kisasa cha **Online / Offline** kimeongezwa:
     - **Akiwa Online:** Dereva anaanza kupokea maombi ya safari na mizigo moja kwa moja.
     - **Akiwa Offline:** Mfumo unazuia maombi yote; hapokei pop-up yoyote ya safari.
5. **Pop-up ya Ombi la Safari yenye Bango Wazi (15s Modal):**
   - Pop-up ya safari inaonyesha bango kubwa lililo wazi:
     - 📦 **KUSAFIRISHA MZIGO (DELIVERY)** au
     - 🏍️ **USAFIRI WA ABIRIA (TRANSPORT)**
   - Inaonyesha aina ya chombo (Bodaboda vs Bajaji) na njia ya malipo ya mteja.
6. **Kuanza Safari kwa PIN ya Mteja (Customer OTP Verification):**
   - Dereva anapofika kituoni na kubonyeza *ANZISHA SAFARI*, dirisha la kuweka PIN linafunguka.
   - Dereva lazima aweke tarakimu 4 alizopewa na mteja ili kufungua na kuanzisha safari.
7. **Safari za Mfululizo (Back-to-back Requests Ndani ya 1km):**
   - Dereva akiwa umbali wa chini ya kilomita 1 (<= 1.0 km) kufika mwisho wa safari yake, mfumo unamletea arifa ya ombi la safari inayofuata:
     > *"🔥 OMBI LA SAFARI IJAYO (Umebaki 0.9 km): Abiria Rashid Mwamba • Bodaboda • TZS 4,000"*
   - Dereva akikubali, safari inayofuata inapangwa mara moja ili asikae bila kazi punde atakapomshusha abiria.
8. **Ramani ya Mahitaji ya Abiria (Demand Heatmap 🔥):**
   - Kitufe cha moto 🔥 kwenye upau wa ramani kinamwezesha dereva kuwasha/kuzima ramani ya mahitaji ya abiria.
   - Inaonyesha maeneo yenye maombi mengi ya abiria (Kariakoo Msimbazi, Ubungo Stand, Mwenge Stand, Posta Mpya) yakiwa na duara za mng'ao wa rangi nyekundu na machungwa.
9. **Rangi za Foleni na Njia ya Mkato (Shortcut ⚡):**
   - Ramani inasoma:
     - 🟢 **Kijani:** Sehemu isiyo na foleni.
     - 🔴 **Nyekundu:** Sehemu yenye foleni ya magari.
   - Kitufe cha **Njia ya Mkato ⚡ (Shortcut):** Dereva akibonyeza, ramani inabadilika mara moja kwenda kwenye njia ya mkato isiyo na foleni (kijani tupu) na kupunguza muda wa safari.
10. **Kumaliza Safari bila Ku-logout (Return to Dashboard):**
    - Hitilafu ya dereva kutolewa nje (kwenye splash/login) baada ya kutoa nyota imerekebishwa; sasa anarudi moja kwa moja kwenye `/dashboard`.

---

## 🖥️ 5. Backend Server & WebSocket Dispatcher (`backend/server.dart`)

- **Anwani:** `http://localhost:3000/` | WebSocket: `ws://localhost:3000/ws`
- **Maboresho:**
  - Inasaidia jumbe za aina mpya: `new_ride` (yenye `serviceType`, `pin`, `payment`, `price`), `ride_accepted`, `verify_pin`, na `driver_status_update`.
  - Inatoa dashibodi ya kisasa ya wavuti (Web Monitor) inayoonyesha idadi ya vifaa vilivyounganishwa, safari zinazoendelea, na mtiririko wa matukio ya moja kwa moja (Live Event Logs).

---

## 📊 6. Hali ya Afya ya Msimbo (Codebase Health)

- ✅ **Dart Analysis (`backend/server.dart`):** `No issues found!` (0 errors).
- ✅ **Flutter Analysis (`bodaboda_customer`):** `No errors found!` (0 errors).
- ✅ **Flutter Analysis (`bodaboda_driver`):** `No errors found!` (0 errors).
- ✅ **Mifumo yote mitatu inafanya kazi kwa wakati mmoja (Concurrent Live Execution).**

---

## 🎯 7. Hatua Zinazofuata (Roadmap & Next Steps)
1. **Kuunganisha Huduma ya SMS Halisi:** Kuunganisha SMS Gateway (mfano: Beem Africa, Twilio) kwa ajili ya kutuma OTP halisi kwenye simu za mkononi za wateja na madereva.
2. **Malipo Halisi ya Simu (Mobile Money Integration):** Kuunganisha API za M-Pesa (Vodacom Daraja), Tigo Pesa, na Airtel Money kwa ajili ya makato na malipo ya moja kwa moja ya pochi.
3. **Uchapishaji wa APK & Play Store:** Kufanya compilation ya toleo jipya la APK na Bundle kwa ajili ya majaribio kwenye vifaa halisi vya Android na iOS.
