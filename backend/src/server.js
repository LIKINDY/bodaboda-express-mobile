import http from 'http';
import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';

import { initWebSocketServer, activeRides, clients, onlineDrivers } from './services/websocketService.js';
import authRoutes from './routes/authRoutes.js';
import rideRoutes from './routes/rideRoutes.js';
import driverRoutes from './routes/driverRoutes.js';
import paymentRoutes from './routes/paymentRoutes.js';
import { errorHandler } from './middleware/errorHandler.js';

dotenv.config();

const app = express();
const server = http.createServer(app);

// 1. Global Middlewares
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// 2. Health & Status Dashboard
app.get('/health', (req, res) => {
  res.json({
    status: 'online',
    service: 'Bodaboda Express Backend API & WebSocket Server',
    uptime: process.uptime(),
    timestamp: new Date().toISOString()
  });
});

app.get('/', (req, res) => {
  res.send(`
    <!DOCTYPE html>
    <html lang="sw">
    <head>
      <meta charset="UTF-8">
      <title>Bodaboda Express — Seva ya Seva (Backend)</title>
      <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background: #0f172a; color: #f8fafc; padding: 40px; }
        .card { background: #1e293b; border-radius: 12px; padding: 24px; max-width: 700px; margin: 0 auto; box-shadow: 0 10px 25px rgba(0,0,0,0.5); }
        h1 { color: #f59e0b; margin-top: 0; }
        .badge { display: inline-block; padding: 4px 10px; border-radius: 999px; background: #10b981; color: white; font-weight: bold; font-size: 12px; }
        ul { line-height: 1.8; }
        code { background: #334155; padding: 2px 6px; border-radius: 4px; color: #38bdf8; }
      </style>
    </head>
    <body>
      <div class="card">
        <h1>🏍️ Bodaboda Express Backend Gateway</h1>
        <p><span class="badge">ONLINE</span> Port: <code>${process.env.PORT || 3000}</code></p>
        <p>Seva ya WebSocket na REST API inafanya kazi kikamilifu:</p>
        <ul>
          <li><strong>WebSocket Gateway:</strong> <code>ws://localhost:${process.env.PORT || 3000}/ws</code></li>
          <li><strong>Wateja Waliounganishwa (Clients):</strong> ${clients.size}</li>
          <li><strong>Madereva Waliopo Online:</strong> ${onlineDrivers.size}</li>
          <li><strong>Safari Zinazoendelea (Active Rides):</strong> ${activeRides.size}</li>
        </ul>
        <hr style="border-color: #334155; margin: 20px 0;">
        <p><strong>REST API Endpoints:</strong></p>
        <ul>
          <li><code>POST /api/v1/auth/customer/request-otp</code></li>
          <li><code>POST /api/v1/auth/driver/login</code></li>
          <li><code>POST /api/v1/rides/estimate</code></li>
          <li><code>GET /api/v1/drivers/demand-heatmap</code></li>
          <li><code>POST /api/v1/payments/initiate</code></li>
        </ul>
      </div>
    </body>
    </html>
  `);
});

// 3. API Routes
app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/rides', rideRoutes);
app.use('/api/v1/drivers', driverRoutes);
app.use('/api/v1/payments', paymentRoutes);

// 4. Error Handling
app.use(errorHandler);

// 5. Initialize WebSocket Gateway
initWebSocketServer(server);

// 6. Start Server
const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`\n======================================================`);
  console.log(`🚀 Bodaboda Express Backend is running on port ${PORT}`);
  console.log(`📡 WebSocket URL: ws://localhost:${PORT}/ws`);
  console.log(`🌐 HTTP REST API: http://localhost:${PORT}/api/v1`);
  console.log(`======================================================\n`);
});
