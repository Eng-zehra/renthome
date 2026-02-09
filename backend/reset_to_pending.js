const mysql = require('mysql2/promise');
const dotenv = require('dotenv');
const path = require('path');

dotenv.config({ path: path.join(__dirname, '.env') });

async function resetToPending() {
    const conn = await mysql.createConnection({
        host: process.env.DB_HOST,
        user: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
        database: process.env.DB_NAME
    });

    console.log('🔄 Resetting all confirmed bookings to pending...');

    const [result] = await conn.execute(
        "UPDATE bookings SET status = 'pending' WHERE status = 'confirmed'"
    );

    console.log(`✅ Updated ${result.affectedRows} bookings to pending status`);

    // Show current status
    const [rows] = await conn.execute(
        'SELECT status, COUNT(*) as count FROM bookings GROUP BY status'
    );

    console.log('\n📊 Current booking status distribution:');
    rows.forEach(r => {
        console.log(`   ${r.status}: ${r.count}`);
    });

    await conn.end();
}

resetToPending().catch(console.error);
