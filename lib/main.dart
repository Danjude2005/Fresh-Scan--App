import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'seller_home.dart';
import 'services/product_service.dart';
import 'services/seller_service.dart';
import 'services/community_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const FreshScanApp());
}

/* ================= APP ROOT ================= */

class FreshScanApp extends StatelessWidget {
  const FreshScanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FreshScan',
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF2D6A4F),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2D6A4F),
          primary: const Color(0xFF2D6A4F),
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasData) {
            return const SellerHome();
          }
          return const HomeScreen();
        },
      ),
    );
  }
}

/* ================= GREEN BACKGROUND ================= */

class GreenBackground extends StatelessWidget {
  final Widget child;
  const GreenBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFC7F9CC),
            Color(0xFF52B788),
            Color(0xFF2D6A4F),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(child: child),
    );
  }
}

/* ================= HOME SCREEN ================= */

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GreenBackground(
        child: Stack(
          children: [
            Positioned(
              top: 10,
              left: 16,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                },
                child: const Text(
                  "Login",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 16,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const VideoPage()),
                  );
                },
                child: const Text(
                  "Know more",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.qr_code_scanner,
                    size: 110,
                    color: Colors.white,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "FreshScan",
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Scan • Verify • Eat Fresh",
                    style: TextStyle(color: Colors.white70),
                  ),
                  SizedBox(height: 50),
                  Text(
                    "Ready to check your food?",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ================= VIDEO PAGE ================= */

class VideoPage extends StatelessWidget {
  const VideoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Know More"),
        backgroundColor: const Color(0xFF2D6A4F),
        foregroundColor: Colors.white,
      ),
      body: GreenBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.play_circle_filled,
                size: 80,
                color: Colors.white,
              ),
              const SizedBox(height: 20),
              const Text(
                "How FreshScan Works",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 30),
                child: const Text(
                  "FreshScan helps you verify the freshness of your food using advanced scanning technology. "
                      "Sellers can list their products and buyers can check freshness before purchase.",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ================= BUYER DASHBOARD PAGE ================= */

class BuyerDashboardPage extends StatelessWidget {
  const BuyerDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Buyer Dashboard"),
        backgroundColor: const Color(0xFF2D6A4F),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
            },
          )
        ],
      ),
      body: GreenBackground(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              "Welcome, Buyer!",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                padding: const EdgeInsets.all(20),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: const [
                  DashboardCard(
                    Icons.qr_code_scanner,
                    "Scanner",
                    "Scan products to check freshness",
                  ),
                  DashboardCard(
                    Icons.agriculture,
                    "FreshScan Farm",
                    "Browse local farms",
                  ),
                  DashboardCard(
                    Icons.groups,
                    "Join Community",
                    "Connect with others",
                  ),
                  DashboardCard(
                    Icons.smart_toy,
                    "Chatbot",
                    "Get instant help",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ================= DASHBOARD CARD ================= */

class DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const DashboardCard(this.icon, this.title, this.subtitle, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: () => _handleNavigation(context),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: Colors.green[800],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
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

  void _handleNavigation(BuildContext context) {
    switch (title) {
      case "Scanner":
      case "Product Scanner":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SellerScannerPage()),
        );
        break;
      case "My Products":
      case "Add Products":
      case "Add Product":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MyProductsPage()),
        );
        break;
      case "FreshScan Farm":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FarmPage()),
        );
        break;
      case "Join Community":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CommunityListPage()),
        );
        break;
      case "Chatbot":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChatbotPage()),
        );
        break;
      case "View Other Sellers":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NearbySellersPage()),
        );
        break;
    }
  }
}

/* ================= SELLER SCANNER PAGE ================= */

class SellerScannerPage extends StatefulWidget {
  const SellerScannerPage({super.key});

  @override
  State<SellerScannerPage> createState() => _SellerScannerPageState();
}

class _SellerScannerPageState extends State<SellerScannerPage> {
  int? freshness, nutrition, pesticides, shelfLife;
  bool scanning = false;
  final ProductService _productService = ProductService();

  Future<void> scanProduct() async {
    setState(() {
      scanning = true;
      freshness = null;
    });

    await Future.delayed(const Duration(seconds: 2));
    final r = Random();

    int f = r.nextInt(101);
    int n = r.nextInt(101);
    int p = r.nextInt(101);
    int sl = r.nextInt(30) + 1;

    setState(() {
      freshness = f;
      nutrition = n;
      pesticides = p;
      shelfLife = sl;
      scanning = false;
    });

    await _productService.saveScanResult(
      name: "Scanned Item",
      freshness: f,
      nutrition: n,
      pesticides: p,
      shelfLife: sl,
    );
  }

  @override
  Widget build(BuildContext context) {
    final accepted = freshness != null && freshness! >= 75;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Product Scanner"),
        backgroundColor: const Color(0xFF2D6A4F),
        foregroundColor: Colors.white,
      ),
      body: GreenBackground(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              height: 200,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white, width: 3),
                color: const Color(0xFF2D6A4F).withOpacity(0.5),
              ),
              child: Center(
                child: scanning
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.qr_code_scanner,
                      size: 80,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Position QR code in frame",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: scanning ? null : scanProduct,
              icon: Icon(scanning ? Icons.hourglass_empty : Icons.camera_alt),
              label: Text(scanning ? "Scanning..." : "Scan Product"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF2D6A4F),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
            const SizedBox(height: 20),
            if (freshness != null)
              Card(
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            accepted ? Icons.check_circle : Icons.warning,
                            color: accepted ? Colors.green : Colors.red,
                            size: 30,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            accepted ? "Product Accepted" : "Product Rejected",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: accepted ? Colors.green : Colors.red),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      _buildDetailRow("Freshness", "$freshness%", freshness ?? 0),
                      _buildDetailRow("Nutrition", "$nutrition%", nutrition ?? 0),
                      _buildDetailRow("Shelf Life", "$shelfLife days", shelfLife ?? 0),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => setState(() => freshness = null),
                              child: const Text("Scan Again"),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: accepted ? () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => AddNewProductPage(
                                  scannedFreshness: freshness,
                                  scannedNutrition: nutrition,
                                  scannedPesticides: pesticides,
                                  scannedShelfLife: shelfLife,
                                )));
                              } : null,
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2D6A4F), foregroundColor: Colors.white),
                              child: const Text("Add Product"),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, int score) {
    Color color = score >= 75 ? Colors.green : (score >= 50 ? Colors.orange : Colors.red);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey))),
          Expanded(child: LinearProgressIndicator(value: score / 100, backgroundColor: Colors.grey[200], valueColor: AlwaysStoppedAnimation<Color>(color), minHeight: 6)),
          const SizedBox(width: 8),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

/* ================= CHATBOT PAGE ================= */

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    setState(() {
      _messages.add({"text": _messageController.text, "isUser": true});
      String response = "I'm here to help! You can ask about product freshness or how to use the scanner.";
      if (_messageController.text.toLowerCase().contains("freshness")) response = "Freshness is calculated based on nutrient retention and shelf life.";
      _messages.add({"text": response, "isUser": false});
      _messageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Assistant"), backgroundColor: const Color(0xFF2D6A4F), foregroundColor: Colors.white),
      body: GreenBackground(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final m = _messages[index];
                  return Align(
                    alignment: m['isUser'] ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: m['isUser'] ? const Color(0xFF2D6A4F) : Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: Text(m['text'], style: TextStyle(color: m['isUser'] ? Colors.white : Colors.black)),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(child: TextField(controller: _messageController, decoration: const InputDecoration(hintText: "Ask something..."))),
                  IconButton(icon: const Icon(Icons.send, color: Color(0xFF2D6A4F)), onPressed: _sendMessage),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ================= MY PRODUCTS PAGE ================= */

class MyProductsPage extends StatelessWidget {
  const MyProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ProductService _productService = ProductService();
    return Scaffold(
      appBar: AppBar(title: const Text("My Products"), backgroundColor: const Color(0xFF2D6A4F), foregroundColor: Colors.white),
      body: GreenBackground(
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _productService.getSellerProducts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.white));
            final products = snapshot.data ?? [];
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: products.length + 1,
              itemBuilder: (context, index) {
                if (index == products.length) return _buildAddCard(context);
                final p = products[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(p['name']),
                    subtitle: Text("${p['category']} • ${p['status']} (${p['freshness']}%)"),
                    trailing: Text("₹${p['price']}/kg", style: const TextStyle(fontWeight: FontWeight.bold)),
                    onLongPress: () => _productService.deleteProduct(p['id']),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildAddCard(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.add_circle, color: Color(0xFF2D6A4F)),
        title: const Text("Add New Product"),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddNewProductPage())),
      ),
    );
  }
}

/* ================= ADD NEW PRODUCT PAGE ================= */

class AddNewProductPage extends StatefulWidget {
  final int? scannedFreshness, scannedNutrition, scannedPesticides, scannedShelfLife;
  const AddNewProductPage({super.key, this.scannedFreshness, this.scannedNutrition, this.scannedPesticides, this.scannedShelfLife});

  @override
  State<AddNewProductPage> createState() => _AddNewProductPageState();
}

class _AddNewProductPageState extends State<AddNewProductPage> {
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final quantityController = TextEditingController();
  String category = "Vegetable";
  bool isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Product"), backgroundColor: const Color(0xFF2D6A4F), foregroundColor: Colors.white),
      body: GreenBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: "Product Name")),
                TextField(controller: priceController, decoration: const InputDecoration(labelText: "Price/kg"), keyboardType: TextInputType.number),
                TextField(controller: quantityController, decoration: const InputDecoration(labelText: "Quantity (e.g. 10 kg)")),
                DropdownButtonFormField<String>(
                  value: category,
                  items: ["Vegetable", "Fruit", "Leafy"].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setState(() => category = v!),
                  decoration: const InputDecoration(labelText: "Category"),
                ),
                const SizedBox(height: 20),
                if (widget.scannedFreshness == null) 
                  ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SellerScannerPage())), child: const Text("Scan for Freshness")),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2D6A4F), foregroundColor: Colors.white),
                    child: isSaving ? const CircularProgressIndicator() : const Text("Save Product"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (widget.scannedFreshness == null) return;
    setState(() => isSaving = true);
    await ProductService().addProduct(
      name: nameController.text,
      category: category,
      freshness: widget.scannedFreshness!,
      nutrition: widget.scannedNutrition ?? 0,
      pesticides: widget.scannedPesticides ?? 0,
      price: double.tryParse(priceController.text) ?? 0.0,
      quantity: quantityController.text,
      shelfLife: widget.scannedShelfLife ?? 0,
    );
    Navigator.pop(context);
  }
}

/* ================= NEARBY SELLERS PAGE ================= */

class NearbySellersPage extends StatelessWidget {
  const NearbySellersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final SellerService _sellerService = SellerService();
    return Scaffold(
      appBar: AppBar(title: const Text("Nearby Sellers"), backgroundColor: const Color(0xFF2D6A4F), foregroundColor: Colors.white),
      body: GreenBackground(
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _sellerService.getSellers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.white));
            final sellers = snapshot.data ?? [];
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sellers.length,
              itemBuilder: (context, index) {
                final s = sellers[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.store, color: Color(0xFF2D6A4F)),
                    title: Text(s['name'] ?? 'Seller'),
                    subtitle: Text(s['location'] ?? 'Location unknown'),
                    trailing: Text("⭐ ${s['rating'] ?? 'N/A'}"),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/* ================= COMMUNITY LIST PAGE ================= */

class CommunityListPage extends StatelessWidget {
  const CommunityListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final CommunityService _communityService = CommunityService();
    return Scaffold(
      appBar: AppBar(title: const Text("Communities"), backgroundColor: const Color(0xFF2D6A4F), foregroundColor: Colors.white),
      body: GreenBackground(
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _communityService.getCommunities(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.white));
            final communities = snapshot.data ?? [];
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: communities.length,
              itemBuilder: (context, index) {
                final c = communities[index];
                final isMember = (c['members'] as List?)?.contains(FirebaseAuth.instance.currentUser?.uid) ?? false;
                return Card(
                  child: ListTile(
                    title: Text(c['name']),
                    subtitle: Text("${c['memberCount']} members • ${c['type']}"),
                    trailing: ElevatedButton(
                      onPressed: () => _communityService.toggleJoin(c['id'], !isMember),
                      child: Text(isMember ? "Joined" : "Join"),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context, _communityService),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateDialog(BuildContext context, CommunityService service) {
    final nameController = TextEditingController();
    showDialog(context: context, builder: (context) => AlertDialog(
      title: const Text("Create Community"),
      content: TextField(controller: nameController, decoration: const InputDecoration(labelText: "Community Name")),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        TextButton(onPressed: () {
          service.createCommunity(name: nameController.text, type: "Mixed", description: "A new community for FreshScan users.");
          Navigator.pop(context);
        }, child: const Text("Create")),
      ],
    ));
  }
}

/* ================= FRESHSCAN FARM PAGE ================= */

class FarmPage extends StatelessWidget {
  const FarmPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ProductService _productService = ProductService();
    return Scaffold(
      appBar: AppBar(title: const Text("FreshScan Farm"), backgroundColor: const Color(0xFF2D6A4F), foregroundColor: Colors.white),
      body: GreenBackground(
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _productService.getAllProducts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.white));
            final products = snapshot.data ?? [];
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final p = products[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(p['name']),
                    subtitle: Text("${p['sellerName']} • ${p['status']}"),
                    trailing: Text("₹${p['price']}/kg", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
