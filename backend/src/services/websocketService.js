import { WebSocketServer, WebSocket } from 'ws';

// In-memory state for real-time tracking (can be backed by Redis / DB in production)
const clients = new Set();
const activeRides = new Map();
const onlineDrivers = new Map(); // socket -> driverProfile

export function initWebSocketServer(server) {
  const wss = new WebSocketServer({ server, path: '/ws' });

  wss.on('connection', (socket, req) => {
    clients.add(socket);
    console.log(`🔌 [WebSocket] Client connected: (Total clients: ${clients.size})`);

    socket.on('message', (rawData) => {
      try {
        const message = JSON.parse(rawData.toString());
        const { type } = message;

        console.log(`📩 [WebSocket] Event received: ${type}`);

        switch (type) {
          case 'new_ride':
            handleNewRide(socket, message.data);
            break;

          case 'ride_accepted':
            handleRideAccepted(socket, message);
            break;

          case 'driver_status_update':
            handleDriverStatusUpdate(socket, message);
            break;

          case 'location_update':
            handleLocationUpdate(socket, message);
            break;

          case 'verify_pin':
            handleVerifyPin(socket, message);
            break;

          case 'ride_completed':
            handleRideCompleted(socket, message);
            break;

          default:
            console.log(`⚠️ Unknown event type: ${type}`);
        }
      } catch (err) {
        console.error('❌ Error handling WebSocket message:', err.message);
        socket.send(JSON.stringify({ type: 'error', message: 'Invalid JSON message' }));
      }
    });

    socket.on('close', () => {
      clients.delete(socket);
      onlineDrivers.delete(socket);
      console.log(`🔌 [WebSocket] Client disconnected: (Remaining: ${clients.size})`);
    });

    socket.on('error', (err) => {
      console.error('❌ WebSocket error:', err.message);
    });

    // Send welcome handshake
    socket.send(JSON.stringify({
      type: 'connection_established',
      message: 'Connected to Bodaboda Express WebSocket Gateway',
      timestamp: new Date().toISOString()
    }));
  });

  return wss;
}

function handleNewRide(customerSocket, rawData) {
  const rideData = rawData || {};
  const rideId = rideData.rideId || `TRIP-${Math.floor(1000 + Math.random() * 9000)}`;
  const otpPin = rideData.otpPin || String(Math.floor(1000 + Math.random() * 9000));

  // Handle Book for a Friend attributes
  const isForFriend = Boolean(rideData.is_for_friend ?? rideData.isForFriend ?? false);
  const friendName = rideData.friend_name || rideData.friendName || rideData.recipient_name || null;
  const friendPhone = rideData.friend_phone || rideData.friendPhone || rideData.recipient_phone || null;
  const vehicleType = (rideData.vehicle_type || rideData.vehicleType || 'bodaboda').toLowerCase();

  const rideRecord = {
    ...rideData,
    rideId,
    otpPin,
    vehicleType,
    isForFriend,
    friendName,
    friendPhone,
    status: 'searching',
    customerSocket,
    createdAt: new Date().toISOString()
  };

  activeRides.set(rideId, rideRecord);

  // Broadcast to all connected driver clients
  let driversNotified = 0;
  for (const client of clients) {
    if (client !== customerSocket && client.readyState === WebSocket.OPEN) {
      client.send(JSON.stringify({
        type: 'new_ride',
        data: {
          rideId,
          pickupAddress: rideRecord.pickupAddress,
          destinationAddress: rideRecord.destinationAddress,
          pickupLatLng: rideRecord.pickupLatLng,
          destinationLatLng: rideRecord.destinationLatLng,
          vehicleType,
          serviceType: rideRecord.serviceType || 'ride',
          fare: rideRecord.fare,
          paymentMethod: rideRecord.paymentMethod,
          customerName: rideRecord.customerName,
          customerPhone: rideRecord.customerPhone,
          isForFriend,
          friendName,
          friendPhone,
          recipient_name: friendName,
          recipient_phone: friendPhone,
          distanceKm: rideRecord.distanceKm || 3.2,
          durationMins: rideRecord.durationMins || 10
        }
      }));
      driversNotified++;
    }
  }

  // Acknowledge back to customer with assigned OTP PIN
  customerSocket.send(JSON.stringify({
    type: 'ride_created',
    data: {
      rideId,
      otpPin,
      status: 'searching',
      isForFriend,
      friendName,
      friendPhone,
      vehicleType,
      driversNotified
    }
  }));

  if (isForFriend && friendPhone) {
    console.log(`📲 [SMS Gateway Dispatch] SMS notification sent to friend ${friendName} (${friendPhone}): "Habari ${friendName}! Rafiki yako ${rideRecord.customerName || 'Mteja'} amekuagizia usafiri wa Bodaboda Express (${vehicleType.toUpperCase()}). PIN ya safari ni ${otpPin}."`);
  }

  console.log(`📢 [Ride Created] ${rideId} [Vehicle: ${vehicleType}, ForFriend: ${isForFriend}] broadcasted to ${driversNotified} driver(s). OTP: ${otpPin}`);
}

function handleRideAccepted(driverSocket, message) {
  const { rideId, driverId, driverName, driverPlate, driverPhone } = message;

  if (!rideId || !activeRides.has(rideId)) {
    driverSocket.send(JSON.stringify({
      type: 'error',
      message: 'Ride not found or already assigned'
    }));
    return;
  }

  const ride = activeRides.get(rideId);
  if (ride.status !== 'searching') {
    driverSocket.send(JSON.stringify({
      type: 'ride_already_taken',
      message: 'Samahani, safari hii imeshachukuliwa na dereva mwingine.'
    }));
    return;
  }

  ride.status = 'accepted';
  ride.assignedDriver = {
    driverId: driverId || 'DRV-101',
    driverName: driverName || 'Juma Rashid',
    driverPlate: driverPlate || 'MC 123 ABC',
    driverPhone: driverPhone || '+255755123456',
    rating: 4.9
  };
  ride.driverSocket = driverSocket;

  // Notify customer
  if (ride.customerSocket && ride.customerSocket.readyState === WebSocket.OPEN) {
    ride.customerSocket.send(JSON.stringify({
      type: 'ride_accepted',
      rideId,
      status: 'accepted',
      driver: ride.assignedDriver
    }));
  }

  // Confirm to accepting driver
  driverSocket.send(JSON.stringify({
    type: 'ride_accept_confirmed',
    rideId,
    rideData: {
      pickupAddress: ride.pickupAddress,
      destinationAddress: ride.destinationAddress,
      pickupLatLng: ride.pickupLatLng,
      destinationLatLng: ride.destinationLatLng,
      customerName: ride.customerName,
      customerPhone: ride.customerPhone,
      isForFriend: ride.isForFriend,
      friendName: ride.friendName,
      friendPhone: ride.friendPhone,
      recipient_name: ride.friendName,
      recipient_phone: ride.friendPhone,
      vehicleType: ride.vehicleType,
      fare: ride.fare,
      paymentMethod: ride.paymentMethod
    }
  }));

  if (ride.isForFriend && ride.friendPhone) {
    console.log(`📲 [SMS Gateway Dispatch] SMS update sent to friend ${ride.friendName} (${ride.friendPhone}): "Dereva ${ride.assignedDriver.driverName} (${ride.assignedDriver.driverPlate}, Simu: ${ride.assignedDriver.driverPhone}) amekubali safari yako ya Bodaboda Express. Yupo njiani!"`);
  }

  // Broadcast to other drivers that this ride is no longer available
  for (const client of clients) {
    if (client !== driverSocket && client.readyState === WebSocket.OPEN) {
      client.send(JSON.stringify({
        type: 'ride_locked',
        rideId
      }));
    }
  }

  console.log(`✅ [Ride Accepted] ${rideId} assigned to driver ${ride.assignedDriver.driverName}`);
}

function handleDriverStatusUpdate(socket, message) {
  const { status, driverId, driverName } = message;
  const isOnline = status === 'online';

  if (isOnline) {
    onlineDrivers.set(socket, { driverId, driverName, isOnline: true });
    console.log(`🟢 [Driver Online] ${driverName || driverId || 'Driver'} is now ONLINE`);
  } else {
    onlineDrivers.delete(socket);
    console.log(`🔴 [Driver Offline] ${driverName || driverId || 'Driver'} is now OFFLINE`);
  }

  socket.send(JSON.stringify({
    type: 'driver_status_ack',
    status: isOnline ? 'online' : 'offline',
    timestamp: new Date().toISOString()
  }));
}

function handleLocationUpdate(socket, message) {
  const { rideId, lat, lng, heading } = message;

  if (rideId && activeRides.has(rideId)) {
    const ride = activeRides.get(rideId);
    ride.driverLocation = { lat, lng, heading };

    // Forward location to the passenger
    if (ride.customerSocket && ride.customerSocket.readyState === WebSocket.OPEN) {
      ride.customerSocket.send(JSON.stringify({
        type: 'location_update',
        rideId,
        location: { lat, lng, heading }
      }));
    }
  }
}

function handleVerifyPin(driverSocket, message) {
  const { rideId, pin } = message;
  if (!rideId || !activeRides.has(rideId)) {
    driverSocket.send(JSON.stringify({ type: 'pin_error', message: 'Safari haijapatikana' }));
    return;
  }

  const ride = activeRides.get(rideId);
  if (String(ride.otpPin).trim() === String(pin).trim()) {
    ride.status = 'in_progress';
    ride.startedAt = new Date().toISOString();

    const successPayload = {
      type: 'ride_started',
      rideId,
      status: 'in_progress',
      message: 'PIN imethibitishwa. Safari imeanza rasmi!'
    };

    driverSocket.send(JSON.stringify(successPayload));
    if (ride.customerSocket && ride.customerSocket.readyState === WebSocket.OPEN) {
      ride.customerSocket.send(JSON.stringify(successPayload));
    }
    console.log(`🚀 [Ride Started] ${rideId} verified successfully with PIN`);
  } else {
    driverSocket.send(JSON.stringify({
      type: 'pin_error',
      message: 'PIN siyo sahihi! Tafadhali muulize mteja tarakimu 4 zilizo kwenye app yake.'
    }));
  }
}

function handleRideCompleted(driverSocket, message) {
  const { rideId, finalFare } = message;
  if (rideId && activeRides.has(rideId)) {
    const ride = activeRides.get(rideId);
    ride.status = 'completed';
    ride.completedAt = new Date().toISOString();
    ride.finalFare = finalFare || ride.fare;

    const completedPayload = {
      type: 'ride_completed',
      rideId,
      status: 'completed',
      finalFare: ride.finalFare,
      completedAt: ride.completedAt
    };

    driverSocket.send(JSON.stringify(completedPayload));
    if (ride.customerSocket && ride.customerSocket.readyState === WebSocket.OPEN) {
      ride.customerSocket.send(JSON.stringify(completedPayload));
    }
    console.log(`🏁 [Ride Completed] ${rideId} completed. Fare: TZS ${ride.finalFare}`);
  }
}

export { activeRides, onlineDrivers, clients };
