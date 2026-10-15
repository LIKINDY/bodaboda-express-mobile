import jwt from 'jsonwebtoken';

const JWT_SECRET = process.env.JWT_SECRET || 'super_secret_jwt_key_for_bodaboda_express_change_in_production';

// Mock storage for demo/starter (replace with DB model e.g. Mongoose or Prisma)
const mockUsers = new Map();
const mockDrivers = new Map();

export async function customerRequestOtp(req, res) {
  try {
    const { phone } = req.body;
    if (!phone) {
      return res.status(400).json({ success: false, message: 'Namba ya simu inahitajika (Phone number required)' });
    }

    // Default development OTP is 1234
    const otp = '1234';
    console.log(`📱 [SMS Gateway] OTP sent to ${phone}: ${otp}`);

    res.json({
      success: true,
      message: `OTP imetumwa kwa namba ${phone}`,
      devOtp: process.env.NODE_ENV !== 'production' ? otp : undefined
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
}

export async function customerVerifyOtp(req, res) {
  try {
    const { phone, otp, fullName } = req.body;

    if (!phone || !otp) {
      return res.status(400).json({ success: false, message: 'Simu na OTP zinahitajika' });
    }

    // In dev, accept 1234 or any 4-digit code
    if (otp !== '1234') {
      return res.status(400).json({ success: false, message: 'OTP siyo sahihi (Invalid OTP code)' });
    }

    let user = mockUsers.get(phone);
    if (!user) {
      user = {
        id: `CUST-${Math.floor(1000 + Math.random() * 9000)}`,
        phone,
        fullName: fullName || 'Mteja Bodaboda',
        role: 'customer',
        createdAt: new Date().toISOString()
      };
      mockUsers.set(phone, user);
    }

    const token = jwt.sign(
      { id: user.id, phone: user.phone, role: 'customer' },
      JWT_SECRET,
      { expiresIn: '30d' }
    );

    res.json({
      success: true,
      message: 'Umeingia kwa mafanikio',
      token,
      user
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
}

export async function driverLogin(req, res) {
  try {
    const { phone } = req.body;
    if (!phone) {
      return res.status(400).json({ success: false, message: 'Namba ya simu inahitajika' });
    }

    const otp = '1234';
    console.log(`🏍️ [Driver SMS Gateway] OTP sent to ${phone}: ${otp}`);

    res.json({
      success: true,
      message: `OTP ya dereva imetumwa kwa ${phone}`,
      devOtp: process.env.NODE_ENV !== 'production' ? otp : undefined
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
}

export async function driverVerifyOtp(req, res) {
  try {
    const { phone, otp } = req.body;

    if (otp !== '1234') {
      return res.status(400).json({ success: false, message: 'OTP ya dereva siyo sahihi' });
    }

    let driver = mockDrivers.get(phone);
    if (!driver) {
      driver = {
        id: `DRV-${Math.floor(100 + Math.random() * 900)}`,
        phone,
        fullName: 'Juma Shabani',
        vehicleType: 'bodaboda',
        plateNumber: 'MC 582 DFB',
        rating: 4.88,
        isVerified: true,
        role: 'driver'
      };
      mockDrivers.set(phone, driver);
    }

    const token = jwt.sign(
      { id: driver.id, phone: driver.phone, role: 'driver' },
      JWT_SECRET,
      { expiresIn: '30d' }
    );

    res.json({
      success: true,
      message: 'Dereva ameingia kwa mafanikio',
      token,
      driver
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
}

export async function driverUploadDocuments(req, res) {
  try {
    const { driverId, idType, idNumber, faceSelfieUrl, idDocumentUrl } = req.body;

    console.log(`📄 [Driver Verification] ID Type: ${idType}, ID: ${idNumber} for ${driverId}`);

    res.json({
      success: true,
      message: 'Nyaraka za uthibitisho zimepokelewa kikamilifu kwa uhakiki.',
      status: 'pending_approval'
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
}

export async function socialSignIn(req, res) {
  try {
    const { provider, email, fullName, providerId, role = 'driver' } = req.body;

    const token = jwt.sign(
      { id: `SOC-${Math.floor(1000 + Math.random() * 9000)}`, email, role },
      JWT_SECRET,
      { expiresIn: '30d' }
    );

    res.json({
      success: true,
      message: `Umeingia kwa ${provider}`,
      token,
      profile: {
        email,
        fullName: fullName || 'User',
        provider
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
}
