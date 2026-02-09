import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FilterSheet extends StatefulWidget {
  const FilterSheet({super.key});

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  RangeValues _priceRange = const RangeValues(50, 500);
  int _bedrooms = 1;
  int _beds = 1;
  int _bathrooms = 1;
  final List<String> _propertyTypes = ['Apartment', 'House', 'Studio', 'Villa', 'Luxury'];
  String _selectedType = 'Apartment';
  final Map<String, bool> _amenities = {
    'Wi-Fi': true,
    'AC': false,
    'Kitchen': true,
    'Parking': false,
    'Washer': false,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filters',
                  style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Reset all', style: TextStyle(color: Colors.grey)),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 20),
            _sectionTitle('Price Range'),
            RangeSlider(
              values: _priceRange,
              min: 0,
              max: 1000,
              divisions: 20,
              activeColor: const Color(0xFF2D64FF),
              labels: RangeLabels(
                '\$${_priceRange.start.round()}',
                '\$${_priceRange.end.round()}',
              ),
              onChanged: (values) => setState(() => _priceRange = values),
            ),
            const SizedBox(height: 20),
            _sectionTitle('Rooms and Beds'),
            _stepperRow('Bedrooms', _bedrooms, (val) => setState(() => _bedrooms = val)),
            _stepperRow('Beds', _beds, (val) => setState(() => _beds = val)),
            _stepperRow('Bathrooms', _bathrooms, (val) => setState(() => _bathrooms = val)),
            const SizedBox(height: 24),
            _sectionTitle('Property Type'),
            Wrap(
              spacing: 10,
              children: _propertyTypes.map((type) {
                final isSelected = _selectedType == type;
                return ChoiceChip(
                  label: Text(type),
                  selected: isSelected,
                  onSelected: (val) => setState(() => _selectedType = type),
                  selectedColor: const Color(0xFF2D64FF).withOpacity(0.1),
                  labelStyle: TextStyle(color: isSelected ? const Color(0xFF2D64FF) : Colors.black),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            _sectionTitle('Amenities'),
            _amenitiesGrid(),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Show 150+ stays'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _stepperRow(String label, int value, Function(int) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Row(
            children: [
              _circleIconBtn(Icons.remove, () => value > 0 ? onChanged(value - 1) : null),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('$value', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              _circleIconBtn(Icons.add, () => onChanged(value + 1)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _circleIconBtn(IconData icon, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Icon(icon, size: 20, color: onTap == null ? Colors.grey : Colors.black),
      ),
    );
  }

  Widget _amenitiesGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 4,
      children: _amenities.keys.map((key) {
        return CheckboxListTile(
          title: Text(key, style: const TextStyle(fontSize: 14)),
          value: _amenities[key],
          onChanged: (val) => setState(() => _amenities[key] = val!),
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: const Color(0xFF2D64FF),
        );
      }).toList(),
    );
  }
}
