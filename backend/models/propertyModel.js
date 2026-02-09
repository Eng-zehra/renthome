const db = require('../config/db');

const Property = {
    getAll: async () => {
        const [rows] = await db.execute('SELECT * FROM properties');
        return rows;
    },

    getById: async (id) => {
        const [rows] = await db.execute('SELECT * FROM properties WHERE id = ?', [id]);
        return rows[0];
    },

    create: async (data, host_id) => {
        const { title, description, type, price_per_night, location, city, bedrooms, beds, bathrooms, amenities, images } = data;
        const [result] = await db.execute(
            'INSERT INTO properties (title, description, type, price_per_night, location, city, bedrooms, beds, bathrooms, amenities, host_id, images) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
            [title, description, type, price_per_night, location, city, bedrooms, beds, bathrooms, JSON.stringify(amenities), host_id, JSON.stringify(images)]
        );
        return result.insertId;
    },

    update: async (id, data) => {
        const { title, description, type, price_per_night, location, city, bedrooms, beds, bathrooms, amenities, images, rating } = data;
        await db.execute(
            'UPDATE properties SET title = ?, description = ?, type = ?, price_per_night = ?, location = ?, city = ?, bedrooms = ?, beds = ?, bathrooms = ?, amenities = ?, images = ?, rating = ? WHERE id = ?',
            [title, description, type, price_per_night, location, city, bedrooms, beds, bathrooms, JSON.stringify(amenities), JSON.stringify(images), rating, id]
        );
    },

    delete: async (id) => {
        await db.execute('DELETE FROM properties WHERE id = ?', [id]);
    }
};

module.exports = Property;
