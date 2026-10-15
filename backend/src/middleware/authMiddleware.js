import jwt from 'jsonwebtoken';

export function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({
      success: false,
      message: 'Access denied: Token haijapatikana (No token provided)'
    });
  }

  const secret = process.env.JWT_SECRET || 'super_secret_jwt_key_for_bodaboda_express_change_in_production';

  jwt.verify(token, secret, (err, user) => {
    if (err) {
      return res.status(403).json({
        success: false,
        message: 'Invalid or expired token (Muda wa token umeisha au siyo halali)'
      });
    }
    req.user = user;
    next();
  });
}
