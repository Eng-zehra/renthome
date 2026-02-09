const mysql = require('mysql2/promise');
const bcrypt = require('bcryptjs');
const dotenv = require('dotenv');
const path = require('path');

dotenv.config({ path: path.join(__dirname, '.env') });

async function resetPassword() {
    try {
        const connection = await mysql.createConnection({
            host: process.env.DB_HOST,
            user: process.env.DB_USER,
            password: process.env.DB_PASSWORD,
            database: process.env.DB_NAME
        });

        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash('123456', salt);

        await connection.execute('UPDATE users SET password = ? WHERE email = ?', [hashedPassword, 'asma@gmail.com']);
        console.log('Password updated successfully for asma@gmail.com');
        await connection.end();
    } catch (error) {
        console.error('Error:', error.message);
    }
}

resetPassword();
