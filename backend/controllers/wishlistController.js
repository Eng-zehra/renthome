const Wishlist = require('../models/wishlistModel');

const toggleWishlist = async (req, res) => {
    const { property_id } = req.body;
    const user_id = req.user.id;

    try {
        const saved = await Wishlist.getByUser(user_id);
        const isAlreadySaved = saved.some(p => p.id === property_id);

        if (isAlreadySaved) {
            await Wishlist.remove(user_id, property_id);
            res.json({ message: 'Removed from wishlist', saved: false });
        } else {
            await Wishlist.add(user_id, property_id);
            res.json({ message: 'Added to wishlist', saved: true });
        }
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const getMyWishlist = async (req, res) => {
    try {
        const items = await Wishlist.getByUser(req.user.id);
        res.json(items);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

module.exports = { toggleWishlist, getMyWishlist };
