const express = require('express');
const router = express.Router();
const { toggleWishlist, getMyWishlist } = require('../controllers/wishlistController');
const { protect } = require('../middleware/authMiddleware');

router.post('/toggle', protect, toggleWishlist);
router.get('/my', protect, getMyWishlist);

module.exports = router;
