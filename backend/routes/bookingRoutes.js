const express = require('express');
const router = express.Router();
const { createBooking, getMyBookings, getBlockedDates } = require('../controllers/bookingController');
const { protect } = require('../middleware/authMiddleware');

router.get('/property/:id/dates', getBlockedDates);
router.post('/', protect, createBooking);
router.get('/my', protect, getMyBookings);

module.exports = router;
