import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/property_provider.dart';
import '../services/api_service.dart';
import '../models/property_model.dart';

class AdminAddPropertyScreen extends StatefulWidget {
  final Property? property; 
  const AdminAddPropertyScreen({super.key, this.property});

  @override
  State<AdminAddPropertyScreen> createState() => _AdminAddPropertyScreenState();
}

class _AdminAddPropertyScreenState extends State<AdminAddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _locationController;
  late TextEditingController _cityController;
  late TextEditingController _ratingController;

  String _selectedType = 'Apartment';
  final List<String> _types = ['Apartment', 'House', 'Studio', 'Villa', 'Budget', 'Luxury'];

  int _bedrooms = 1;
  int _beds = 1;
  int _bathrooms = 1;

  final List<String> _commonAmenities = ['WiFi', 'Pool', 'AC', 'Kitchen', 'Parking', 'TV', 'Gym'];
  List<String> _selectedAmenities = [];

  String? _uploadedImageUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    final p = widget.property;
    _titleController = TextEditingController(text: p?.title ?? '');
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _priceController = TextEditingController(text: p?.pricePerNight.toString() ?? '');
    _locationController = TextEditingController(text: p?.location ?? '');
    _cityController = TextEditingController(text: p?.city ?? '');
    _ratingController = TextEditingController(text: p?.rating.toString() ?? '0');
    
    if (p != null) {
      _selectedType = p.type;
      _bedrooms = p.bedrooms;
      _beds = p.beds;
      _bathrooms = p.bathrooms;
      _uploadedImageUrl = p.images.isNotEmpty ? p.images[0] : null;
      _selectedAmenities = List.from(p.amenities);
    } else {
      _selectedAmenities = ['WiFi', 'Kitchen'];
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.property != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Property' : 'Add New Property', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel('Property Title'),
                _buildTextField(_titleController, 'e.g. Luxury Villa with Pool', LineIcons.home),
                
                const SizedBox(height: 20),
                _buildLabel('Description'),
                _buildTextField(_descriptionController, 'Describe the property...', LineIcons.font, maxLines: 3),
                
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Category'),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedType,
                                isExpanded: true,
                                items: _types.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value, style: GoogleFonts.outfit()),
                                  );
                                }).toList(),
                                onChanged: (val) => setState(() => _selectedType = val!),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Price / Night'),
                          _buildTextField(_priceController, 'e.g. 250', LineIcons.dollarSign, isNumber: true),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Location'),
                          _buildTextField(_locationController, 'e.g. Malibu', LineIcons.mapMarker),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('City'),
                          _buildTextField(_cityController, 'e.g. California', LineIcons.city),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                _buildLabel('Property Image'),
                GestureDetector(
                  onTap: _isUploading ? null : _pickAndUploadImage,
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey[300]!),
                      image: _uploadedImageUrl != null 
                        ? DecorationImage(image: NetworkImage(_uploadedImageUrl!), fit: BoxFit.cover)
                        : null,
                    ),
                    child: _isUploading 
                      ? const Center(child: CircularProgressIndicator())
                      : _uploadedImageUrl == null 
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(LineIcons.camera, size: 40, color: Colors.grey),
                                Text('Select Image from Computer', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          )
                        : null,
                  ),
                ),
                
                const SizedBox(height: 20),
                _buildLabel('Rating (0-5)'),
                _buildTextField(_ratingController, 'e.g. 4.8', LineIcons.star, isNumber: true),

                const SizedBox(height: 20),
                _buildLabel('Details'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStepper('Bedrooms', _bedrooms, (val) => setState(() => _bedrooms = val)),
                    _buildStepper('Beds', _beds, (val) => setState(() => _beds = val)),
                    _buildStepper('Baths', _bathrooms, (val) => setState(() => _bathrooms = val)),
                  ],
                ),
                
                const SizedBox(height: 20),
                _buildLabel('Amenities'),
                Wrap(
                  spacing: 10,
                  children: _commonAmenities.map((amenity) {
                    final isSelected = _selectedAmenities.contains(amenity);
                    return FilterChip(
                      label: Text(amenity, style: GoogleFonts.outfit(fontSize: 12)),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedAmenities.add(amenity);
                          } else {
                            _selectedAmenities.remove(amenity);
                          }
                        });
                      },
                      selectedColor: const Color(0xFF2D64FF).withOpacity(0.2),
                      checkmarkColor: const Color(0xFF2D64FF),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 40),
                Consumer<PropertyProvider>(
                  builder: (context, provider, _) {
                    return SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: provider.isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2D64FF),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: provider.isLoading 
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(isEditing ? 'Update Property' : 'Upload Property', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    );
                  }
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(text, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool isNumber = false, int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
      ),
    );
  }

  Widget _buildStepper(String label, int value, Function(int) onChanged) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
        Row(
          children: [
            IconButton(
              icon: const Icon(LineIcons.minusCircle, size: 20),
              onPressed: value > 1 ? () => onChanged(value - 1) : null,
            ),
            Text('$value', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(LineIcons.plusCircle, size: 20),
              onPressed: () => onChanged(value + 1),
            ),
          ],
        )
      ],
    );
  }

  void _pickAndUploadImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );

    if (result != null) {
      setState(() => _isUploading = true);
      final bytes = result.files.first.bytes;
      final name = result.files.first.name;

      if (bytes != null) {
        final url = await ApiService.uploadImage(bytes, name);
        setState(() {
          _uploadedImageUrl = url;
          _isUploading = false;
        });
      }
    }
  }

  void _submitForm() async {
    if (_uploadedImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload an image first'), backgroundColor: Colors.orange),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final Map<String, dynamic> data = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'type': _selectedType,
        'price_per_night': double.parse(_priceController.text),
        'location': _locationController.text,
        'city': _cityController.text,
        'bedrooms': _bedrooms,
        'beds': _beds,
        'bathrooms': _bathrooms,
        'amenities': _selectedAmenities,
        'rating': double.parse(_ratingController.text),
        'images': [_uploadedImageUrl],
      };

      bool success;
      if (widget.property != null) {
        success = await Provider.of<PropertyProvider>(context, listen: false).updateProperty(widget.property!.id, data);
      } else {
        success = await Provider.of<PropertyProvider>(context, listen: false).addProperty(data);
      }

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.property != null ? 'Property updated successfully!' : 'Property added successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } else if (mounted) {
        // We need to get the error message from the provider if possible, but for now let's just make the message clearer
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save property. Please check your admin permissions or form data.'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
