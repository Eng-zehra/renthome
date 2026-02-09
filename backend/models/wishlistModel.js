const db = require('../config/db');

const Wishlist = {
    add: async (user_id, property_id) => {
        const [result] = await db.execute(
            'INSERT IGNORE INTO saved_listings (user_id, property_id) VALUES (?, ?)',
            [user_id, property_id]
        );
        return result.affectedRows > 0;
    },

    remove: async (user_id, property_id) => {
        const [result] = await db.execute(
            'DELETE FROM saved_listings WHERE user_id = ? AND property_id = ?',
            [user_id, property_id]
        );
        return result.affectedRows > 0;
    },

    getByUser: async (user_id) => {
        const [rows] = await db.execute(
            `SELECT p.* 
             FROM properties p 
             JOIN saved_listings s ON p.id = s.property_id 
             WHERE s.user_id = ?`,
            [user_id]
        );
        return rows;
    }
};

module.exports = Wishlist;
