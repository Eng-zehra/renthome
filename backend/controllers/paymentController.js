const PaymentMethod = require('../models/paymentModel');

const getPaymentMethods = async (req, res) => {
    try {
        const methods = await PaymentMethod.getAllByUserId(req.user.id);
        res.json(methods);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const addPaymentMethod = async (req, res) => {
    try {
        const methodId = await PaymentMethod.create(req.user.id, req.body);
        res.status(201).json({ id: methodId, ...req.body });
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};

const deletePaymentMethod = async (req, res) => {
    try {
        await PaymentMethod.delete(req.params.id, req.user.id);
        res.json({ message: 'Payment method deleted' });
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};

module.exports = { getPaymentMethods, addPaymentMethod, deletePaymentMethod };
