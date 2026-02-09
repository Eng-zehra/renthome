const db = require('./config/db');

const debugData = async () => {
    try {
        console.log('--- CHECKING BOOKINGS ---');
        const [bookings] = await db.execute('SELECT id, total_price, status, created_at FROM bookings ORDER BY id DESC LIMIT 5');
        console.log(bookings);

        console.log('--- CHECKING AGGREGATION ---');
        const [revenue] = await db.execute("SELECT SUM(total_price) as totalRevenue FROM bookings WHERE status = 'confirmed'");
        console.log('Total Revenue Query Result:', revenue);

        process.exit();
    } catch (error) {
        console.error('Error:', error);
        process.exit(1);
    }
};

debugData();
