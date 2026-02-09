const express = require('express');
const router = express.Router();
const { getPaymentMethods, addPaymentMethod, deletePaymentMethod } = require('../controllers/paymentController');
const { protect } = require('../middleware/authMiddleware');

router.use(protect);

router.route('/')
    .get(getPaymentMethods)
    .post(addPaymentMethod);

router.delete('/:id', deletePaymentMethod);

module.exports = router;
