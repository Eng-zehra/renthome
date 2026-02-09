import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'property_details.dart';
import 'map_view.dart';
import '../models/property_model.dart';
import '../widgets/filter_sheet.dart';
import '../providers/property_provider.dart';
import '../providers/wishlist_provider.dart';
import '../providers/auth_provider.dart';
import 'admin_add_property.dart';

class ExploreTab extends StatefulWidget {
  const ExploreTab({super.key});

  @override
  State<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => 
      Provider.of<PropertyProvider>(context, listen: false).fetchProperties()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => Provider.of<PropertyProvider>(context, listen: false).fetchProperties(),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchSection(context),
                    _buildCategoryChips(),
                    _buildListingSection(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const MapViewScreen()));
        },
        backgroundColor: Colors.black,
        icon: const Icon(LineIcons.map, color: Colors.white),
        label: const Text('Map', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 20,
      title: Row(
        children: [
          const Icon(LineIcons.mapMarker, color: Color(0xFF2D64FF), size: 20),
          const SizedBox(width: 8),
          Consumer<PropertyProvider>(
             builder: (context, provider, _) => GestureDetector(
              onTap: () => _showCitySelector(context),
              child: Row(
                children: [
                  Text(
                    provider.currentCity,
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black),
                  ),
                  const Icon(Icons.keyboard_arrow_down, color: Colors.black),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: [
        Center(
          child: Container(
            margin: const EdgeInsets.only(right: 20),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[200]!),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(LineIcons.bell, color: Colors.black, size: 20),
          ),
        ),
      ],
    );
  }

  void _showCitySelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        final cities = [
          'Awdal', 'Bakool', 'Banaadir', 'Bari', 'Bay', 'Galguduud', 'Gedo', 'Hiiraan',
          'Jubbada Dhexe', 'Jubbada Hoose', 'Mudug', 'Nugaal', 'Sanaag',
          'Shabeellaha Dhexe', 'Shabeellaha Hoose', 'Sool', 'Togdheer', 'Woqooyi Galbeed', 'All'
        ];
        return Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.7, // Taller sheet for many items
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Select Region', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: cities.length,
                  itemBuilder: (context, index) {
                    final city = cities[index];
                    return ListTile(
                      title: Text(city),
                      leading: const Icon(LineIcons.mapMarker),
                      onTap: () {
                        Provider.of<PropertyProvider>(context, listen: false).filterByCity(city);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Where to?',
            style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () {}, // Search logic
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(15),
              ),
              child: TextField(
                onChanged: (val) => Provider.of<PropertyProvider>(context, listen: false).searchProperties(val),
                decoration: InputDecoration(
                  hintText: 'Search destinations...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(LineIcons.search, color: Colors.grey),
                  border: InputBorder.none,
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 1, height: 20, color: Colors.grey[300]),
                      IconButton(
                        icon: const Icon(LineIcons.horizontalSliders, color: Color(0xFF2D64FF)),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => const FilterSheet(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    final categories = ['All', 'Apartment', 'House', 'Studio', 'Villa', 'Budget', 'Luxury'];
    return Consumer<PropertyProvider>(
      builder: (context, propertyProvider, _) {
        return SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = (propertyProvider.selectedCategory ?? 'All') == category;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                child: ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (val) => propertyProvider.filterByCategory(category),
                  selectedColor: const Color(0xFF2D64FF),
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey[200]!),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildListingSection(BuildContext context) {
    return Consumer<PropertyProvider>(
      builder: (context, propertyProvider, _) {
        if (propertyProvider.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(50.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final properties = propertyProvider.properties;

        if (properties.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(50.0),
              child: Column(
                children: [
                  Icon(LineIcons.searchMinus, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('No properties found', style: GoogleFonts.outfit(fontSize: 18, color: Colors.grey)),
                  const SizedBox(height: 8),
                  const Text('Try adjusting your search or filters', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          itemCount: properties.length,
          itemBuilder: (context, index) => _buildListingCard(context, properties[index]),
        );
      },
    );
  }

  Widget _buildListingCard(BuildContext context, Property p) {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    final isAdmin = user?.role == 'admin';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PropertyDetailsScreen(property: p)),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Hero(
                  tag: 'prop-${p.id}',
                    child: Container(
                      height: 240,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: NetworkImage(p.images[0]),
                          fit: BoxFit.cover,
                          onError: (exception, stackTrace) => const Icon(Icons.error),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          p.images[0],
                          fit: BoxFit.cover,
                          height: 240,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey[200],
                            child: const Icon(LineIcons.image, color: Colors.grey, size: 40),
                          ),
                        ),
                      ),
                    ),
                ),
                Positioned(
                  top: 15,
                  right: 15,
                  child: Consumer<WishlistProvider>(
                    builder: (context, wishlist, _) {
                      final isSaved = wishlist.isSaved(p.id);
                      return GestureDetector(
                        onTap: () => wishlist.toggleWishlist(p.id),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isSaved ? LineIcons.heartAlt : LineIcons.heart, 
                            size: 20, 
                            color: isSaved ? Colors.red : Colors.black
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (isAdmin)
                  Positioned(
                    top: 15,
                    left: 15,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => AdminAddPropertyScreen(property: p)),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(LineIcons.edit, size: 20, color: Colors.blue),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _showDeleteDialog(context, p),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(LineIcons.trash, size: 20, color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    p.title,
                    style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 18),
                    Text(' ${p.rating}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            Text('${p.location}, ${p.city}', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 4),
            Text(
              '\$${p.pricePerNight.toStringAsFixed(0)} night',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2D64FF),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Property p) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Property'),
        content: Text('Are you sure you want to delete "${p.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final success = await Provider.of<PropertyProvider>(context, listen: false).deleteProperty(p.id);
              if (success && mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Property deleted successfully'), backgroundColor: Colors.green),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
