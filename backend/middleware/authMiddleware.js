const jwt = require('jsonwebtoken');
const User = require('../models/userModel');

const protect = async (req, res, next) => {
    let token;

    if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
        try {
            token = req.headers.authorization.split(' ')[1];
            console.log('🔑 Token found, verifying...');
            const decoded = jwt.verify(token, process.env.JWT_SECRET);
            req.user = await User.findById(decoded.id);
            console.log('✅ User authenticated:', req.user?.email);
            next();
        } catch (error) {
            console.error('❌ Token verification failed:', error.message);
            res.status(401);
            return res.json({ message: 'Not authorized, token failed' });
        }
    } else {
        console.log('❌ No authorization token found');
        res.status(401);
        return res.json({ message: 'Not authorized, no token' });
    }
};

const admin = (req, res, next) => {
    console.log('🔐 Admin check - User:', req.user?.email, 'Role:', req.user?.role);
    if (req.user && req.user.role === 'admin') {
        console.log('✅ Admin access granted');
        next();
    } else {
        console.log('❌ Admin access denied - not an admin');
        res.status(403);
        res.json({ message: 'Not authorized as an admin' });
    }
};

module.exports = { protect, admin };
