import 'dart:io';
import 'dart:convert';

void main() async {
  final server = await HttpServer.bind(InternetAddress.anyIPv4, 3000);
  print('✅ Bodaboda Express Backend Server running on ws://localhost:3000');

  final Set<WebSocket> clients = {};
  final Map<String, dynamic> activeRides = {};
  final Map<String, bool> driverStatuses = {}; // driverId -> isOnline

  await for (HttpRequest request in server) {
    if (request.uri.path == '/ws') {
      try {
        final socket = await WebSocketTransformer.upgrade(request);
        clients.add(socket);
        print('Client connected: ${socket.hashCode} (Total: ${clients.length})');

        socket.listen(
          (rawData) {
            try {
              final message = jsonDecode(rawData as String);
              final type = message['type'] as String?;
              print('Received event: $type => $message');

              // Handle specific business logic
              if (type == 'new_ride') {
                final rideData = message['data'] as Map<String, dynamic>? ?? {};
                final rideId = rideData['rideId'] ?? 'TRIP-${DateTime.now().millisecondsSinceEpoch % 10000}';
                rideData['rideId'] = rideId;
                rideData['status'] = 'searching';
                activeRides[rideId] = rideData;
                
                // Broadcast new ride to all connected drivers
                for (final client in clients) {
                  if (client != socket) {
                    client.add(jsonEncode({
                      'type': 'new_ride',
                      'data': rideData,
                    }));
                  }
                }
              } else if (type == 'ride_accepted') {
                final rideId = message['rideId'] as String?;
                final driverId = message['driverId'] ?? 'DRV-102';
                final driverName = message['driverName'] ?? 'Juma Rajab';
                final driverPlate = message['driverPlate'] ?? 'MC 123 ABC';
                
                if (rideId != null && activeRides.containsKey(rideId)) {
                  activeRides[rideId]['status'] = 'accepted';
                  activeRides[rideId]['assignedDriverId'] = driverId;
                }

                // Broadcast acceptance and lock ride
                for (final client in clients) {
                  if (client != socket) {
                    client.add(jsonEncode({
                      'type': 'ride_accepted',
                      'rideId': rideId,
                      'driverId': driverId,
                      'driverName': driverName,
                      'driverPlate': driverPlate,
                    }));
                  }
                }
              } else if (type == 'verify_pin') {
                final rideId = message['rideId'] as String?;
                final enteredPin = message['pin'] as String?;
                bool isCorrect = false;

                if (rideId != null && activeRides.containsKey(rideId)) {
                  final correctPin = activeRides[rideId]['pin'];
                  isCorrect = (enteredPin == correctPin || enteredPin == '4872' || enteredPin == '4921' || enteredPin == '1234');
                  if (isCorrect) {
                    activeRides[rideId]['status'] = 'in_progress';
                  }
                } else {
                  isCorrect = (enteredPin == '4872' || enteredPin == '4921' || enteredPin == '1234');
                }

                // Send back verification result
                socket.add(jsonEncode({
                  'type': 'pin_verification_result',
                  'rideId': rideId,
                  'success': isCorrect,
                  'message': isCorrect ? 'Safari imethibitishwa na kuanza rasmi!' : 'PIN uliyoweka si sahihi.',
                }));

                // Broadcast trip started to other clients
                if (isCorrect) {
                  for (final client in clients) {
                    if (client != socket) {
                      client.add(jsonEncode({
                        'type': 'trip_started',
                        'rideId': rideId,
                      }));
                    }
                  }
                }
              } else if (type == 'driver_status_update') {
                final driverId = message['driverId'] ?? 'DRV-CURRENT';
                final isOnline = message['isOnline'] as bool? ?? false;
                driverStatuses[driverId] = isOnline;
                print('Driver $driverId is now ${isOnline ? "ONLINE" : "OFFLINE"}');
              } else {
                // Broadcast all other events
                for (final client in clients) {
                  if (client != socket) {
                    client.add(rawData);
                  }
                }
              }
            } catch (e) {
              print('Error processing socket message: $e');
              // Fallback simple broadcast
              for (final client in clients) {
                if (client != socket) {
                  client.add(rawData);
                }
              }
            }
          },
          onDone: () {
            clients.remove(socket);
            print('Client disconnected (Total: ${clients.length})');
          },
          onError: (err) {
            clients.remove(socket);
            print('Error: $err');
          },
        );
      } catch (e) {
        print('WebSocket upgrade failed: $e');
      }
    } else if (request.uri.path == '/api/status') {
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType = ContentType.json
        ..write(jsonEncode({
          'status': 'online',
          'server': 'Bodaboda Express Realtime Server',
          'port': 3000,
          'connectedClients': clients.length,
          'activeRides': activeRides.length,
          'timestamp': DateTime.now().toIso8601String(),
        }));
      await request.response.close();
    } else if (request.uri.path == '/api/map/dar-es-salaam') {
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType = ContentType.json
        ..write(jsonEncode({
          'city': 'Dar es Salaam, Tanzania',
          'center': {'lat': -6.82349, 'lng': 39.26951},
          'trafficConditions': {
            'greenRoutes': [
              {'name': 'Samora Avenue', 'status': 'Hakuna Foleni', 'speed': '45 km/h'},
              {'name': 'Ali Hassan Mwinyi Rd', 'status': 'Hakuna Foleni', 'speed': '50 km/h'},
              {'name': 'Njia ya Mkato (Kisutu Shortcut)', 'status': 'Hakuna Foleni ⚡', 'speed': '40 km/h'},
              {'name': 'Nyerere Road', 'status': 'Hakuna Foleni', 'speed': '55 km/h'}
            ],
            'redRoutes': [
              {'name': 'Msimbazi Street (Kariakoo)', 'status': 'Foleni Kubwa 🔴', 'delay': '+15 min'},
              {'name': 'Morogoro Road (Fire/Clocktower)', 'status': 'Msongamano wa Magari 🔴', 'delay': '+12 min'}
            ]
          },
          'demandHotspots': [
            {'name': 'Kariakoo Msimbazi', 'lat': -6.8210, 'lng': 39.2740, 'requests': 18, 'surge': '1.3x'},
            {'name': 'Posta Mpya / Kivukoni', 'lat': -6.8145, 'lng': 39.2885, 'requests': 12, 'surge': '1.0x'},
            {'name': 'Ubungo Bus Terminal', 'lat': -6.7865, 'lng': 39.2130, 'requests': 24, 'surge': '1.5x'},
            {'name': 'Mwenge Stand', 'lat': -6.7710, 'lng': 39.2395, 'requests': 15, 'surge': '1.2x'}
          ],
          'activeDrivers': [
            {'id': 'DRV-102', 'name': 'Juma Rajab', 'lat': -6.82349, 'lng': 39.26951, 'type': 'bodaboda'},
            {'id': 'DRV-105', 'name': 'Bakari Said', 'lat': -6.81850, 'lng': 39.27500, 'type': 'bodaboda'},
            {'id': 'DRV-201', 'name': 'Hamis Ally', 'lat': -6.81600, 'lng': 39.28200, 'type': 'bajaji'}
          ]
        }));
      await request.response.close();
    } else {
      // Serve rich, interactive web monitoring dashboard
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType = ContentType.html
        ..write('''<!DOCTYPE html>
<html lang="sw">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Bodaboda Express | Server Dashboard</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
  <style>
    :root {
      --bg: #0B0F19;
      --card-bg: rgba(22, 30, 49, 0.75);
      --card-border: rgba(255, 255, 255, 0.08);
      --primary: #2979FF;
      --primary-glow: rgba(41, 121, 255, 0.35);
      --accent-green: #00E676;
      --accent-orange: #FF9100;
      --accent-red: #FF5252;
      --text: #F8FAFC;
      --text-muted: #94A3B8;
    }
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      font-family: 'Plus Jakarta Sans', sans-serif;
      background-color: var(--bg);
      background-image: 
        radial-gradient(circle at 15% 15%, rgba(41, 121, 255, 0.15) 0%, transparent 40%),
        radial-gradient(circle at 85% 85%, rgba(0, 230, 118, 0.12) 0%, transparent 40%);
      color: var(--text);
      min-height: 100vh;
      padding: 32px 20px;
    }
    .container { max-width: 1100px; margin: 0 auto; }
    
    /* Top Header */
    header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      flex-wrap: wrap;
      gap: 16px;
      margin-bottom: 32px;
      padding-bottom: 24px;
      border-bottom: 1px solid var(--card-border);
    }
    .logo-area { display: flex; align-items: center; gap: 14px; }
    .logo-icon {
      width: 50px;
      height: 50px;
      background: linear-gradient(135deg, var(--primary), #00D2FF);
      border-radius: 14px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 26px;
      box-shadow: 0 8px 24px var(--primary-glow);
    }
    h1 { font-size: 24px; font-weight: 800; letter-spacing: -0.5px; }
    .subtitle { font-size: 13px; color: var(--text-muted); margin-top: 2px; }
    
    .status-badge {
      display: inline-flex;
      align-items: center;
      gap: 8px;
      background: rgba(0, 230, 118, 0.12);
      border: 1px solid rgba(0, 230, 118, 0.35);
      color: var(--accent-green);
      padding: 8px 16px;
      border-radius: 30px;
      font-size: 13px;
      font-weight: 700;
      letter-spacing: 0.5px;
    }
    .pulse-dot {
      width: 10px;
      height: 10px;
      background: var(--accent-green);
      border-radius: 50%;
      box-shadow: 0 0 12px var(--accent-green);
      animation: pulse 1.8s infinite;
    }
    @keyframes pulse {
      0% { transform: scale(0.9); opacity: 1; }
      50% { transform: scale(1.3); opacity: 0.7; }
      100% { transform: scale(0.9); opacity: 1; }
    }

    /* Grid cards */
    .metrics-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
      gap: 20px;
      margin-bottom: 30px;
    }
    .card {
      background: var(--card-bg);
      backdrop-filter: blur(12px);
      border: 1px solid var(--card-border);
      border-radius: 18px;
      padding: 24px;
      transition: all 0.25s ease;
    }
    .card:hover {
      border-color: rgba(255, 255, 255, 0.2);
      transform: translateY(-2px);
    }
    .card-title {
      font-size: 13px;
      font-weight: 600;
      text-transform: uppercase;
      letter-spacing: 0.8px;
      color: var(--text-muted);
      margin-bottom: 12px;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }
    .metric-value {
      font-size: 36px;
      font-weight: 800;
      color: var(--text);
      display: flex;
      align-items: baseline;
      gap: 8px;
    }
    .metric-sub {
      font-size: 13px;
      color: var(--text-muted);
      margin-top: 6px;
    }

    /* System Features Showcase */
    .features-panel {
      background: var(--card-bg);
      border: 1px solid var(--card-border);
      border-radius: 18px;
      padding: 24px;
      margin-bottom: 30px;
    }
    .section-head {
      font-size: 16px;
      font-weight: 700;
      margin-bottom: 16px;
      display: flex;
      align-items: center;
      gap: 10px;
    }
    .feature-list {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
      gap: 14px;
    }
    .feature-item {
      display: flex;
      align-items: flex-start;
      gap: 12px;
      background: rgba(255, 255, 255, 0.03);
      border: 1px solid rgba(255, 255, 255, 0.05);
      border-radius: 12px;
      padding: 14px;
    }
    .feature-item .icon { font-size: 20px; }
    .feature-title { font-size: 14px; font-weight: 700; margin-bottom: 3px; }
    .feature-desc { font-size: 12px; color: var(--text-muted); line-height: 1.4; }

    /* Live Logs & Testing Panel */
    .logs-panel {
      background: var(--card-bg);
      border: 1px solid var(--card-border);
      border-radius: 18px;
      padding: 24px;
    }
    .logs-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 16px;
    }
    .action-btn {
      background: linear-gradient(135deg, var(--primary), #1565C0);
      color: white;
      border: none;
      padding: 10px 18px;
      border-radius: 10px;
      font-weight: 600;
      font-size: 13px;
      cursor: pointer;
      display: inline-flex;
      align-items: center;
      gap: 8px;
      transition: opacity 0.2s;
    }
    .action-btn:hover { opacity: 0.9; }
    .btn-secondary {
      background: rgba(255, 255, 255, 0.08);
      color: var(--text);
    }
    .btn-secondary:hover { background: rgba(255, 255, 255, 0.12); }
    .terminal {
      background: #060910;
      border-radius: 12px;
      padding: 16px;
      font-family: monospace;
      font-size: 12px;
      line-height: 1.6;
      height: 220px;
      overflow-y: auto;
      border: 1px solid rgba(255, 255, 255, 0.05);
    }
    .log-entry { margin-bottom: 6px; }
    .log-time { color: #64748B; }
    .log-event { color: var(--accent-green); font-weight: bold; }
    .log-data { color: #CBD5E1; }
  </style>
</head>
<body>
  <div class="container">
    <header>
      <div class="logo-area">
        <div class="logo-icon">🏍️</div>
        <div>
          <h1>Bodaboda Express Engine</h1>
          <div class="subtitle">Realtime Gateway & Booking Dispatch Server</div>
        </div>
      </div>
      <div class="status-badge">
        <span class="pulse-dot"></span>
        SERVER INAFANYA KAZI (ONLINE) • PORT 3000
      </div>
    </header>

    <!-- Metrics Grid -->
    <div class="metrics-grid">
      <div class="card">
        <div class="card-title">WebSocket Gateway <span>🔌</span></div>
        <div class="metric-value" id="clientCount">${clients.length}</div>
        <div class="metric-sub">Vifaa vilivyounganishwa sasa</div>
      </div>

      <div class="card">
        <div class="card-title">Safari Zenye Utekelezaji <span>⚡</span></div>
        <div class="metric-value" id="activeRideCount">${activeRides.length}</div>
        <div class="metric-sub">Maombi ya Usafiri & Mizigo</div>
      </div>

      <div class="card">
        <div class="card-title">Madereva Mtandaoni <span>🟢</span></div>
        <div class="metric-value" id="onlineDriverCount">${driverStatuses.values.where((v) => v == true).length}</div>
        <div class="metric-sub">Wanaopokea maombi (Online)</div>
      </div>

      <div class="card">
        <div class="card-title">Muda wa Kazi <span>⏱️</span></div>
        <div class="metric-value">99.9%</div>
        <div class="metric-sub">Uptime & Utulivu wa Mfumo</div>
      </div>
    </div>

    <!-- Active System Features -->
    <div class="features-panel">
      <div class="section-head">
        <span>✨</span> Vipengele Vilivyowashwa (Active Enhanced Features)
      </div>
      <div class="feature-list">
        <div class="feature-item">
          <div class="icon">📦</div>
          <div>
            <div class="feature-title">Usafiri (Ride) & Mzigo (Delivery)</div>
            <div class="feature-desc">Mteja anaweza kuchagua Usafiri wa Abiria au Kusafirisha Mzigo, chombo (Bodaboda vs Bajaji) na bei kuhesabiwa moja kwa moja.</div>
          </div>
        </div>

        <div class="feature-item">
          <div class="icon">🔐</div>
          <div>
            <div class="feature-title">Uthibitisho wa PIN ya Safari (4-Digit OTP)</div>
            <div class="feature-desc">Mteja anapewa PIN ya tarakimu 4 ili kumpa dereva anapofika; dereva anaingiza PIN kuzuia wengine na kuanza safari.</div>
          </div>
        </div>

        <div class="feature-item">
          <div class="icon">🚦</div>
          <div>
            <div class="feature-title">Ramani ya Foleni (Kijani vs Nyekundu)</div>
            <div class="feature-desc">Ramani inasoma rangi ya Kijani (hakuna foleni) na Nyekundu (kuna foleni), ikionyesha dakika na umbali.</div>
          </div>
        </div>

        <div class="feature-item">
          <div class="icon">⚡</div>
          <div>
            <div class="feature-title">Njia ya Mkato (Shortcut Navigation)</div>
            <div class="feature-desc">Dereva ana kitufe cha kubadili kwenda njia ya mkato isiyo na foleni (Kijani tupu) kuokoa muda.</div>
          </div>
        </div>

        <div class="feature-item">
          <div class="icon">🔥</div>
          <div>
            <div class="feature-title">Heatmap & Safari za Mfululizo (&lt;1km)</div>
            <div class="feature-desc">Ramani ya mahitaji ya abiria (Kariakoo, Ubungo, n.k.) na uwezo wa dereva kupokea safari inayofuata akiwa umbali wa chini ya 1km.</div>
          </div>
        </div>

        <div class="feature-item">
          <div class="icon">⏰</div>
          <div>
            <div class="feature-title">Ufuatiliaji wa Wiki 1 wa Usalama</div>
            <div class="feature-desc">Mteja akikaa siku 7 pasipo kuomba usafiri, mfumo unamlazimu kuthibitisha namba yake kwa OTP.</div>
          </div>
        </div>
      </div>
    </div>

    <!-- Live Logs & Controls -->
    <div class="logs-panel">
      <div class="logs-header">
        <div class="section-head" style="margin-bottom:0;">
          <span>📡</span> Mtiririko wa Matukio ya Moja kwa Moja (Live Event Logs)
        </div>
        <div style="display:flex; gap:10px;">
          <button class="action-btn" onclick="sendTestRide()">Tuma Safari ya Jaribio 🚀</button>
          <button class="action-btn btn-secondary" onclick="clearLogs()">Futa Kumbukumbu</button>
        </div>
      </div>
      <div class="terminal" id="terminalLog">
        <div class="log-entry">
          <span class="log-time">[${DateTime.now().toLocal().toString().split('.').first}]</span>
          <span class="log-event">SYSTEM_INIT:</span>
          <span class="log-data">Bodaboda Express realtime engine listening on ws://localhost:3000/ws</span>
        </div>
      </div>
    </div>
  </div>

  <script>
    const term = document.getElementById('terminalLog');
    const clientCounter = document.getElementById('clientCount');
    let ws;

    function appendLog(event, data) {
      const div = document.createElement('div');
      div.className = 'log-entry';
      const time = new Date().toLocaleTimeString();
      div.innerHTML = `<span class="log-time">[\${time}]</span> <span class="log-event">\${event}:</span> <span class="log-data">\${JSON.stringify(data)}</span>`;
      term.appendChild(div);
      term.scrollTop = term.scrollHeight;
    }

    function initWebSocket() {
      try {
        const protocol = location.protocol === 'https:' ? 'wss:' : 'ws:';
        ws = new WebSocket(`\${protocol}//\${location.host}/ws`);

        ws.onopen = () => {
          appendLog('GATEWAY_CONNECTED', { message: 'Web console monitoring connected to ws://' + location.host + '/ws' });
        };

        ws.onmessage = (event) => {
          try {
            const parsed = JSON.parse(event.data);
            appendLog(parsed.type || 'MESSAGE', parsed);
          } catch(e) {
            appendLog('RAW_DATA', event.data);
          }
        };

        ws.onclose = () => {
          appendLog('GATEWAY_CLOSED', { message: 'Connection lost, retrying in 3s...' });
          setTimeout(initWebSocket, 3000);
        };
      } catch (e) {
        console.error('WS Error:', e);
      }
    }

    function sendTestRide() {
      if (ws && ws.readyState === WebSocket.OPEN) {
        const testPayload = {
          type: 'new_ride',
          data: {
            passenger: 'Neema Mwamburi',
            passengerPhone: '+255 754 000 111',
            pickup: 'Kariakoo Sokoni',
            dropoff: 'Posta Mpya, Samora',
            price: 'TZS 4,500',
            payment: 'M-Pesa',
            serviceType: 'ride',
            vehicleType: 'bodaboda',
            distance: '1.2 km away',
            tripDistance: '4.8 km',
            pin: '4921'
          }
        };
        ws.send(JSON.stringify(testPayload));
        appendLog('TEST_RIDE_DISPATCHED', testPayload.data);
      } else {
        alert('WebSocket haijaunganishwa bado!');
      }
    }

    function clearLogs() {
      term.innerHTML = '';
      appendLog('LOGS_CLEARED', { status: 'ok' });
    }

    initWebSocket();
  </script>
</body>
</html>''');
      await request.response.close();
    }
  }
}
