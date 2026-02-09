import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/admin_provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    final provider = Provider.of<AdminProvider>(context, listen: false);
    await Future.wait([
      provider.fetchDashboardStats(),
      provider.fetchAllBookings(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FE),
        appBar: AppBar(
          title: Text('Admin Panel', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          bottom: TabBar(
            labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            labelColor: const Color(0xFF2D64FF),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF2D64FF),
            tabs: [
              const Tab(text: 'Overview'),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Bookings'),
                    if (adminProvider.pendingBookings > 0)
                      Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        child: Text(
                          adminProvider.pendingBookings.toString(),
                          style: const TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshData,
            ),
          ],
        ),
        body: TabBarView(
          children: [
            // Overview Tab
            _buildOverviewTab(adminProvider, currencyFormat),
            
            // Bookings Tab
            _buildBookingsTab(adminProvider, currencyFormat),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(AdminProvider provider, NumberFormat format) {
    if (provider.isLoading) return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Key Performance Indicators', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard('Revenue', format.format(provider.totalRevenue), Icons.payments, Colors.green),
              _buildStatCard('Users', provider.totalUsers.toString(), Icons.people, Colors.blue),
              _buildStatCard('Properties', provider.totalProperties.toString(), Icons.home, Colors.orange),
              _buildStatCard('Pending', provider.pendingBookings.toString(), Icons.hourglass_empty, Colors.red),
            ],
          ),
          const SizedBox(height: 30),
          Text('Revenue Analytics', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildChart(provider),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildBookingsTab(AdminProvider provider, NumberFormat format) {
    if (provider.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading bookings...'),
          ],
        ),
      );
    }
    
    if (provider.bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox_outlined, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No bookings found', style: TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 8),
            const Text('Bookings will appear here once customers make reservations', 
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshData,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.bookings.length,
        itemBuilder: (context, index) {
          final booking = provider.bookings[index];
          return _buildBookingCard(booking, format);
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: color.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChart(AdminProvider provider) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20)],
      ),
      child: provider.chartData.isEmpty
          ? const Center(child: Text("Initializing charts..."))
          : LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index >= 0 && index < provider.chartData.length) {
                          DateTime date = DateTime.parse(provider.chartData[index]['date']);
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(DateFormat('dd/MM').format(date), style: const TextStyle(fontSize: 9, color: Colors.grey)),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: provider.chartData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value['dailyRevenue'])).toList(),
                    isCurved: true,
                    color: const Color(0xFF2D64FF),
                    barWidth: 4,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF2D64FF).withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildBookingCard(dynamic booking, NumberFormat format) {
    final rawStatus = booking['status'];
    final status = (rawStatus ?? 'pending').toString().toLowerCase().trim();
    
    Color statusColor;
    switch (status) {
      case 'confirmed': statusColor = Colors.green; break;
      case 'cancelled': statusColor = Colors.red; break;
      default: statusColor = Colors.orange;
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey[200],
                backgroundImage: booking['customer_avatar'] != null ? NetworkImage(booking['customer_avatar']) : null,
                child: booking['customer_avatar'] == null ? Icon(Icons.person, color: Colors.grey) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking['customer_name'] ?? 'Guest', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(booking['customer_email'] ?? 'No email', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Text(status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              const Icon(Icons.home_outlined, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(booking['property_title'] ?? 'Property', style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text('${DateFormat('MMM dd').format(DateTime.parse(booking['check_in']))} - ${DateFormat('MMM dd').format(DateTime.parse(booking['check_out']))}', style: TextStyle(color: Colors.grey[700])),
              const Spacer(),
              Text(format.format(double.tryParse(booking['total_price'].toString()) ?? 0), style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xFF2D64FF))),
            ],
          ),
          const SizedBox(height: 16),
          if (status == 'pending')
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _updateStatus(booking['id'], 'cancelled'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red, 
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12)
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateStatus(booking['id'], 'confirmed'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12)
                    ),
                    child: const Text('Confirm'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _updateStatus(dynamic id, String status) async {
    final success = await Provider.of<AdminProvider>(context, listen: false).updateBookingStatus(id, status);
    if (!mounted) return;
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking ${status.toUpperCase()} successfully'), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Failed to update booking status'), backgroundColor: Colors.red),
      );
    }
  }
}
