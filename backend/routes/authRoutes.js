const express = require('express');
const router = express.Router();
const { registerUser, loginUser, getMe, updateUserProfile, forgotPassword } = require('../controllers/authController');
const { protect } = require('../middleware/authMiddleware');

router.post('/register', registerUser);
router.post('/login', loginUser);
router.post('/forgot-password', forgotPassword);
router.get('/me', protect, getMe);
router.put('/profile', protect, updateUserProfile);

module.exports = router;
