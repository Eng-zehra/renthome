import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/booking_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class TripsTab extends StatefulWidget {
  const TripsTab({super.key});

  @override
  State<TripsTab> createState() => _TripsTabState();
}

class _TripsTabState extends State<TripsTab> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => 
      Provider.of<BookingProvider>(context, listen: false).fetchMyBookings()
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Trips', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 0,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'Past'),
            ],
            labelColor: Colors.black,
            indicatorColor: Color(0xFF2D64FF),
          ),
        ),
        body: Consumer<BookingProvider>(
          builder: (context, bookingProvider, _) {
            if (bookingProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final bookings = bookingProvider.myBookings;
            // Filter logic for upcoming vs past (simulated by checking if check_out is before today)
            final now = DateTime.now();
            final upcoming = bookings.where((b) => DateTime.parse(b['check_out']).isAfter(now)).toList();
            final past = bookings.where((b) => DateTime.parse(b['check_out']).isBefore(now)).toList();

            return TabBarView(
              children: [
                _buildBookingList(upcoming, 'No upcoming trips'),
                _buildBookingList(past, 'No past trips'),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBookingList(List<dynamic> bookings, String emptyMsg) {
    if (bookings.isEmpty) {
      return Center(child: Text(emptyMsg, style: const TextStyle(color: Colors.grey)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final b = bookings[index];
        final images = b['images'] is String ? jsonDecode(b['images']) : b['images'];
        final checkIn = DateTime.parse(b['check_in']);
        final checkOut = DateTime.parse(b['check_out']);

        return Card(
          margin: const EdgeInsets.only(bottom: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
          color: Colors.grey[50],
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(images[0], width: 100, height: 100, fit: BoxFit.cover),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(b['title'], style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text('${b['city']}, ${b['location']}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                      const SizedBox(height: 8),
                      Text(
                        '${DateFormat('MMM d').format(checkIn)} - ${DateFormat('MMM d').format(checkOut)}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text('Total: \$${b['total_price']}', style: const TextStyle(color: Color(0xFF2D64FF), fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      _buildStatusBadge(b['status'] ?? 'pending'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'confirmed': color = Colors.green; break;
      case 'cancelled': color = Colors.red; break;
      default: color = Colors.orange;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
