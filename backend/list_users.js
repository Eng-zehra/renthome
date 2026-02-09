const mysql = require('mysql2/promise');
const dotenv = require('dotenv');

dotenv.config();

async function checkUsers() {
    const conn = await mysql.createConnection({
        host: process.env.DB_HOST,
        user: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
        database: process.env.DB_NAME
    });

    const [users] = await conn.execute('SELECT id, name, email, role FROM users LIMIT 5');
    console.log('Available Users:');
    users.forEach(u => {
        console.log(`  ID: ${u.id}, Name: ${u.name}, Email: ${u.email}, Role: ${u.role}`);
    });

    await conn.end();
}

checkUsers().catch(console.error);
