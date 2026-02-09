import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import '../providers/property_provider.dart';
import 'property_details.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final propertyProvider = Provider.of<PropertyProvider>(context);
    final properties = propertyProvider.properties;

    return Scaffold(
      body: Stack(
        children: [
          // Styled Map Background
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFE5E3DF),
              image: DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1524661135-423995f22d0b?auto=format&fit=crop&w=1920&q=80'),
                fit: BoxFit.cover,
                opacity: 0.8,
              ),
            ),
          ),
          
          // Dynamic Pins from Real Data
          if (properties.isNotEmpty)
            ...properties.asMap().entries.map((entry) {
              int idx = entry.key;
              var p = entry.value;
              double top = 150 + (idx * 85.0) % 350;
              double left = 40 + (idx * 130.0) % 280;
              
              return _buildMapPin(
                context, 
                idx,
                top, 
                left, 
                '\$${p.pricePerNight.toStringAsFixed(0)}',
                isSelected: _selectedIndex == idx,
              );
            }).toList(),
          
          // Top Navigation
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                      ),
                      child: const Icon(Icons.close, color: Colors.black, size: 20),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                    ),
                    child: Row(
                      children: [
                        const Icon(LineIcons.horizontalSliders, size: 18, color: Colors.black),
                        const SizedBox(width: 8),
                        Text('Filters', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom Carousel with Real Data
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 140,
              child: properties.isEmpty 
                ? const SizedBox.shrink()
                : PageView.builder(
                    itemCount: properties.length,
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() => _selectedIndex = index);
                    },
                    itemBuilder: (context, index) {
                      final p = properties[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => PropertyDetailsScreen(property: p)),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10))],
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: Image.network(
                                  p.images.isNotEmpty ? p.images[0] : 'https://images.unsplash.com/photo-1568605114967-8130f3a36994', 
                                  width: 110, 
                                  height: 110, 
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    width: 110,
                                    height: 110,
                                    color: Colors.grey[100],
                                    child: const Icon(LineIcons.image, color: Colors.grey),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      p.title, 
                                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16), 
                                      maxLines: 1, 
                                      overflow: TextOverflow.ellipsis
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.star, color: Colors.amber, size: 14),
                                        const SizedBox(width: 4),
                                        Text('${p.rating} • Superhost', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '\$${p.pricePerNight.toStringAsFixed(0)} / night', 
                                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 17, color: const Color(0xFF2D64FF))
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPin(BuildContext context, int index, double top, double left, String price, {bool isSelected = false}) {
    return Positioned(
      top: top,
      left: left,
      child: GestureDetector(
        onTap: () {
          if (_pageController.hasClients) {
            _pageController.animateToPage(
              index, 
              duration: const Duration(milliseconds: 300), 
              curve: Curves.easeInOut
            );
          }
          setState(() => _selectedIndex = index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 4))],
          ),
          child: Text(
            price, 
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold, 
              fontSize: 14, 
              color: isSelected ? Colors.white : Colors.black
            )
          ),
        ),
      ),
    );
  }
}
