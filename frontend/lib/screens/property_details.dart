import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import '../models/property_model.dart';
import '../providers/wishlist_provider.dart';
import 'booking_screen.dart';

class PropertyDetailsScreen extends StatelessWidget {
  final Property property;

  const PropertyDetailsScreen({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildSliverAppBar(context),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const Divider(height: 48),
                      _buildHostCard(),
                      const Divider(height: 48),
                      _buildDescription(),
                      const Divider(height: 48),
                      _buildAmenitiesSection(),
                      const Divider(height: 48),
                      _buildReviewsSection(),
                      const SizedBox(height: 100), // Space for bottom bar
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildBottomStickyBar(context),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: const CircleAvatar(
          backgroundColor: Colors.white,
          child: Icon(Icons.arrow_back, color: Colors.black),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(LineIcons.share, color: Colors.black),
          ),
          onPressed: () {},
        ),
        Consumer<WishlistProvider>(
          builder: (context, wishlist, _) {
            final isSaved = wishlist.isSaved(property.id);
            return IconButton(
              icon: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  isSaved ? LineIcons.heartAlt : LineIcons.heart, 
                  color: isSaved ? Colors.red : Colors.black
                ),
              ),
              onPressed: () => wishlist.toggleWishlist(property.id),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: PageView.builder(
          itemCount: property.images.length,
          itemBuilder: (context, index) {
            return Image.network(
              property.images[index],
              fit: BoxFit.cover,
              width: double.infinity,
              height: 400,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[200],
                child: const Icon(LineIcons.image, color: Colors.grey, size: 50),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          property.title,
          style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 20),
            Text(' ${property.rating} · ', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('${property.location}, ${property.city}', style: const TextStyle(decoration: TextDecoration.underline)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _specIcon(LineIcons.bed, '${property.bedrooms} Beds'),
            const SizedBox(width: 16),
            _specIcon(LineIcons.bath, '${property.bathrooms} Baths'),
            const SizedBox(width: 16),
            _specIcon(LineIcons.users, '${property.maxGuests} Guests'),
          ],
        ),
      ],
    );
  }

  Widget _specIcon(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[700]),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: Colors.grey[700])),
      ],
    );
  }

  Widget _buildHostCard() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 28,
          backgroundImage: NetworkImage('https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=150&q=80'),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hosted by Alexander', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('Joined in 2021 · Superhost', style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text('Contact', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('About this place', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text(
          property.description,
          style: TextStyle(color: Colors.grey[800], height: 1.5, fontSize: 16),
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 12),
        const Text(
          'Read more',
          style: TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
        ),
      ],
    );
  }

  Widget _buildAmenitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('What this place offers', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        GridView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 4,
          ),
          itemCount: property.amenities.length > 6 ? 6 : property.amenities.length,
          itemBuilder: (context, index) {
            return Row(
              children: [
                const Icon(LineIcons.checkCircle, size: 20, color: Color(0xFF2D64FF)),
                const SizedBox(width: 12),
                Text(property.amenities[index]),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {},
            child: Text('Show all ${property.amenities.length} amenities'),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.star, color: Colors.black, size: 24),
            Text(' 4.90 · 128 reviews', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 16),
        // Simple Review Card placeholder
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[200]!),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(radius: 20, backgroundImage: NetworkImage('https://randomuser.me/api/portraits/women/44.jpg')),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Emily Watson', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('October 2023', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text('The place was clean and the view was absolutely breathtaking! Alexander was a great host.'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomStickyBar(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '\$${property.pricePerNight.toStringAsFixed(0)} night',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Text('Feb 12 - 17', style: TextStyle(decoration: TextDecoration.underline)),
                ],
              ),
              SizedBox(
                width: 160,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BookingScreen(property: property)),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF5A5F)),
                  child: const Text('Reserve', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
