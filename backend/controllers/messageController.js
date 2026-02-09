const Message = require('../models/messageModel');

// Get all conversations for the logged-in user
const getConversations = async (req, res) => {
    try {
        const conversations = await Message.getConversations(req.user.id);
        res.json(conversations);
    } catch (error) {
        console.error('Get Conversations Error:', error);
        res.status(500).json({ message: error.message });
    }
};

// Get messages between logged-in user and another user
const getMessages = async (req, res) => {
    try {
        const { userId } = req.params;
        const messages = await Message.getMessages(req.user.id, parseInt(userId));

        // Mark messages as read
        await Message.markAsRead(req.user.id, parseInt(userId));

        res.json(messages);
    } catch (error) {
        console.error('Get Messages Error:', error);
        res.status(500).json({ message: error.message });
    }
};

// Send a message
const sendMessage = async (req, res) => {
    try {
        const { receiverId, message, propertyId } = req.body;

        if (!receiverId || !message) {
            return res.status(400).json({ message: 'Receiver ID and message are required' });
        }

        const messageId = await Message.create(
            req.user.id,
            receiverId,
            message,
            propertyId || null
        );

        res.status(201).json({
            id: messageId,
            sender_id: req.user.id,
            receiver_id: receiverId,
            message,
            property_id: propertyId,
            created_at: new Date()
        });
    } catch (error) {
        console.error('Send Message Error:', error);
        res.status(500).json({ message: error.message });
    }
};

// Get admin user ID
const getAdminContact = async (req, res) => {
    try {
        const adminId = await Message.getAdminId();
        if (adminId) {
            res.json({ adminId });
        } else {
            res.status(404).json({ message: 'Admin not found' });
        }
    } catch (error) {
        console.error('Get Admin Error:', error);
        res.status(500).json({ message: error.message });
    }
};

module.exports = { getConversations, getMessages, sendMessage, getAdminContact };
