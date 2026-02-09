const Booking = require('../models/bookingModel');

const createBooking = async (req, res) => {
    try {
        console.log('📝 Creating new booking...');
        console.log('   Request body:', req.body);
        console.log('   User ID:', req.user.id);

        const bookingId = await Booking.create(req.body, req.user.id);

        console.log(`✅ Booking created with ID: ${bookingId}`);

        // Return the booking with the ACTUAL status from database (always 'pending')
        // Don't spread req.body as it might contain incorrect status
        res.status(201).json({
            id: bookingId,
            property_id: req.body.property_id,
            check_in: req.body.check_in,
            check_out: req.body.check_out,
            guests: req.body.guests,
            total_price: req.body.total_price,
            status: 'pending', // Always return 'pending' for new bookings
            message: 'Booking created successfully. Awaiting admin confirmation.'
        });
    } catch (error) {
        console.error('❌ Booking creation failed:', error.message);
        res.status(400).json({ message: error.message });
    }
};

const getMyBookings = async (req, res) => {
    try {
        const bookings = await Booking.getByUser(req.user.id);
        res.json(bookings);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const getBlockedDates = async (req, res) => {
    try {
        const dates = await Booking.getBlockedDates(req.params.id);
        res.json(dates);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

module.exports = { createBooking, getMyBookings, getBlockedDates };
