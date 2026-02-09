const mysql = require('mysql2/promise');
const dotenv = require('dotenv');
const path = require('path');

dotenv.config({ path: path.join(__dirname, '.env') });

async function checkBookings() {
    const conn = await mysql.createConnection({
        host: process.env.DB_HOST,
        user: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
        database: process.env.DB_NAME
    });

    const [rows] = await conn.execute('SELECT id, status, created_at FROM bookings ORDER BY created_at DESC LIMIT 10');
    console.log('Recent bookings:');
    rows.forEach(r => {
        console.log(`ID: ${r.id}, Status: ${r.status}, Created: ${r.created_at}`);
    });

    await conn.end();
}

checkBookings().catch(console.error);
