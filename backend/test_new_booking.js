const mysql = require('mysql2/promise');
const dotenv = require('dotenv');
const path = require('path');

dotenv.config({ path: path.join(__dirname, '.env') });

async function testNewBooking() {
    const conn = await mysql.createConnection({
        host: process.env.DB_HOST,
        user: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
        database: process.env.DB_NAME
    });

    console.log(' Testing new booking creation...\n');

    // Get a real property and user
    const [properties] = await conn.execute('SELECT id FROM properties LIMIT 1');
    const [users] = await conn.execute('SELECT id FROM users LIMIT 1');

    if (properties.length === 0 || users.length === 0) {
        console.log(' No properties or users found in database');
        await conn.end();
        return;
    }

    const propertyId = properties[0].id;
    const userId = users[0].id;

    console.log(`Using property ID: ${propertyId}, user ID: ${userId}\n`);

    // Create a test booking
    const [result] = await conn.execute(
        "INSERT INTO bookings (property_id, user_id, check_in, check_out, guests, total_price, status) VALUES (?, ?, ?, ?, ?, ?, 'pending')",
        [propertyId, userId, '2026-03-01', '2026-03-05', 2, 500.00]
    );

    const newId = result.insertId;
    console.log(` Created test booking with ID: ${newId}`);

    // Immediately read it back
    const [rows] = await conn.execute(
        'SELECT id, status FROM bookings WHERE id = ?',
        [newId]
    );

    if (rows.length > 0) {
        const booking = rows[0];
        console.log(`\n📋 Verification:`);
        console.log(`   ID: ${booking.id}`);
        console.log(`   Status: "${booking.status}"`);
        console.log(`   Status Type: ${typeof booking.status}`);
        console.log(`   Is Pending: ${booking.status === 'pending'}`);

        if (booking.status === 'pending') {
            console.log('\n SUCCESS: Booking created with pending status!');
        } else {
            console.log(`\n FAILURE: Expected 'pending' but got '${booking.status}'`);
        }
    }

    // Clean up test booking
    await conn.execute('DELETE FROM bookings WHERE id = ?', [newId]);
    console.log(`\n🧹 Cleaned up test booking ${newId}`);

    await conn.end();
}

testNewBooking().catch(console.error);
