const Property = require('../models/propertyModel');

const getProperties = async (req, res) => {
    try {
        const properties = await Property.getAll();
        res.json(properties);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const getPropertyById = async (req, res) => {
    try {
        const property = await Property.getById(req.params.id);
        if (property) {
            res.json(property);
        } else {
            res.status(404).json({ message: 'Property not found' });
        }
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const createProperty = async (req, res) => {
    try {
        console.log('Create Property Body:', req.body);
        const propertyId = await Property.create(req.body, req.user.id);
        res.status(201).json({ id: propertyId, ...req.body });
    } catch (error) {
        console.error('Create Property Error:', error);
        res.status(400).json({ message: error.message });
    }
};

const updateProperty = async (req, res) => {
    try {
        console.log('Update Property ID:', req.params.id);
        console.log('Update Property Body:', req.body);
        await Property.update(req.params.id, req.body);
        res.json({ message: 'Property updated successfully' });
    } catch (error) {
        console.error('Update Property Error:', error);
        res.status(400).json({ message: error.message });
    }
};

const deleteProperty = async (req, res) => {
    try {
        await Property.delete(req.params.id);
        res.json({ message: 'Property deleted successfully' });
    } catch (error) {
        console.error('Delete Property Error:', error);
        res.status(400).json({ message: error.message });
    }
};

module.exports = { getProperties, getPropertyById, createProperty, updateProperty, deleteProperty };
