const express = require('express');
const router = express.Router();
const { getDashboardStats, getAllBookings, updateBookingStatus } = require('../controllers/adminController');
const { protect, admin } = require('../middleware/authMiddleware');

// Log all admin route requests
router.use((req, res, next) => {
    console.log(`📥 Admin route request: ${req.method} ${req.originalUrl}`);
    next();
});

// All admin routes are protected by auth and admin check
router.use(protect);
router.use(admin);

router.get('/stats', getDashboardStats);
router.get('/bookings', getAllBookings);
router.patch('/bookings/:id/status', updateBookingStatus);

module.exports = router;
