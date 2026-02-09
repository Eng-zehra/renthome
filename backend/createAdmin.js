const db = require('./config/db');
const bcrypt = require('bcryptjs');
const dotenv = require('dotenv');

dotenv.config();

const createAdmin = async () => {
    try {
        const name = 'Admin User';
        const email = 'admin@renthome.com';
        const password = 'adminpassword123'; // Change this!
        const phone = '0000000000';
        const role = 'admin';

        // Check if admin already exists
        const [exists] = await db.execute('SELECT * FROM users WHERE email = ?', [email]);
        if (exists.length > 0) {
            console.log('⚠️ Admin user already exists');
            process.exit(0);
        }

        const hashedPassword = await bcrypt.hash(password, 10);

        await db.execute(
            'INSERT INTO users (name, email, password, phone, role) VALUES (?, ?, ?, ?, ?)',
            [name, email, hashedPassword, phone, role]
        );

        console.log('✅ Admin Account Created Successfully!');
        console.log('📧 Email: ' + email);
        console.log('🔑 Password: ' + password);
        process.exit(0);
    } catch (error) {
        console.error('❌ Error creating admin:', error);
        process.exit(1);
    }
};

createAdmin();
