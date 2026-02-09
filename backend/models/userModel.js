const db = require('../config/db');
const bcrypt = require('bcryptjs');

const User = {
    create: async (userData) => {
        const { name, email, password, phone, role } = userData;
        const hashedPassword = await bcrypt.hash(password, 10);
        const [result] = await db.execute(
            'INSERT INTO users (name, email, password, phone, role) VALUES (?, ?, ?, ?, ?)',
            [name, email, hashedPassword, phone, role || 'user']
        );
        return result.insertId;
    },

    findByEmail: async (email) => {
        const [rows] = await db.execute('SELECT * FROM users WHERE email = ?', [email]);
        return rows[0];
    },

    findById: async (id) => {
        const [rows] = await db.execute('SELECT id, name, email, phone, role, avatar, created_at FROM users WHERE id = ?', [id]);
        return rows[0];
    },

    update: async (id, userData) => {
        const { name, phone, avatar, email } = userData;

        // If email is being updated, check if it's already taken
        if (email) {
            const [existing] = await db.execute('SELECT id FROM users WHERE email = ? AND id != ?', [email, id]);
            if (existing.length > 0) {
                throw new Error('Email already in use');
            }
            await db.execute(
                'UPDATE users SET name = ?, phone = ?, avatar = ?, email = ? WHERE id = ?',
                [name, phone, avatar, email, id]
            );
        } else {
            await db.execute(
                'UPDATE users SET name = ?, phone = ?, avatar = ? WHERE id = ?',
                [name, phone, avatar, id]
            );
        }
    },

    comparePassword: async (enteredPassword, hashedPassword) => {
        return await bcrypt.compare(enteredPassword, hashedPassword);
    }
};

module.exports = User;
