const mysql = require('mysql2/promise');
const dotenv = require('dotenv');
const path = require('path');

dotenv.config({ path: path.join(__dirname, '.env') });

async function checkAdmin() {
    try {
        const connection = await mysql.createConnection({
            host: process.env.DB_HOST,
            user: process.env.DB_USER,
            password: process.env.DB_PASSWORD,
            database: process.env.DB_NAME
        });

        const [users] = await connection.execute("SELECT id, name, email, role FROM users");
        console.log('Users:', users);

        await connection.end();
    } catch (error) {
        console.error('Error:', error.message);
    }
}

checkAdmin();
