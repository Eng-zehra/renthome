const db = require('./config/db');

const fix = async () => {
    try {
        console.log('Fixing bookings...');
        await db.execute("UPDATE bookings SET status = 'confirmed'");
        console.log('All bookings marked confirmed.');
        process.exit();
    } catch (error) {
        console.error('Error:', error);
        process.exit(1);
    }
};

fix();
