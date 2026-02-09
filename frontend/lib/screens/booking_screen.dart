import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import '../models/property_model.dart';
import '../providers/booking_provider.dart';
import '../providers/payment_provider.dart';
import '../models/payment_method.dart';
import 'package:intl/intl.dart';
import 'payment_methods_screen.dart';

class BookingScreen extends StatefulWidget {
  final Property property;

  const BookingScreen({super.key, required this.property});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int _guests = 1;
  DateTime _checkIn = DateTime.now().add(const Duration(days: 7));
  DateTime _checkOut = DateTime.now().add(const Duration(days: 12));
  int? _selectedCardId;
  String? _selectedPaymentType; // 'card' or 'paypal'
  String? _paypalEmail;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final provider = Provider.of<PaymentProvider>(context, listen: false);
      provider.fetchPaymentMethods().then((_) {
        if (mounted) _autoSelectPaymentMethod(provider.methods);
      });
      Provider.of<BookingProvider>(context, listen: false).fetchBlockedDates(widget.property.id);
    });
  }

  void _autoSelectPaymentMethod(List<PaymentMethod> methods) {
    if (methods.isEmpty) return;
    
    // Only auto-select if nothing is currently selected
    if (_selectedPaymentType == null && _selectedCardId == null && _paypalEmail == null) {
      final firstMethod = methods.first;
        if (firstMethod.cardType == 'PayPal') {
           _selectedPaymentType = 'paypal';
           _paypalEmail = firstMethod.cardNumber;
           _selectedCardId = null;
        } else {
           _selectedCardId = firstMethod.id;
           _selectedPaymentType = 'card';
           _paypalEmail = null;
        }
    }
    // Force UI update
    setState(() {});
  }

  void _showPayPalDialog() {
    showDialog(
      context: context,
      builder: (context) => PayPalDialog(
        onConnect: (email) async {
          // Save to provider to make it persistent
          final success = await Provider.of<PaymentProvider>(context, listen: false).addPaymentMethod({
            'card_type': 'PayPal',
            'card_holder': 'PayPal Account',
            'card_number': email,
            'expiry_date': 'N/A',
            'is_default': false,
          });

          if (success && mounted) {
            setState(() {
              _paypalEmail = email;
              _selectedPaymentType = 'paypal';
              _selectedCardId = null;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('PayPal account $email connected!'), backgroundColor: Colors.green),
            );
          }
        },
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    int nights = _checkOut.difference(_checkIn).inDays;
    double basePrice = widget.property.pricePerNight * nights;
    double serviceFee = basePrice * 0.12;
    double cleaningFee = 50.0;
    double total = basePrice + serviceFee + cleaningFee;

    final paymentProvider = Provider.of<PaymentProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm and pay'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPropertySummary(),
            const Divider(height: 48),
            _sectionTitle('Your trip'),
            _tripDetailRow(
              'Dates', 
              '${_checkIn.day}–${_checkOut.day} ${_getMonth(_checkIn.month)}',
              onTap: _selectDates,
            ),
            _tripDetailRow(
              'Guests', 
              '$_guests guest${_guests > 1 ? 's' : ''}',
              onTap: _selectGuests,
            ),
            const Divider(height: 48),
            _sectionTitle('Price details'),
            _priceRow('\$${widget.property.pricePerNight.toStringAsFixed(0)} x $nights nights', '\$${basePrice.toStringAsFixed(0)}'),
            _priceRow('Cleaning fee', '\$${cleaningFee.toStringAsFixed(0)}'),
            _priceRow('RentHome service fee', '\$${serviceFee.toStringAsFixed(0)}'),
            const Divider(),
            _priceRow('Total (USD)', '\$${total.toStringAsFixed(0)}', isTotal: true),
            const SizedBox(height: 48),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _sectionTitle('Payment method'),
                TextButton(
                  onPressed: () async {
                    await Navigator.push(context, MaterialPageRoute(builder: (context) => const PaymentMethodsScreen()));
                    if (mounted) {
                      final provider = Provider.of<PaymentProvider>(context, listen: false);
                      await provider.fetchPaymentMethods();
                      _autoSelectPaymentMethod(provider.methods);
                    }
                  },
                  child: const Text('Manage'),
                ),
              ],
            ),

            if (paymentProvider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (paymentProvider.methods.isEmpty)
              _buildNoPaymentMethod(context)
            else
              ...paymentProvider.methods.map((method) => _buildPaymentOption(method)),
            
            // Only show generic PayPal option if no PayPal account is linked
            if (!paymentProvider.methods.any((m) => m.cardType == 'PayPal'))
              _buildGenericOption(LineIcons.paypal, 'PayPal', isPayPal: true),
              
            _buildGenericOption(LineIcons.googleWallet, 'Google Pay'),

            const SizedBox(height: 48),
            Consumer<BookingProvider>(
              builder: (context, bookingProvider, _) {
                final isMethodSelected = (_selectedCardId != null && _selectedPaymentType == 'card') || 
                                        (_selectedPaymentType == 'paypal' && _paypalEmail != null);
                return SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: (bookingProvider.isLoading || !isMethodSelected) 
                      ? null 
                      : () => _handleBooking(context, bookingProvider, total),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5A5F),
                      disabledBackgroundColor: Colors.grey[300]
                    ),
                    child: bookingProvider.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          !isMethodSelected ? 'Select Payment Method' : 'Confirm and pay', 
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)
                        ),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildNoPaymentMethod(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(15),
        color: Colors.red.withOpacity(0.05),
      ),
      child: Column(
        children: [
          const Icon(LineIcons.exclamationCircle, color: Colors.red),
          const SizedBox(height: 10),
          const Text('No payment methods found', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Please add a payment method to continue booking.', style: TextStyle(fontSize: 12)),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PaymentMethodsScreen())),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              minimumSize: const Size(120, 36)
            ),
            child: const Text('Add Method', style: TextStyle(fontSize: 12)),
          )
        ],
      ),
    );
  }

  Widget _buildPaymentOption(PaymentMethod method) {
    bool isPayPal = method.cardType == 'PayPal';
    bool isSelected = (_selectedCardId == method.id && _selectedPaymentType == 'card') || 
                      (isPayPal && _selectedPaymentType == 'paypal' && _paypalEmail == method.cardNumber);
    
    // Auto-select if matches local state
    if (isSelected && isPayPal && _paypalEmail == null) {
       _paypalEmail = method.cardNumber;
    }

    return GestureDetector(
      onTap: () => setState(() {
        if (isPayPal) {
          _selectedPaymentType = 'paypal';
          _paypalEmail = method.cardNumber;
          _selectedCardId = null;
        } else {
          _selectedCardId = method.id;
          _selectedPaymentType = 'card';
          _paypalEmail = null;
        }
      }),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: isSelected ? Colors.black : Colors.grey[300]!, width: isSelected ? 2 : 1),
          borderRadius: BorderRadius.circular(15),
          color: isSelected ? Colors.black.withOpacity(0.02) : Colors.transparent,
        ),
        child: Row(
          children: [
            if (isPayPal) 
              const Icon(LineIcons.paypal, size: 30, color: Color(0xFF003087))
            else
              const Icon(Icons.credit_card, size: 30),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isPayPal ? 'PayPal' : method.cardType, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  isPayPal ? method.cardNumber : '•••• ${method.cardNumber.substring(method.cardNumber.length - 4)}', 
                  style: TextStyle(color: Colors.grey[600])
                ),
              ],
            ),
            const Spacer(),
            if (isSelected) const Icon(Icons.check_circle, color: Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildGenericOption(IconData icon, String label, {bool isPayPal = false}) {
    bool isSelected = isPayPal && _selectedPaymentType == 'paypal';
    return GestureDetector(
      onTap: isPayPal ? _showPayPalDialog : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: isSelected ? Colors.black : Colors.grey[300]!, width: isSelected ? 2 : 1),
          borderRadius: BorderRadius.circular(15),
          color: isSelected ? Colors.black.withOpacity(0.02) : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
                  if (isPayPal && _paypalEmail != null)
                    Text(_paypalEmail!, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),
            if (isSelected) 
              const Icon(Icons.check_circle, color: Colors.blue)
            else
              const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDates() async {
    debugPrint('📅 Attempting to open date picker...');
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    final blockedDates = bookingProvider.blockedDates;

    try {
      final DateTimeRange? picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime.now().subtract(const Duration(days: 1)), // Allow today
        lastDate: DateTime.now().add(const Duration(days: 365)),
        initialDateRange: DateTimeRange(start: _checkIn, end: _checkOut),
        selectableDayPredicate: (day, start, end) {
          // Check if the current day is blocked
          bool isDayBlocked = false;
          for (var blocked in blockedDates) {
            if (day.year == blocked.year && day.month == blocked.month && day.day == blocked.day) {
              isDayBlocked = true;
              break;
            }
          }

          // If the day is NOT blocked, it's selectable
          if (!isDayBlocked) return true;

          // If the day IS blocked, but it's the current selected START or END date, 
          // we must allow it to avoid the assertion error crashing the app.
          bool isSelectedDate = (day.year == _checkIn.year && day.month == _checkIn.month && day.day == _checkIn.day) ||
                               (day.year == _checkOut.year && day.month == _checkOut.month && day.day == _checkOut.day);
          
          if (isSelectedDate) {
            return true;
          }

          return false;
        },
      );

      if (picked != null) {
        debugPrint('✅ Date picked: ${picked.start} to ${picked.end}');
        setState(() {
          _checkIn = picked.start;
          _checkOut = picked.end;
        });
      }
    } catch (e) {
      debugPrint('❌ Error in showDateRangePicker: $e');
    }
  }

  void _selectGuests() {
    debugPrint('👥 Opening guest picker...');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Guests', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Guests', style: TextStyle(fontSize: 18)),
                        Row(
                          children: [
                            _countButton(Icons.remove, () {
                              if (_guests > 1) {
                                setModalState(() => _guests--);
                                setState(() {});
                              }
                            }),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text('$_guests', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ),
                            _countButton(Icons.add, () {
                              if (_guests < widget.property.maxGuests) {
                                setModalState(() => _guests++);
                                setState(() {});
                              }
                            }),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                        child: const Text('Save', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        );
      },
    );
  }

  Widget _countButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[400]!),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, size: 18),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      ),
    );
  }

  void _handleBooking(BuildContext context, BookingProvider bookingProvider, double total) async {
    final success = await bookingProvider.createBooking({
      'property_id': widget.property.id,
      'check_in': DateFormat('yyyy-MM-dd').format(_checkIn),
      'check_out': DateFormat('yyyy-MM-dd').format(_checkOut),
      'guests': _guests,
      'total_price': total,
    });

    if (success) {
      if (mounted) _showSuccessDialog(context);
    } else {
      if (mounted) {
        _showErrorDialog(context, bookingProvider.lastError ?? 'Failed to book. Please try again.');
      }
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 20),
            Text('Booking Unavailable', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _selectDates(); // Allow user to pick different dates
                    },
                    child: const Text('Change Dates'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      Navigator.pop(context); // Go back to browse other properties
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2D64FF)),
                    child: const Text('Browse More'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertySummary() {
    return Row(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(LineIcons.home, size: 40, color: Colors.black54),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.property.title, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 2),
              Text(widget.property.type, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.star, size: 14),
                  Text(' ${widget.property.rating} ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text('(128 reviews)', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: Text(title, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold)),
    );
  }

  Widget _tripDetailRow(String label, String value, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () {
          debugPrint('Row tapped: $label');
          if (onTap != null) onTap();
        },
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(value, style: TextStyle(color: Colors.grey[600], fontSize: 15)),
                  ],
                ),
              ),
              const Text(
                'Edit', 
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  color: Color(0xFF2D64FF),
                  decoration: TextDecoration.underline
                )
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _priceRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, fontSize: isTotal ? 18 : 16)),
          Text(value, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, fontSize: isTotal ? 18 : 16)),
        ],
      ),
    );
  }

  String _getMonth(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 24),
            Text('Booking Request Sent!', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text('Your booking has been requested and is pending confirmation from the host.', textAlign: TextAlign.center),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Close booking screen
                },
                child: const Text('View Trip'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
