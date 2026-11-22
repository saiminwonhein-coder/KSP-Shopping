import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    anonKey: const String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY'),
  );

  runApp(const KspApp());
}

final supabase = Supabase.instance.client;

const navy = Color(0xFF102A43);
const gold = Color(0xFFD4AF37);
const String adminPin = '1234';

class Product {
  Product({
    required this.id,
    required this.mm,
    required this.en,
    required this.category,
    required this.price,
    required this.emoji,
  });

  factory Product.fromMap(Map<String, dynamic> map) => Product(
        id: (map['id'] as num).toInt(),
        mm: map['mm'].toString(),
        en: map['en'].toString(),
        category: map['category'].toString(),
        price: (map['price'] as num).toInt(),
        emoji: map['emoji'].toString(),
      );

  final int id;
  final String mm, en, category, emoji;
  final int price;
}

class KspApp extends StatefulWidget {
  const KspApp({super.key});
  @override
  State<KspApp> createState() => _KspAppState();
}

class _KspAppState extends State<KspApp> {
  bool english = false;
  bool loading = true;
  bool isAdmin = false;
  int page = 0;
  String category = 'အားလုံး';
  String? errorMessage;

  final Map<int, int> cart = {};
  List<Product> products = [];
  List> orders = [];

  @override
  void initState() {
    super.initState();
    fetchAllData();
  }

  Future<void> fetchAllData() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });
    try {
      final prodData = await supabase.from('products').select().order('id');
      products = prodData.map((e) => Product.fromMap(e)).toList();

      if (isAdmin) {
        final orderData = await supabase.from('orders').select().order('id', ascending: false);
        orders = orderData.map((e) => Map<String, dynamic>.from(e)).toList();
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      setState(() => loading = false);
    }
  }

  String tr(String mm, String en) => english ? en : mm;
  int get count => cart.values.fold(0, (a, b) => a + b);
  int get total {
    int sum = 0;
    cart.forEach((id, qty) {
      final matches = products.where((item) => item.id == id);
      if (matches.isNotEmpty) {
        sum += matches.first.price * qty;
      }
    });
    return sum;
  }

  void toggleAdminMode(BuildContext ctx) {
    if (isAdmin) {
      setState(() {
        isAdmin = false;
        page = 0;
      });
      return;
    }

    final pinCtrl = TextEditingController();
    showDialog(
      context: ctx,
      builder: (dCtx) => AlertDialog(
        title: Text(tr('Admin ဝင်ရောက်ရန်', 'Admin Login')),
        content: TextField(
          controller: pinCtrl,
          obscureText: true,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: tr('PIN နံပါတ်ရိုက်ထည့်ပါ (1234)', 'Enter Admin PIN (1234)'),
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dCtx), child: Text(tr('ပယ်ဖျက်', 'Cancel'))),
          FilledButton(
            onPressed: () {
              if (pinCtrl.text.trim() == adminPin) {
                Navigator.pop(dCtx);
                setState(() {
                  isAdmin = true;
                  page = 0;
                });
                fetchAllData();
              } else {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(content: Text(tr('PIN နံပါတ် မှားယွင်းနေပါသည်', 'Incorrect PIN'))),
                );
              }
            },
            child: Text(tr('ဝင်မည်', 'Login')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KSP Shopping',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: navy),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: isAdmin ? const Color(0xFF7B1E1E) : navy,
          foregroundColor: Colors.white,
        ),
      ),
      home: Builder(
        builder: (ctx) => Scaffold(
          appBar: AppBar(
            title: Text(
              isAdmin ? 'KSP ADMIN PANEL' : 'KSP SHOPPING',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(onPressed: fetchAllData, icon: const Icon(Icons.refresh)),
              TextButton(
                onPressed: () => setState(() => english = !english),
                child: Text(english ? 'မြန်မာ' : 'EN', style: const TextStyle(color: Colors.white)),
              ),
              if (!isAdmin)
                IconButton(
                  onPressed: () => setState(() => page = 1),
                  icon: Badge(
                    isLabelVisible: count > 0,
                    label: Text('$count'),
                    child: const Icon(Icons.shopping_cart_outlined),
                  ),
                ),
              IconButton(
                tooltip: isAdmin ? 'Exit Admin' : 'Admin Login',
                onPressed: () => toggleAdminMode(ctx),
                icon: Icon(isAdmin ? Icons.logout : Icons.lock_outline),
              ),
            ],
          ),
          body: loading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.wifi_off, size: 48, color: Colors.red),
                            const SizedBox(height: 12),
                            Text('Connection Error:\n$errorMessage', textAlign: TextAlign.center),
                            const SizedBox(height: 12),
                            FilledButton(onPressed: fetchAllData, child: const Text('ပြန်ကြိုးစားမည် / Retry')),
                          ],
                        ),
                      ),
                    )
                  : isAdmin
                      ? IndexedStack(index: page, children: [adminProductsPage(), adminOrdersPage()])
                      : IndexedStack(index: page, children: [shop(), cartPage(ctx)]),
          bottomNavigationBar: NavigationBar(
            selectedIndex: page,
            onDestinationSelected: (v) => setState(() => page = v),
            destinations: isAdmin
                ? [
                    NavigationDestination(icon: const Icon(Icons.inventory), label: tr('ပစ္စည်းစီမံရန်', 'Products')),
                    NavigationDestination(icon: const Icon(Icons.receipt_long), label: tr('အော်ဒါများ', 'Orders')),
                  ]
                : [
                    NavigationDestination(icon: const Icon(Icons.storefront), label: tr('ပင်မ', 'Shop')),
                    NavigationDestination(icon: const Icon(Icons.shopping_basket), label: tr('ဈေးခြင်း', 'Cart')),
                  ],
          ),
        ),
      ),
    );
  }

  Widget shop() {
    final items = products.where((p) => category == 'အားလုံး' || p.category == category).toList();
    return ListView(padding: const EdgeInsets.all(16), children: [
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [navy, Color(0xFF245477)]),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(tr('ထိုင်းနိုင်ငံထုတ် ကုန်ပစ္စည်းများ', 'Products from Thailand'),
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(tr('အချိုရည် • မုန့် • ကျန်းမာရေးသုံးပစ္စည်း', 'Drinks • Snacks • Healthcare'),
              style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 12),
          const Text('KSP SHOPPING', style: TextStyle(color: gold, letterSpacing: 2)),
        ]),
      ),
      const SizedBox(height: 18),
      Text(tr('ကုန်ပစ္စည်းအမျိုးအစား', 'Categories'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      Wrap(spacing: 8, children: [
        chip('အားလုံး', tr('အားလုံး', 'All')),
        chip('အချိုရည်', tr('အချိုရည်', 'Drinks')),
        chip('မုန့်', tr('မုန့်', 'Snacks')),
        chip('ဆေးဝါး', tr('ဆေးဝါး', 'Medicines')),
      ]),
      const SizedBox(height: 16),
      Text(tr('ပစ္စည်းများ', 'Products'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      if (items.isEmpty)
        Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(tr('ပစ္စည်းမရှိသေးပါ', 'No products found')))),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: .78,
        ),
        itemBuilder: (_, i) => productCard(items[i]),
      ),
    ]);
  }

  Widget chip(String value, String label) => ChoiceChip(
        label: Text(label),
        selected: category == value,
        selectedColor: gold.withValues(alpha: 0.3),
        onSelected: (_) => setState(() => category = value),
      );

  Widget productCard(Product p) => Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: Center(child: Text(p.emoji, style: const TextStyle(fontSize: 52)))),
            Text(english ? p.en : p.mm,
                maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('${p.price} MMK', style: const TextStyle(color: navy, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: navy),
                onPressed: () => setState(() => cart[p.id] = (cart[p.id] ?? 0) + 1),
                child: Text(tr('ဈေးခြင်းထဲထည့်', 'Add to cart'), style: const TextStyle(fontSize: 12)),
              ),
            ),
          ]),
        ),
      );

  Widget cartPage(BuildContext ctx) {
    if (cart.isEmpty) return Center(child: Text(tr('ဈေးခြင်းထဲတွင် ပစ္စည်းမရှိသေးပါ။', 'Your cart is empty.')));
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    return ListView(padding: const EdgeInsets.all(16), children: [
      Text(tr('သင့်ဈေးခြင်း', 'Your Cart'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ...cart.entries.map((e) {
        final p = products.firstWhere((item) => item.id == e.key);
        return Card(
          child: ListTile(
            leading: Text(p.emoji, style: const TextStyle(fontSize: 28)),
            title: Text(english ? p.en : p.mm),
            subtitle: Text('${p.price} MMK × ${e.value}'),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(
                onPressed: () => setState(() {
                  if (e.value == 1) {
                    cart.remove(e.key);
                  } else {
                    cart[e.key] = e.value - 1;
                  }
                }),
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Text('${e.value}'),
              IconButton(
                onPressed: () => setState(() => cart[e.key] = e.value + 1),
                icon: const Icon(Icons.add_circle_outline),
              ),
            ]),
          ),
        );
      }),
      const SizedBox(height: 12),
      Text('${tr('စုစုပေါင်း', 'Total')}: $total MMK', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      FilledButton(
        onPressed: () {
          showDialog(
            context: ctx,
            builder: (dCtx) => AlertDialog(
              title: Text(tr('မှာယူသူ အချက်အလက်', 'Customer Details')),
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                TextField(controller: nameCtrl, decoration: InputDecoration(labelText: tr('အမည်', 'Your Name'))),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(labelText: tr('ဖုန်းနံပါတ်', 'Phone Number')),
                ),
              ]),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dCtx), child: Text(tr('ပယ်ဖျက်', 'Cancel'))),
                FilledButton(
                  onPressed: () async {
                    final orderItems = cart.entries.map((e) {
                      final p = products.firstWhere((item) => item.id == e.key);
                      return {
                        'product_id': p.id,
                        'name': p.mm,
                        'qty': e.value,
                        'price': p.price,
                        'customer': '${nameCtrl.text} (${phoneCtrl.text})'
                      };
                    }).toList();

                    await supabase.from('orders').insert({'items': orderItems, 'total_price': total});
                    setState(() => cart.clear());
                    if (dCtx.mounted) Navigator.pop(dCtx);
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(content: Text(tr('Order တင်ခြင်း အောင်မြင်ပါသည်!', 'Order placed successfully!'))),
                      );
                    }
                  },
                  child: Text(tr('အတည်ပြုမည်', 'Confirm Order')),
                ),
              ],
            ),
          );
        },
        child: Text(tr('Order တင်ရန်', 'Place order')),
      ),
    ]);
  }

  Widget adminProductsPage() => ListView(padding: const EdgeInsets.all(16), children: [
        Text(tr('ကုန်ပစ္စည်းများ စီမံခန့်ခွဲရန်', 'Manage Products'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Builder(
          builder: (ctx) => FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF7B1E1E)),
            onPressed: () => addProduct(ctx),
            icon: const Icon(Icons.add),
            label: Text(tr('ပစ္စည်းအသစ်ထည့်ရန်', 'Add New Product')),
          ),
        ),
        const SizedBox(height: 12),
        ...products.map((p) => Card(
              child: ListTile(
                leading: Text(p.emoji, style: const TextStyle(fontSize: 26)),
                title: Text(english ? p.en : p.mm),
                subtitle: Text('${p.price} MMK • ${p.category}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () async {
                    await supabase.from('products').delete().eq('id', p.id);
                    fetchAllData();
                  },
                ),
              ),
            )),
      ]);

  Widget adminOrdersPage() => ListView(padding: const EdgeInsets.all(16), children: [
        Text(tr('ဝယ်ယူထားသော အော်ဒါများ (${orders.length})', 'Customer Orders (${orders.length})'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (orders.isEmpty) Center(child: Text(tr('အော်ဒါ မရှိသေးပါ', 'No orders yet'))),
        ...orders.map((o) {
          final rawItems = o['items'];
          final items = rawItems is Iterable ? rawItems.toList() : [];
          final customerInfo = items.isNotEmpty ? (items.first['customer'] ?? '') : '';
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Order #${o['id']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('${o['total_price']} MMK',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                ]),
                if (customerInfo.toString().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('👤 $customerInfo', style: const TextStyle(fontWeight: FontWeight.w500)),
                  ),
                const Divider(),
                ...items.map((item) => Text('• ${item['name']} × ${item['qty']} (${item['price']} MMK)')),
              ]),
            ),
          );
        }),
      ]);

  void addProduct(BuildContext parentContext) {
    final name = TextEditingController(), price = TextEditingController();
    String cat = 'မုန့်';
    showDialog(
      context: parentContext,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, refresh) => AlertDialog(
          title: Text(tr('ပစ္စည်းအသစ်', 'New product')),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: name, decoration: InputDecoration(labelText: tr('ပစ္စည်းအမည်', 'Product name'))),
            TextField(
              controller: price,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: tr('ဈေးနှုန်း (MMK)', 'Price (MMK)')),
            ),
            DropdownButtonFormField<String>(
              initialValue: cat,
              decoration: InputDecoration(labelText: tr('အမျိုးအစား', 'Category')),
              items: const [
                DropdownMenuItem(value: 'အချိုရည်', child: Text('အချိုရည် / Drinks')),
                DropdownMenuItem(value: 'မုန့်', child: Text('မုန့် / Snacks')),
                DropdownMenuItem(value: 'ဆေးဝါး', child: Text('ဆေးဝါး / Medicines')),
              ],
              onChanged: (v) => refresh(() => cat = v ?? 'မုန့်'),
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(tr('ပယ်ဖျက်', 'Cancel'))),
            FilledButton(
              onPressed: () async {
                final n = name.text.trim(), value = int.tryParse(price.text.trim());
                if (n.isEmpty || value == null || value <= 0) return;

                await supabase.from('products').insert({
                  'mm': n,
                  'en': n,
                  'category': cat,
                  'price': value,
                  'emoji': cat == 'အချိုရည်' ? '🥤' : cat == 'ဆေးဝါး' ? '🩹' : '🍪',
                });

                if (ctx.mounted) Navigator.pop(ctx);
                fetchAllData();
              },
              child: Text(tr('သိမ်းမည်', 'Save')),
            ),
          ],
        ),
      ),
    );
  }
}
