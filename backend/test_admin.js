const db = require('./config/db');
require('dotenv').config();

const testAdmin = async () => {
    try {
        console.log('Testing admin bookings query...\n');

        const query = `
            SELECT b.*, 
                   u.name as customer_name, u.email as customer_email, u.phone as customer_phone, u.avatar as customer_avatar,
                   p.title as property_title, p.location as property_location, p.images as property_images
            FROM bookings b
            JOIN users u ON b.user_id = u.id
            JOIN properties p ON b.property_id = p.id
            ORDER BY b.created_at DESC
        `;

        const [bookings] = await db.execute(query);

        console.log(`✅ Query successful! Found ${bookings.length} bookings\n`);

        if (bookings.length > 0) {
            console.log('Sample booking:');
            console.log({
                id: bookings[0].id,
                customer: bookings[0].customer_name,
                email: bookings[0].customer_email,
                property: bookings[0].property_title,
                check_in: bookings[0].check_in,
                check_out: bookings[0].check_out,
                status: bookings[0].status
            });
        }

        process.exit(0);
    } catch (error) {
        console.error('❌ Error:', error);
        process.exit(1);
    }
};

testAdmin();
