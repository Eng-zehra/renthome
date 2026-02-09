const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
const dotenv = require('dotenv');
const path = require('path');
const { errorHandler } = require('./middleware/errorMiddleware');
// last change aan sameeyey
// Load environment variables
dotenv.config();

const app = express();

// testing the  Middleware; 
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve static files from uploads
app.use('/uploads', express.static(path.join(__dirname, '/uploads')));

if (process.env.NODE_ENV === 'development') {
    app.use(morgan('dev'));
}

// Routes
app.use('/api/auth', require('./routes/authRoutes'));
app.use('/api/properties', require('./routes/propertyRoutes'));
app.use('/api/bookings', require('./routes/bookingRoutes'));
app.use('/api/wishlist', require('./routes/wishlistRoutes'));
app.use('/api/messages', require('./routes/messageRoutes'));
app.use('/api/payment', require('./routes/paymentRoutes'));
app.use('/api/admin', require('./routes/adminRoutes'));
app.use('/api/upload', require('./routes/uploadRoutes'));

app.get('/', (req, res) => {
    res.json({ message: 'Welcome to RentHome API' });
});

// Error Handling Middleware
app.use(errorHandler);

const PORT = process.env.PORT || 8080;

app.listen(PORT, () => {
    console.log(`Server running in ${process.env.NODE_ENV} mode on port ${PORT}`);
});
