const express = require('express');
const router = express.Router();
const { getConversations, getMessages, sendMessage, getAdminContact } = require('../controllers/messageController');
const { protect } = require('../middleware/authMiddleware');

// All routes require authentication
router.get('/conversations', protect, getConversations);
router.get('/admin', protect, getAdminContact);
router.get('/:userId', protect, getMessages);
router.post('/', protect, sendMessage);

module.exports = router;
