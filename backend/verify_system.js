const mysql = require('mysql2/promise');
const dotenv = require('dotenv');

dotenv.config();

async function finalVerification() {
    const conn = await mysql.createConnection({
        host: process.env.DB_HOST,
        user: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
        database: process.env.DB_NAME
    });

    console.log('🔍 FINAL SYSTEM VERIFICATION\n');
    console.log('='.repeat(50));

    // 1. Check all booking statuses
    const [allBookings] = await conn.execute('SELECT status, COUNT(*) as count FROM bookings GROUP BY status');

    console.log('\n📊 Booking Status Distribution:');
    let totalPending = 0;
    allBookings.forEach(row => {
        console.log(`   ${row.status.toUpperCase()}: ${row.count}`);
        if (row.status === 'pending') totalPending = row.count;
    });

    // 2. Check recent bookings
    const [recent] = await conn.execute('SELECT id, status, created_at FROM bookings ORDER BY created_at DESC LIMIT 5');

    console.log('\n📋 Recent Bookings:');
    recent.forEach(b => {
        const statusIcon = b.status === 'pending' ? '✅' : '⚠️';
        console.log(`   ${statusIcon} ID ${b.id}: ${b.status}`);
    });

    // 3. Verify schema default
    const [schema] = await conn.execute("SHOW COLUMNS FROM bookings WHERE Field = 'status'");
    console.log('\n🗄️  Database Schema:');
    console.log(`   Default value: ${schema[0].Default}`);
    console.log(`   Type: ${schema[0].Type}`);

    // 4. Final summary
    console.log('\n' + '='.repeat(50));
    console.log('📝 VERIFICATION SUMMARY:\n');

    const allPending = allBookings.length === 1 && allBookings[0].status === 'pending';
    const schemaCorrect = schema[0].Default === 'pending';

    console.log(`   ✅ Total Pending Bookings: ${totalPending}`);
    console.log(`   ${allPending ? '✅' : '⚠️'}  All bookings are pending: ${allPending}`);
    console.log(`   ${schemaCorrect ? '✅' : '⚠️'}  Schema default is 'pending': ${schemaCorrect}`);

    if (allPending && schemaCorrect) {
        console.log('\n🎉 SUCCESS: System is correctly configured!');
        console.log('   - All existing bookings are pending');
        console.log('   - New bookings will default to pending');
        console.log('   - Admin approval is required');
    } else {
        console.log('\n⚠️  WARNING: Some issues detected');
        if (!allPending) console.log('   - Not all bookings are pending');
        if (!schemaCorrect) console.log('   - Schema default is not pending');
    }

    console.log('\n' + '='.repeat(50));

    await conn.end();
}

finalVerification().catch(console.error);
