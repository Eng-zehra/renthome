const db = require('./config/db');

const seedProperties = async () => {
    try {
        // Clear existing properties for a fresh start
        await db.execute('DELETE FROM properties');

        const properties = [
            {
                title: 'Ocean View Villa',
                description: 'A beautiful ocean front villa with amazing views. Featuring modern amenities and spacious rooms.',
                type: 'Villa',
                price_per_night: 350.00,
                location: 'Kismayo',
                city: 'Jubbada Hoose',
                bedrooms: 4,
                beds: 5,
                bathrooms: 3,
                amenities: JSON.stringify(['WiFi', 'Pool', 'Kitchen', 'Free Parking', 'AC']),
                host_id: null,
                is_instant_book: true,
                rating: 4.8,
                images: JSON.stringify(['https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&w=800&q=80'])
            },
            {
                title: 'Modern Mogadishu Apartment',
                description: 'Stylish apartment in the heart of Mogadishu. Perfect for business travelers.',
                type: 'Apartment',
                price_per_night: 150.00,
                location: 'Hodan District',
                city: 'Banaadir',
                bedrooms: 2,
                beds: 2,
                bathrooms: 1,
                amenities: JSON.stringify(['WiFi', 'Kitchen', 'Gym', 'Workspace']),
                host_id: null,
                is_instant_book: false,
                rating: 4.5,
                images: JSON.stringify(['https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format&fit=crop&w=800&q=80'])
            },
            {
                title: 'Hargeisa Family Home',
                description: 'Spacious family home with a beautiful garden.',
                type: 'House',
                price_per_night: 200.00,
                location: 'Hargeisa',
                city: 'Woqooyi Galbeed',
                bedrooms: 3,
                beds: 4,
                bathrooms: 2,
                amenities: JSON.stringify(['WiFi', 'Garden', 'Kitchen', 'Parking']),
                host_id: null,
                is_instant_book: true,
                rating: 4.9,
                images: JSON.stringify(['https://images.unsplash.com/photo-1568605114967-8130f3a36994?auto=format&fit=crop&w=800&q=80'])
            },
            {
                title: 'Garowe Guest House',
                description: 'Traditional guest house experience with modern comforts.',
                type: 'House',
                price_per_night: 80.00,
                location: 'Garowe',
                city: 'Nugaal',
                bedrooms: 1,
                beds: 1,
                bathrooms: 1,
                amenities: JSON.stringify(['WiFi', 'Breakfast', 'AC']),
                host_id: null,
                is_instant_book: true,
                rating: 4.6,
                images: JSON.stringify(['https://images.unsplash.com/photo-1598928506311-c55ded91a20c?auto=format&fit=crop&w=800&q=80'])
            }
        ];

        for (const prop of properties) {
            await db.execute(
                `INSERT INTO properties (title, description, type, price_per_night, location, city, bedrooms, beds, bathrooms, amenities, host_id, is_instant_book, rating, images) 
                 VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
                [prop.title, prop.description, prop.type, prop.price_per_night, prop.location, prop.city, prop.bedrooms, prop.beds, prop.bathrooms, prop.amenities, prop.host_id, prop.is_instant_book, prop.rating, prop.images]
            );
        }

        console.log('✅ Database seeded with sample properties');
        process.exit(0);
    } catch (error) {
        console.error('❌ Error seeding database:', error);
        process.exit(1);
    }
};

seedProperties();
