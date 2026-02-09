const express = require('express');
const router = express.Router();
const { getProperties, getPropertyById, createProperty, updateProperty, deleteProperty } = require('../controllers/propertyController');
const { protect, admin } = require('../middleware/authMiddleware');

router.get('/', getProperties);
router.post('/', protect, admin, createProperty);

router.route('/:id')
    .get(getPropertyById)
    .put(protect, admin, updateProperty)
    .delete(protect, admin, deleteProperty);

module.exports = router;
