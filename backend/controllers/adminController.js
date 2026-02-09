const db = require('../config/db');

const getDashboardStats = async (req, res) => {
    try {
        // 1. Total Money (Revenue)
        const [totalRevenueResult] = await db.execute(
            "SELECT SUM(total_price) as totalRevenue FROM bookings WHERE status = 'confirmed'"
        );
        const totalRevenue = totalRevenueResult[0].totalRevenue || 0;

        // 2. Chart Data
        const [dailyRevenueResult] = await db.execute(
            `SELECT DATE(created_at) as date, SUM(total_price) as dailyRevenue 
             FROM bookings 
             WHERE status = 'confirmed'
             GROUP BY DATE(created_at) 
             ORDER BY date ASC`
        );

        // 3. Additional Stats
        const [[{ totalUsers }]] = await db.execute("SELECT COUNT(*) as totalUsers FROM users");
        const [[{ totalProperties }]] = await db.execute("SELECT COUNT(*) as totalProperties FROM properties");
        const [[{ totalBookings }]] = await db.execute("SELECT COUNT(*) as totalBookings FROM bookings");
        const [[{ pendingBookings }]] = await db.execute("SELECT COUNT(*) as pendingBookings FROM bookings WHERE status = 'pending'");

        res.json({
            totalRevenue,
            totalUsers,
            totalProperties,
            totalBookings,
            pendingBookings,
            chartData: dailyRevenueResult
        });
    } catch (error) {
        console.error('Admin Stats Error:', error);
        res.status(500).json({ message: 'Failed to fetch admin stats' });
    }
};

const getAllBookings = async (req, res) => {
    try {
        console.log('📋 Fetching all bookings for admin...');
        const query = `
            SELECT b.id, b.property_id, b.user_id,
            DATE_FORMAT(b.check_in, '%Y-%m-%d') as check_in,
            DATE_FORMAT(b.check_out, '%Y-%m-%d') as check_out,
            b.guests, b.total_price, b.status, b.created_at,
            u.name as customer_name, u.email as customer_email, u.phone as customer_phone, u.avatar as customer_avatar,
            p.title as property_title, p.location as property_location, p.images as property_images
            FROM bookings b
            JOIN users u ON b.user_id = u.id
            JOIN properties p ON b.property_id = p.id
            ORDER BY 
                CASE WHEN b.status = 'pending' THEN 0 ELSE 1 END,
                b.created_at DESC
        `;
        const [bookings] = await db.execute(query);

        console.log(`✅ Found ${bookings.length} bookings`);

        // Parse property images if they are strings
        bookings.forEach(b => {
            if (typeof b.property_images === 'string') {
                try {
                    b.property_images = JSON.parse(b.property_images);
                } catch (e) {
                    b.property_images = [];
                }
            }
        });

        // Debug: Log status distribution
        const statusCounts = {};
        bookings.forEach(b => {
            const status = b.status;
            statusCounts[status] = (statusCounts[status] || 0) + 1;
            if (b.id <= 40) { // Log first few for debugging
                console.log(`   Booking ${b.id}: status="${status}" (type: ${typeof status})`);
            }
        });
        console.log('📊 Status distribution:', statusCounts);

        res.json(bookings);
    } catch (error) {
        console.error('❌ Admin Bookings Error:', error);
        res.status(500).json({ message: 'Failed to fetch bookings' });
    }
};

const updateBookingStatus = async (req, res) => {
    const { id } = req.params;
    const { status } = req.body;

    console.log(`🔄 Admin updating booking ${id} to status: ${status}`);

    if (!['pending', 'confirmed', 'cancelled'].includes(status)) {
        console.log(`❌ Invalid status: ${status}`);
        return res.status(400).json({ message: 'Invalid status' });
    }

    try {
        // First check if booking exists
        const [existing] = await db.execute("SELECT id, status FROM bookings WHERE id = ?", [id]);
        if (existing.length === 0) {
            console.log(`❌ Booking ${id} not found`);
            return res.status(404).json({ message: 'Booking not found' });
        }

        console.log(`📝 Current status: ${existing[0].status} -> New status: ${status}`);

        const [result] = await db.execute("UPDATE bookings SET status = ? WHERE id = ?", [status, id]);

        if (result.affectedRows > 0) {
            console.log(`✅ Booking ${id} successfully updated to ${status}`);
            res.json({ message: 'Booking status updated successfully', booking_id: id, new_status: status });
        } else {
            console.log(`⚠️ No rows affected for booking ${id}`);
            res.status(500).json({ message: 'Failed to update booking' });
        }
    } catch (error) {
        console.error('❌ Update Booking Error:', error);
        res.status(500).json({ message: 'Failed to update booking' });
    }
};

module.exports = { getDashboardStats, getAllBookings, updateBookingStatus };
