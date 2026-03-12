import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'services/auth_service.dart';
import 'login_page.dart';
import 'main.dart'; // GreenBackground, SellerScannerPage, MyProductsPage,
// AddNewProductPage, NearbySellersPage, CommunityListPage,
// ChatbotPage, FarmPage

class SellerHome extends StatefulWidget {
  const SellerHome({super.key});

  @override
  State<SellerHome> createState() => _SellerHomeState();
}

class _SellerHomeState extends State<SellerHome> {
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _profile;
  bool _loadingProfile = true;

  // Stats (fetched from Firestore)
  int _totalProducts = 0;
  int _totalScans = 0;
  double _rating = 0.0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Load user profile
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      // Load seller stats
      final sellerDoc = await FirebaseFirestore.instance
          .collection('sellers')
          .doc(user.uid)
          .get();

      if (mounted) {
        setState(() {
          _profile = userDoc.data();
          if (sellerDoc.exists) {
            _totalProducts = sellerDoc.data()?['totalProducts'] ?? 0;
            _totalScans = sellerDoc.data()?['totalScans'] ?? 0;
            _rating = (sellerDoc.data()?['rating'] ?? 0.0).toDouble();
          }
          _loadingProfile = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loadingProfile = false);
    }
  }

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
              (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final name = _profile?['name'] ?? user?.displayName ?? 'Seller';
    final email = _profile?['email'] ?? user?.email ?? '';
    final location = _profile?['location'] ?? '';

    return Scaffold(
      body: GreenBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top Bar ──────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.qr_code_scanner,
                          color: Colors.white, size: 28),
                      const SizedBox(width: 8),
                      const Text(
                        'FreshScan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.white),
                        tooltip: 'Sign Out',
                        onPressed: _signOut,
                      ),
                    ],
                  ),
                ),

                // ── Profile Card ─────────────────────────────────────────────
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.4), width: 1),
                  ),
                  child: _loadingProfile
                      ? const Center(
                      child: CircularProgressIndicator(color: Colors.white))
                      : Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.white,
                        child: Text(
                          name.isNotEmpty
                              ? name[0].toUpperCase()
                              : 'S',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D6A4F),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              email,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 13),
                            ),
                            if (location.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(Icons.location_on,
                                      size: 13, color: Colors.white70),
                                  const SizedBox(width: 2),
                                  Text(
                                    location,
                                    style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          '🏪 Seller',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D6A4F),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Stats Row ────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _buildStatCard(
                          icon: Icons.inventory,
                          label: 'Products',
                          value: '$_totalProducts'),
                      const SizedBox(width: 12),
                      _buildStatCard(
                          icon: Icons.qr_code_scanner,
                          label: 'Scans',
                          value: '$_totalScans'),
                      const SizedBox(width: 12),
                      _buildStatCard(
                          icon: Icons.star,
                          label: 'Rating',
                          value: _rating == 0.0 ? 'New' : _rating.toStringAsFixed(1)),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Section Title ────────────────────────────────────────────
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ── Dashboard Grid ───────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 1.1,
                    children: [
                      _SellerCard(
                        icon: Icons.qr_code_scanner,
                        title: 'Product Scanner',
                        subtitle: 'Scan and add new products',
                        color: const Color(0xFF52B788),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SellerScannerPage()),
                        ),
                      ),
                      _SellerCard(
                        icon: Icons.inventory,
                        title: 'My Products',
                        subtitle: 'Manage your inventory',
                        color: Colors.orange,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MyProductsPage()),
                        ),
                      ),
                      _SellerCard(
                        icon: Icons.add_circle,
                        title: 'Add Product',
                        subtitle: 'List a new product',
                        color: Colors.blue,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AddNewProductPage()),
                        ),
                      ),
                      _SellerCard(
                        icon: Icons.people,
                        title: 'Other Sellers',
                        subtitle: 'Connect with peers',
                        color: Colors.purple,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const NearbySellersPage()),
                        ),
                      ),
                      _SellerCard(
                        icon: Icons.agriculture,
                        title: 'FreshScan Farm',
                        subtitle: 'Browse local farms',
                        color: const Color(0xFF2D6A4F),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const FarmPage()),
                        ),
                      ),
                      _SellerCard(
                        icon: Icons.groups,
                        title: 'Community',
                        subtitle: 'Network with farmers',
                        color: Colors.teal,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const CommunityListPage()),
                        ),
                      ),
                      _SellerCard(
                        icon: Icons.chat,
                        title: 'Chatbot',
                        subtitle: 'Seller assistance',
                        color: Colors.indigo,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ChatbotPage()),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: Colors.white.withOpacity(0.3), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Internal card widget ──────────────────────────────────────────────────────
class _SellerCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _SellerCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}