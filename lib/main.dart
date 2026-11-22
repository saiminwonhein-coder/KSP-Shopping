import 'package:flutter/material.dart';

void main() => runApp(const KspApp());

const navy = Color(0xFF102A43);
const gold = Color(0xFFD4AF37);

class Product {
  Product(this.mm, this.en, this.category, this.price, this.emoji);
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
  int page = 0;
  String category = 'အားလုံး';
  final Map<Product, int> cart = {};
  final List<Product> products = [
    Product('ထိုင်းနို့လက်ဖက်ရည်', 'Thai Milk Tea', 'အချိုရည်', 2500, '🧋'),
    Product('လိမ္မော်အချိုရည်', 'Orange Drink', 'အချိုရည်', 1800, '🧃'),
    Product('အာလူးကြော်', 'Potato Chips', 'မုန့်', 1500, '🥔'),
    Product('ချောကလက်ဘီစကစ်', 'Chocolate Biscuits', 'မုန့်', 2200, '🍪'),
    Product('ကျန်းမာရေးသုံးပစ္စည်း', 'Healthcare Item', 'ဆေးဝါး', 3500, '🩹'),
  ];
  String tr(String mm, String en) => english ? en : mm;
  int get count => cart.values.fold(0, (a, b) => a + b);
  int get total => cart.entries.fold(0, (a, e) => a + e.key.price * e.value);

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'KSP Shopping',
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: navy),
      scaffoldBackgroundColor: const Color(0xFFF5F7FA), useMaterial3: true,
      appBarTheme: const AppBarTheme(backgroundColor: navy, foregroundColor: Colors.white)),
    home: Scaffold(
      appBar: AppBar(title: const Text('KSP SHOPPING', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton(onPressed: () => setState(() => english = !english),
            child: Text(english ? 'မြန်မာ' : 'EN', style: const TextStyle(color: Colors.white))),
          IconButton(onPressed: () => setState(() => page = 1),
            icon: Badge(isLabelVisible: count > 0, label: Text('$count'),
              child: const Icon(Icons.shopping_cart_outlined))),
        ]),
      body: IndexedStack(index: page, children: [shop(), cartPage(), adminPage()]),
      bottomNavigationBar: NavigationBar(selectedIndex: page,
        onDestinationSelected: (v) => setState(() => page = v),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.storefront), label: tr('ပင်မ', 'Shop')),
          NavigationDestination(icon: const Icon(Icons.shopping_basket), label: tr('ဈေးခြင်း', 'Cart')),
          NavigationDestination(icon: const Icon(Icons.admin_panel_settings), label: tr('စီမံရန်', 'Admin')),
        ]),
    ),
  );

  Widget shop() {
    final items = products.where((p) => category == 'အားလုံး' || p.category == category).toList();
    return ListView(padding: const EdgeInsets.all(16), children: [
      Container(padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(gradient: const LinearGradient(colors: [navy, Color(0xFF245477)]),
          borderRadius: BorderRadius.circular(18)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(tr('ထိုင်းနိုင်ငံထုတ် ကုန်ပစ္စည်းများ', 'Products from Thailand'),
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(tr('အချိုရည် • မုန့် • ကျန်းမာရေးသုံးပစ္စည်း', 'Drinks • Snacks • Healthcare'),
            style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 12),
          const Text('KSP SHOPPING', style: TextStyle(color: gold, letterSpacing: 2)),
        ])),
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
      GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: .78),
        itemBuilder: (_, i) => productCard(items[i])),
      const SizedBox(height: 8),
      Text(tr('မှတ်ချက် - ဤပစ္စည်းများသည် နမူနာစာရင်းများဖြစ်သည်။', 'Note: These are sample products.'),
        style: const TextStyle(color: Colors.black54, fontSize: 12)),
    ]);
  }

  Widget chip(String value, String label) => ChoiceChip(label: Text(label),
    selected: category == value, selectedColor: gold.withOpacity(.3),
    onSelected: (_) => setState(() => category = value));

  Widget productCard(Product p) => Card(clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(padding: const EdgeInsets.all(12), child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Center(child: Text(p.emoji, style: const TextStyle(fontSize: 52)))),
        Text(english ? p.en : p.mm, maxLines: 2, overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('${p.price} MMK', style: const TextStyle(color: navy, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        SizedBox(width: double.infinity, child: FilledButton(
          style: FilledButton.styleFrom(backgroundColor: navy),
          onPressed: () => setState(() => cart[p] = (cart[p] ?? 0) + 1),
          child: Text(tr('ဈေးခြင်းထဲထည့်', 'Add to cart'), style: const TextStyle(fontSize: 12)))),
      ])));

  Widget cartPage() {
    if (cart.isEmpty) return Center(child: Text(tr('ဈေးခြင်းထဲတွင် ပစ္စည်းမရှိသေးပါ။', 'Your cart is empty.')));
    return ListView(padding: const EdgeInsets.all(16), children: [
      Text(tr('သင့်ဈေးခြင်း', 'Your Cart'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ...cart.entries.map((e) => Card(child: ListTile(
        leading: Text(e.key.emoji, style: const TextStyle(fontSize: 28)),
        title: Text(english ? e.key.en : e.key.mm),
        subtitle: Text('${e.key.price} MMK × ${e.value}'),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(onPressed: () => setState(() { if (e.value == 1) { cart.remove(e.key); } else { cart[e.key] = e.value - 1; } }),
            icon: const Icon(Icons.remove_circle_outline)),
          Text('${e.value}'),
          IconButton(onPressed: () => setState(() => cart[e.key] = e.value + 1),
            icon: const Icon(Icons.add_circle_outline)),
        ])))),
      const SizedBox(height: 12),
      Text('${tr('စုစုပေါင်း', 'Total')}: $total MMK',
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      FilledButton(onPressed: () => showDialog(context: context, builder: (_) => AlertDialog(
        title: Text(tr('Order စမ်းသပ်မှု', 'Order demo')),
        content: Text(tr('ဤ Demo တွင် Order ကို Online သို့ မပို့သေးပါ။ Backend ချိတ်ဆက်ရန် လိုအပ်ပါသည်။',
          'Orders are not submitted online in this demo. A backend is required.')),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      )), child: Text(tr('Order တင်ရန်', 'Place order'))),
    ]);
  }

  Widget adminPage() => ListView(padding: const EdgeInsets.all(16), children: [
    Text(tr('စီမံခန့်ခွဲမှု (နမူနာ)', 'Admin (Demo)'),
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    const SizedBox(height: 8),
    Text(tr('ပစ္စည်းများကို ထည့်/ဖျက် စမ်းသပ်နိုင်သည်။ App ပိတ်လျှင် ပြောင်းလဲမှုများ ပျောက်သွားမည်။',
      'Add or remove sample products. Changes are temporary and reset when the app closes.')),
    const SizedBox(height: 12),
    FilledButton.icon(onPressed: addProduct, icon: const Icon(Icons.add),
      label: Text(tr('ပစ္စည်းအသစ်ထည့်ရန်', 'Add product'))),
    ...products.map((p) => Card(child: ListTile(
      leading: Text(p.emoji, style: const TextStyle(fontSize: 26)),
      title: Text(english ? p.en : p.mm), subtitle: Text('${p.price} MMK • ${p.category}'),
      trailing: IconButton(icon: const Icon(Icons.delete_outline),
        onPressed: () => setState(() => products.remove(p)))))),
  ]);

  void addProduct() {
    final name = TextEditingController(), price = TextEditingController();
    String cat = 'မုန့်';
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, refresh) =>
      AlertDialog(title: Text(tr('ပစ္စည်းအသစ်', 'New product')),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: name, decoration: InputDecoration(labelText: tr('ပစ္စည်းအမည်', 'Product name'))),
          TextField(controller: price, keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: tr('ဈေးနှုန်း (MMK)', 'Price (MMK)'))),
          DropdownButtonFormField<String>(value: cat, decoration: InputDecoration(labelText: tr('အမျိုးအစား', 'Category')),
            items: const [
              DropdownMenuItem(value: 'အချိုရည်', child: Text('အချိုရည် / Drinks')),
              DropdownMenuItem(value: 'မုန့်', child: Text('မုန့် / Snacks')),
              DropdownMenuItem(value: 'ဆေးဝါး', child: Text('ဆေးဝါး / Medicines')),
            ], onChanged: (v) => refresh(() => cat = v ?? 'မုန့်')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(tr('ပယ်ဖျက်', 'Cancel'))),
          FilledButton(onPressed: () {
            final n = name.text.trim(), value = int.tryParse(price.text.trim());
            if (n.isEmpty || value == null || value <= 0) return;
            setState(() => products.add(Product(n, n, cat, value, cat == 'အချိုရည်' ? '🥤' : cat == 'ဆေးဝါး' ? '🩹' : '🍪')));
            Navigator.pop(ctx);
          }, child: Text(tr('သိမ်းမည်', 'Save'))),
        ])));
  }
}
