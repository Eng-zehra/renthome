const db = require('../config/db');

const Message = {
    // Get all conversations for a user (grouped by other participant)
    getConversations: async (userId) => {
        const [rows] = await db.execute(`
            SELECT DISTINCT
                CASE 
                    WHEN sender_id = ? THEN receiver_id 
                    ELSE sender_id 
                END as other_user_id,
                u.name as other_user_name,
                u.avatar as other_user_avatar,
                (SELECT message FROM messages m2 
                 WHERE (m2.sender_id = ? AND m2.receiver_id = other_user_id) 
                    OR (m2.receiver_id = ? AND m2.sender_id = other_user_id)
                 ORDER BY m2.created_at DESC LIMIT 1) as last_message,
                (SELECT created_at FROM messages m2 
                 WHERE (m2.sender_id = ? AND m2.receiver_id = other_user_id) 
                    OR (m2.receiver_id = ? AND m2.sender_id = other_user_id)
                 ORDER BY m2.created_at DESC LIMIT 1) as last_message_time,
                (SELECT COUNT(*) FROM messages m2 
                 WHERE m2.sender_id = other_user_id 
                   AND m2.receiver_id = ? 
                   AND m2.is_read = FALSE) as unread_count
            FROM messages m
            JOIN users u ON u.id = CASE 
                WHEN m.sender_id = ? THEN m.receiver_id 
                ELSE m.sender_id 
            END
            WHERE sender_id = ? OR receiver_id = ?
            ORDER BY last_message_time DESC
        `, [userId, userId, userId, userId, userId, userId, userId, userId, userId]);
        return rows;
    },

    // Get messages between two users
    getMessages: async (userId, otherUserId) => {
        const [rows] = await db.execute(`
            SELECT m.*, 
                   sender.name as sender_name,
                   sender.avatar as sender_avatar,
                   receiver.name as receiver_name,
                   receiver.avatar as receiver_avatar
            FROM messages m
            JOIN users sender ON m.sender_id = sender.id
            JOIN users receiver ON m.receiver_id = receiver.id
            WHERE (m.sender_id = ? AND m.receiver_id = ?) 
               OR (m.sender_id = ? AND m.receiver_id = ?)
            ORDER BY m.created_at ASC
        `, [userId, otherUserId, otherUserId, userId]);
        return rows;
    },

    // Send a message
    create: async (senderId, receiverId, message, propertyId = null) => {
        const [result] = await db.execute(
            'INSERT INTO messages (sender_id, receiver_id, message, property_id) VALUES (?, ?, ?, ?)',
            [senderId, receiverId, message, propertyId]
        );
        return result.insertId;
    },

    // Mark messages as read
    markAsRead: async (userId, otherUserId) => {
        await db.execute(
            'UPDATE messages SET is_read = TRUE WHERE sender_id = ? AND receiver_id = ? AND is_read = FALSE',
            [otherUserId, userId]
        );
    },

    // Get admin user ID
    getAdminId: async () => {
        const [rows] = await db.execute('SELECT id FROM users WHERE role = ? LIMIT 1', ['admin']);
        return rows.length > 0 ? rows[0].id : null;
    }
};

module.exports = Message;
