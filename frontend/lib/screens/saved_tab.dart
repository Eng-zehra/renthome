import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import '../providers/wishlist_provider.dart';
import 'property_details.dart';
import '../models/property_model.dart';

class SavedTab extends StatefulWidget {
  const SavedTab({super.key});

  @override
  State<SavedTab> createState() => _SavedTabState();
}

class _SavedTabState extends State<SavedTab> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => 
      Provider.of<WishlistProvider>(context, listen: false).fetchWishlist()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Saved', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<WishlistProvider>(
        builder: (context, wishlist, _) {
          if (wishlist.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = wishlist.items;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your collections', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      _buildCollectionCard('Summer Stays', '${items.length} items', 'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?auto=format&fit=crop&w=300&q=80'),
                      const SizedBox(width: 16),
                      _buildCollectionCard('Mountain Getaways', '0 items', 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=300&q=80'),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),
                  if (items.isEmpty)
                    Center(
                      child: Column(
                        children: [
                          const SizedBox(height: 48),
                          Icon(LineIcons.heart, size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text('No saved listings yet', style: GoogleFonts.outfit(fontSize: 18, color: Colors.grey)),
                          const SizedBox(height: 8),
                          const Text('As you search, tap the heart icon to save listings here.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      itemBuilder: (context, index) => _buildSavedItem(context, items[index]),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSavedItem(BuildContext context, Property p) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PropertyDetailsScreen(property: p)),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(p.images[0], width: 80, height: 80, fit: BoxFit.cover),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.title, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text('\$${p.pricePerNight} / night', style: const TextStyle(color: Color(0xFF2D64FF))),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      Text(' ${p.rating}', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(LineIcons.heartAlt, color: Colors.red),
              onPressed: () => Provider.of<WishlistProvider>(context, listen: false).toggleWishlist(p.id),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollectionCard(String title, String count, String img) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                image: DecorationImage(image: NetworkImage(img), fit: BoxFit.cover),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(count, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
      ),
    );
  }
}
