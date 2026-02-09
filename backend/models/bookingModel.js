const db = require('../config/db');

const Booking = {
    // Check if property is available for the given dates
    checkAvailability: async (property_id, check_in, check_out) => {
        console.log(`🔍 Checking availability for property ${property_id} from ${check_in} to ${check_out}`);
        const [rows] = await db.execute(
            `SELECT COUNT(*) as count FROM bookings 
             WHERE property_id = ? 
             AND status IN ('confirmed', 'pending')
             AND check_in < ? AND check_out > ?`,
            [property_id, check_out, check_in]
        );
        const conflictCount = rows[0].count;
        console.log(`📊 Found ${conflictCount} conflicting bookings`);
        const isAvailable = conflictCount === 0;
        console.log(isAvailable ? '✅ Property is available' : '❌ Property is NOT available');
        return isAvailable;
    },

    create: async (data, user_id) => {
        const { property_id, check_in, check_out, guests, total_price } = data;
        console.log(`📝 Creating booking for property ${property_id}, user ${user_id}`);

        // Check availability before creating booking
        const isAvailable = await Booking.checkAvailability(property_id, check_in, check_out);
        if (!isAvailable) {
            console.log('🚫 Booking rejected - dates not available');
            throw new Error('This property is already booked for the selected dates. Please choose different dates or another property.');
        }

        console.log('✅ Proceeding with booking creation');
        console.log('   Setting status to: pending');

        const [result] = await db.execute(
            "INSERT INTO bookings (property_id, user_id, check_in, check_out, guests, total_price, status) VALUES (?, ?, ?, ?, ?, ?, 'pending')",
            [property_id, user_id, check_in, check_out, guests, total_price]
        );

        const bookingId = result.insertId;
        console.log(`✅ Booking created with ID: ${bookingId}`);

        // Verify the status was set correctly
        const [verification] = await db.execute("SELECT status FROM bookings WHERE id = ?", [bookingId]);
        console.log(`   Verified status in DB: "${verification[0].status}"`);

        return bookingId;
    },

    getBlockedDates: async (property_id) => {
        const [rows] = await db.execute(
            "SELECT check_in, check_out FROM bookings WHERE property_id = ? AND status IN ('confirmed', 'pending')",
            [property_id]
        );
        return rows;
    },

    getByUser: async (user_id) => {
        const [rows] = await db.execute(
            `SELECT b.*, p.title, p.location, p.city, p.images 
             FROM bookings b 
             JOIN properties p ON b.property_id = p.id 
             WHERE b.user_id = ? 
             ORDER BY b.created_at DESC`,
            [user_id]
        );
        return rows;
    }
};

module.exports = Booking;
