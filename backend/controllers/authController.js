const jwt = require('jsonwebtoken');
const User = require('../models/userModel');

const generateToken = (id) => {
    return jwt.sign({ id }, process.env.JWT_SECRET, {
        expiresIn: '30d',
    });
};

const registerUser = async (req, res) => {
    console.log('--- REGISTER ATTEMPT ---', req.body);
    const { name, email, password, phone } = req.body;

    try {
        const userExists = await User.findByEmail(email);

        if (userExists) {
            res.status(400);
            throw new Error('User already exists');
        }

        const userId = await User.create({ name, email, password, phone });
        const user = await User.findById(userId);

        if (user) {
            res.status(201).json({
                id: user.id,
                name: user.name,
                email: user.email,
                phone: user.phone,
                avatar: user.avatar,
                role: user.role,
                token: generateToken(user.id),
            });
        } else {
            res.status(400);
            throw new Error('Invalid user data');
        }
    } catch (error) {
        console.error('Registration Error:', error);
        res.status(res.statusCode === 200 ? 500 : res.statusCode).json({ message: error.message });
    }
};

const loginUser = async (req, res) => {
    const { email, password } = req.body;

    try {
        const user = await User.findByEmail(email);

        if (user && (await User.comparePassword(password, user.password))) {
            res.json({
                id: user.id,
                name: user.name,
                email: user.email,
                phone: user.phone,
                avatar: user.avatar,
                role: user.role,
                token: generateToken(user.id),
            });
        } else {
            res.status(401);
            throw new Error('Invalid email or password');
        }
    } catch (error) {
        console.error('Login Error:', error);
        res.status(res.statusCode === 200 ? 500 : res.statusCode).json({ message: error.message });
    }
};

const getMe = async (req, res) => {
    try {
        const user = await User.findById(req.user.id);
        if (user) {
            res.json(user);
        } else {
            res.status(404);
            throw new Error('User not found');
        }
    } catch (error) {
        console.error('Get Profile Error:', error);
        res.status(res.statusCode === 200 ? 500 : res.statusCode).json({ message: error.message });
    }
};

const updateUserProfile = async (req, res) => {
    try {
        const user = await User.findById(req.user.id);

        if (user) {
            const updatedData = {
                name: req.body.name || user.name,
                phone: req.body.phone || user.phone,
                avatar: req.body.avatar || user.avatar,
                email: req.body.email || user.email
            };

            await User.update(req.user.id, updatedData);
            const updatedUser = await User.findById(req.user.id);
            res.json(updatedUser);
        } else {
            res.status(404);
            throw new Error('User not found');
        }
    } catch (error) {
        console.error('Update Profile Error:', error);
        res.status(error.message === 'Email already in use' ? 400 : 500).json({ message: error.message });
    }
};

const forgotPassword = async (req, res) => {
    const { email } = req.body;
    try {
        const user = await User.findByEmail(email);
        if (!user) {
            res.status(404);
            throw new Error('User not found');
        }
        // In a real application, you would generate a reset token and send an email
        res.json({ message: 'If that email address is in our database, we will send you an email to reset your password.' });
    } catch (error) {
        console.error('Forgot Password Error:', error);
        res.status(500).json({ message: error.message });
    }
};

module.exports = { registerUser, loginUser, getMe, updateUserProfile, forgotPassword };
