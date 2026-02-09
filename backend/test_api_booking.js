const axios = require('axios');

async function testBookingCreation() {
    console.log('🧪 Testing Booking Creation via API\n');
    console.log('='.repeat(50));

    try {
        // First, login to get a token
        console.log('\n1️⃣ Logging in as regular user...');
        const loginResponse = await axios.post('http://127.0.0.1:8080/api/auth/login', {
            email: 'asma@gmail.com',
            password: 'password123'
        });

        const token = loginResponse.data.token;
        console.log(' Login successful, got token');

        // Create a booking
        console.log('\n2️ Creating a new booking...');
        const bookingData = {
            property_id: 7,
            check_in: '2026-04-01',
            check_out: '2026-04-05',
            guests: 2,
            total_price: 600.00
        };

        console.log('   Sending data:', bookingData);

        const bookingResponse = await axios.post(
            'http://127.0.0.1:8080/api/bookings',
            bookingData,
            {
                headers: {
                    'Authorization': `Bearer ${token}`,
                    'Content-Type': 'application/json'
                }
            }
        );

        console.log('\n3️⃣ Response from server:');
        console.log('   Status Code:', bookingResponse.status);
        console.log('   Response Data:', JSON.stringify(bookingResponse.data, null, 2));

        const bookingId = bookingResponse.data.id;
        const returnedStatus = bookingResponse.data.status;

        console.log('\n4️⃣ Verification:');
        console.log(`   Booking ID: ${bookingId}`);
        console.log(`   Returned Status: "${returnedStatus}"`);
        console.log(`   Message: ${bookingResponse.data.message || 'N/A'}`);

        if (returnedStatus === 'pending') {
            console.log('\n SUCCESS: Booking created with pending status!');
        } else {
            console.log(`\n FAILURE: Expected 'pending' but got '${returnedStatus}'`);
        }

        // Verify in database
        const mysql = require('mysql2/promise');
        const dotenv = require('dotenv');
        dotenv.config();

        const conn = await mysql.createConnection({
            host: process.env.DB_HOST,
            user: process.env.DB_USER,
            password: process.env.DB_PASSWORD,
            database: process.env.DB_NAME
        });

        const [rows] = await conn.execute('SELECT id, status FROM bookings WHERE id = ?', [bookingId]);

        console.log('\n5 Database Verification:');
        if (rows.length > 0) {
            console.log(`   DB Status: "${rows[0].status}"`);
            if (rows[0].status === 'pending') {
                console.log('    Confirmed: Status is pending in database');
            } else {
                console.log(`    ERROR: Status in DB is '${rows[0].status}' not 'pending'`);
            }
        }

        // Clean up
        await conn.execute('DELETE FROM bookings WHERE id = ?', [bookingId]);
        console.log('\n🧹 Cleaned up test booking');
        await conn.end();

        console.log('\n' + '='.repeat(50));
        console.log(' TEST COMPLETE\n');

    } catch (error) {
        console.error('\n TEST FAILED:');
        if (error.response) {
            console.error('   Status:', error.response.status);
            console.error('   Data:', error.response.data);
        } else {
            console.error('   Error:', error.message);
        }
    }
}

testBookingCreation();
