const mysql = require('mysql2/promise');
const dotenv = require('dotenv');

dotenv.config();

async function fixConfirmedBookings() {
    const conn = await mysql.createConnection({
        host: process.env.DB_HOST,
        user: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
        database: process.env.DB_NAME
    });

    console.log('🔄 Resetting confirmed bookings to pending...\n');

    await conn.execute("UPDATE bookings SET status = 'pending' WHERE id IN (39, 42)");

    console.log('✅ Reset bookings 39 and 42 to pending\n');

    const [rows] = await conn.execute('SELECT id, status FROM bookings WHERE id IN (39, 42)');
    rows.forEach(r => {
        console.log(`   Booking ${r.id}: ${r.status}`);
    });

    await conn.end();
}

fixConfirmedBookings().catch(console.error);
