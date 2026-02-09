const db = require('./config/db');

const checkData = async () => {
    try {
        const [bookings] = await db.execute('SELECT * FROM bookings');
        console.log('Bookings count:', bookings.length);
        console.log('Bookings:', bookings);

        const [users] = await db.execute('SELECT id, name, email, role FROM users');
        console.log('Users count:', users.length);
        console.log('Users:', users);

        process.exit();
    } catch (error) {
        console.error('Error:', error);
        process.exit(1);
    }
};

checkData();
