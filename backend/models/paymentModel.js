const db = require('../config/db');

const PaymentMethod = {
    getAllByUserId: async (userId) => {
        const [rows] = await db.execute('SELECT * FROM payment_methods WHERE user_id = ?', [userId]);
        return rows;
    },

    create: async (userId, data) => {
        const { card_type, card_holder, card_number, expiry_date, is_default } = data;
        const [result] = await db.execute(
            'INSERT INTO payment_methods (user_id, card_type, card_holder, card_number, expiry_date, is_default) VALUES (?, ?, ?, ?, ?, ?)',
            [userId, card_type, card_holder, card_number, expiry_date, is_default || false]
        );
        return result.insertId;
    },

    delete: async (id, userId) => {
        await db.execute('DELETE FROM payment_methods WHERE id = ? AND user_id = ?', [id, userId]);
    }
};

module.exports = PaymentMethod;
