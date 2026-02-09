const db = require('./config/db');
require('dotenv').config();

const checkUserRole = async () => {
    try {
        console.log('Checking users and their roles:\n');

        const [users] = await db.execute('SELECT id, name, email, role FROM users');

        console.log('All users in database:');
        users.forEach(user => {
            console.log(`  ${user.id}. ${user.name} (${user.email}) - Role: ${user.role}`);
        });

        console.log('\n✅ Admin users:');
        const admins = users.filter(u => u.role === 'admin');
        admins.forEach(admin => {
            console.log(`  - ${admin.email}`);
        });

        console.log('\n📝 Regular users:');
        const regularUsers = users.filter(u => u.role === 'user');
        regularUsers.forEach(user => {
            console.log(`  - ${user.email}`);
        });

        process.exit(0);
    } catch (error) {
        console.error('❌ Error:', error);
        process.exit(1);
    }
};

checkUserRole();
