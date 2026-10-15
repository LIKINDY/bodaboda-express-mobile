export function errorHandler(err, req, res, next) {
  console.error('💥 [Server Error]:', err.stack || err.message);

  const status = err.statusCode || 500;
  const message = err.message || 'Hitilafu ya ndani ya seva (Internal server error)';

  res.status(status).json({
    success: false,
    message,
    error: process.env.NODE_ENV === 'development' ? err.stack : undefined
  });
}
