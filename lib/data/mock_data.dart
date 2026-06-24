import 'package:flutter/material.dart';
import 'package:saathi/data/models/banner.dart';
import 'package:saathi/data/models/category.dart';
import 'package:saathi/data/models/ledger_entry.dart';
import 'package:saathi/data/models/product.dart';
import 'package:saathi/util/app_colors.dart';

/// Seed catalog for the demo. Structured exactly like the future API response
/// so swapping MockRepository → ApiRepository is a drop-in change.
class MockData {
  MockData._();

  static String _img(String keyword) =>
      'https://loremflickr.com/400/400/$keyword';

  static const List<CategoryModel> categories = [
    CategoryModel(id: 'c1', name: 'Groceries & Staples', icon: Icons.rice_bowl_outlined, color: Color(0xFF1C6DD0), itemCount: 8),
    CategoryModel(id: 'c2', name: 'Beverages', icon: Icons.local_drink_outlined, color: Color(0xFFE8590C), itemCount: 6),
    CategoryModel(id: 'c3', name: 'Snacks & Namkeen', icon: Icons.cookie_outlined, color: Color(0xFFAB7B00), itemCount: 6),
    CategoryModel(id: 'c4', name: 'Personal Care', icon: Icons.soap_outlined, color: Color(0xFF7048E8), itemCount: 5),
    CategoryModel(id: 'c5', name: 'Home Care', icon: Icons.cleaning_services_outlined, color: Color(0xFF0CA678), itemCount: 5),
    CategoryModel(id: 'c6', name: 'Dairy & Bakery', icon: Icons.bakery_dining_outlined, color: Color(0xFFD6336C), itemCount: 4),
    CategoryModel(id: 'c7', name: 'Packaged Food', icon: Icons.fastfood_outlined, color: Color(0xFF1098AD), itemCount: 4),
    CategoryModel(id: 'c8', name: 'Stationery', icon: Icons.edit_note_outlined, color: Color(0xFF5C7CFA), itemCount: 3),
  ];

  static final List<Product> products = [
    // ---- Groceries & Staples ----
    Product(
      id: 'p1', name: 'India Gate Basmati Rice', brand: 'India Gate', categoryId: 'c1',
      imageUrl: _img('rice'), unit: '25 kg bag', mrp: 2200, moq: 2, stock: 140, isFeatured: true, isPopular: true,
      description: 'Premium aged basmati rice. Long grain, low broken percentage. Ideal for hotels and bulk resale.',
      slabs: const [PriceSlab(minQty: 2, pricePerUnit: 1850), PriceSlab(minQty: 5, pricePerUnit: 1790), PriceSlab(minQty: 10, pricePerUnit: 1720)],
    ),
    Product(
      id: 'p2', name: 'Aashirvaad Atta', brand: 'Aashirvaad', categoryId: 'c1',
      imageUrl: _img('flour'), unit: '10 kg bag', mrp: 520, moq: 5, stock: 300, isPopular: true,
      description: 'Whole wheat atta, 100% MP wheat. Fast-moving SKU.',
      slabs: const [PriceSlab(minQty: 5, pricePerUnit: 430), PriceSlab(minQty: 20, pricePerUnit: 412), PriceSlab(minQty: 50, pricePerUnit: 398)],
    ),
    Product(
      id: 'p3', name: 'Fortune Sunflower Oil', brand: 'Fortune', categoryId: 'c1',
      imageUrl: _img('oil%2Cbottle'), unit: '15 L tin', mrp: 1850, moq: 2, stock: 90, isFeatured: true,
      description: 'Refined sunflower oil, jerrycan tin pack for kirana resale.',
      slabs: const [PriceSlab(minQty: 2, pricePerUnit: 1620), PriceSlab(minQty: 6, pricePerUnit: 1580), PriceSlab(minQty: 12, pricePerUnit: 1540)],
    ),
    Product(
      id: 'p4', name: 'Tata Salt', brand: 'Tata', categoryId: 'c1',
      imageUrl: _img('salt'), unit: 'Carton (24 x 1kg)', mrp: 672, moq: 5, stock: 200, isPopular: true,
      description: 'Iodised vacuum salt. Carton of 24 packs.',
      slabs: const [PriceSlab(minQty: 5, pricePerUnit: 552), PriceSlab(minQty: 15, pricePerUnit: 540), PriceSlab(minQty: 40, pricePerUnit: 528)],
    ),
    Product(
      id: 'p5', name: 'Toor Dal (Arhar)', brand: 'Dairy Demo', categoryId: 'c1',
      imageUrl: _img('lentils'), unit: '30 kg bag', mrp: 4500, moq: 1, stock: 60,
      description: 'Premium polished toor dal, sortex clean.',
      slabs: const [PriceSlab(minQty: 1, pricePerUnit: 3900), PriceSlab(minQty: 4, pricePerUnit: 3780), PriceSlab(minQty: 10, pricePerUnit: 3690)],
    ),
    Product(
      id: 'p6', name: 'Sugar (Refined)', brand: 'Dairy Demo', categoryId: 'c1',
      imageUrl: _img('sugar'), unit: '50 kg bag', mrp: 2300, moq: 1, stock: 80,
      description: 'M-30 grade refined sulphurless sugar.',
      slabs: const [PriceSlab(minQty: 1, pricePerUnit: 2050), PriceSlab(minQty: 5, pricePerUnit: 2010), PriceSlab(minQty: 20, pricePerUnit: 1975)],
    ),

    // ---- Beverages ----
    Product(
      id: 'p7', name: 'Tata Tea Premium', brand: 'Tata Tea', categoryId: 'c2',
      imageUrl: _img('tea'), unit: 'Carton (10 x 1kg)', mrp: 5400, moq: 1, stock: 70, isFeatured: true, isPopular: true,
      description: 'Strong assam blend. High-rotation tea SKU.',
      slabs: const [PriceSlab(minQty: 1, pricePerUnit: 4750), PriceSlab(minQty: 4, pricePerUnit: 4640), PriceSlab(minQty: 10, pricePerUnit: 4520)],
    ),
    Product(
      id: 'p8', name: 'Bru Instant Coffee', brand: 'Bru', categoryId: 'c2',
      imageUrl: _img('coffee'), unit: 'Box (24 x 50g)', mrp: 3120, moq: 1, stock: 50,
      description: 'Instant coffee sachets, retail-ready box.',
      slabs: const [PriceSlab(minQty: 1, pricePerUnit: 2760), PriceSlab(minQty: 5, pricePerUnit: 2700)],
    ),
    Product(
      id: 'p9', name: 'Coca-Cola 750ml', brand: 'Coca-Cola', categoryId: 'c2',
      imageUrl: _img('cola'), unit: 'Crate (24 bottles)', mrp: 960, moq: 3, stock: 120, isPopular: true,
      description: 'PET bottle crate. Returnable not required.',
      slabs: const [PriceSlab(minQty: 3, pricePerUnit: 840), PriceSlab(minQty: 10, pricePerUnit: 816), PriceSlab(minQty: 25, pricePerUnit: 792)],
    ),
    Product(
      id: 'p10', name: 'Real Fruit Juice', brand: 'Real', categoryId: 'c2',
      imageUrl: _img('juice'), unit: 'Carton (12 x 1L)', mrp: 1380, moq: 2, stock: 85,
      description: 'Mixed fruit tetra packs, assorted flavours.',
      slabs: const [PriceSlab(minQty: 2, pricePerUnit: 1200), PriceSlab(minQty: 8, pricePerUnit: 1170)],
    ),
    Product(
      id: 'p11', name: 'Bisleri Water 1L', brand: 'Bisleri', categoryId: 'c2',
      imageUrl: _img('water%2Cbottle'), unit: 'Pack (12 bottles)', mrp: 240, moq: 10, stock: 400, isPopular: true,
      description: 'Packaged drinking water, shrink pack.',
      slabs: const [PriceSlab(minQty: 10, pricePerUnit: 180), PriceSlab(minQty: 30, pricePerUnit: 174), PriceSlab(minQty: 60, pricePerUnit: 168)],
    ),

    // ---- Snacks & Namkeen ----
    Product(
      id: 'p12', name: "Lay's Classic Salted", brand: "Lay's", categoryId: 'c3',
      imageUrl: _img('chips'), unit: 'Box (40 packs)', mrp: 800, moq: 3, stock: 150, isPopular: true,
      description: 'Rs.20 MRP packs, retail-ready ladi box.',
      slabs: const [PriceSlab(minQty: 3, pricePerUnit: 680), PriceSlab(minQty: 12, pricePerUnit: 664), PriceSlab(minQty: 30, pricePerUnit: 648)],
    ),
    Product(
      id: 'p13', name: 'Haldiram Aloo Bhujia', brand: 'Haldiram', categoryId: 'c3',
      imageUrl: _img('namkeen%2Csnack'), unit: 'Carton (24 x 200g)', mrp: 1200, moq: 2, stock: 100, isFeatured: true,
      description: 'Best-selling namkeen. Long shelf life.',
      slabs: const [PriceSlab(minQty: 2, pricePerUnit: 1020), PriceSlab(minQty: 8, pricePerUnit: 996)],
    ),
    Product(
      id: 'p14', name: 'Parle-G Biscuits', brand: 'Parle', categoryId: 'c3',
      imageUrl: _img('biscuit'), unit: 'Carton (48 packs)', mrp: 480, moq: 5, stock: 260, isPopular: true,
      description: 'Glucose biscuit, fastest-moving impulse SKU.',
      slabs: const [PriceSlab(minQty: 5, pricePerUnit: 408), PriceSlab(minQty: 20, pricePerUnit: 398), PriceSlab(minQty: 50, pricePerUnit: 388)],
    ),
    Product(
      id: 'p15', name: 'Britannia Good Day', brand: 'Britannia', categoryId: 'c3',
      imageUrl: _img('cookie'), unit: 'Carton (36 packs)', mrp: 1080, moq: 3, stock: 90,
      description: 'Cashew cookies, premium impulse buy.',
      slabs: const [PriceSlab(minQty: 3, pricePerUnit: 918), PriceSlab(minQty: 12, pricePerUnit: 896)],
    ),

    // ---- Personal Care ----
    Product(
      id: 'p16', name: 'Colgate MaxFresh', brand: 'Colgate', categoryId: 'c4',
      imageUrl: _img('toothpaste'), unit: 'Box (24 x 150g)', mrp: 2400, moq: 2, stock: 70, isFeatured: true,
      description: 'Toothpaste 150g, anti-cavity formula.',
      slabs: const [PriceSlab(minQty: 2, pricePerUnit: 2040), PriceSlab(minQty: 8, pricePerUnit: 1992)],
    ),
    Product(
      id: 'p17', name: 'Lifebuoy Soap', brand: 'Lifebuoy', categoryId: 'c4',
      imageUrl: _img('soap'), unit: 'Box (48 bars)', mrp: 1440, moq: 3, stock: 160, isPopular: true,
      description: 'Germ-protection bathing bar, 100g.',
      slabs: const [PriceSlab(minQty: 3, pricePerUnit: 1224), PriceSlab(minQty: 12, pricePerUnit: 1200)],
    ),
    Product(
      id: 'p18', name: 'Clinic Plus Shampoo', brand: 'Clinic Plus', categoryId: 'c4',
      imageUrl: _img('shampoo'), unit: 'Box (24 x 175ml)', mrp: 2160, moq: 2, stock: 60,
      description: 'Strong & long shampoo bottles.',
      slabs: const [PriceSlab(minQty: 2, pricePerUnit: 1836), PriceSlab(minQty: 8, pricePerUnit: 1800)],
    ),
    Product(
      id: 'p19', name: 'Gillette Razor Pack', brand: 'Gillette', categoryId: 'c4',
      imageUrl: _img('razor'), unit: 'Box (20 packs)', mrp: 1000, moq: 2, stock: 40,
      description: 'Disposable twin-blade razors.',
      slabs: const [PriceSlab(minQty: 2, pricePerUnit: 850), PriceSlab(minQty: 6, pricePerUnit: 830)],
    ),

    // ---- Home Care ----
    Product(
      id: 'p20', name: 'Surf Excel Detergent', brand: 'Surf Excel', categoryId: 'c5',
      imageUrl: _img('detergent'), unit: '5 kg bag', mrp: 650, moq: 4, stock: 110, isFeatured: true, isPopular: true,
      description: 'Easy-wash detergent powder, bulk bag.',
      slabs: const [PriceSlab(minQty: 4, pricePerUnit: 540), PriceSlab(minQty: 16, pricePerUnit: 528), PriceSlab(minQty: 40, pricePerUnit: 516)],
    ),
    Product(
      id: 'p21', name: 'Vim Dishwash Bar', brand: 'Vim', categoryId: 'c5',
      imageUrl: _img('dishwash'), unit: 'Box (30 bars)', mrp: 900, moq: 3, stock: 130,
      description: 'Lemon dishwash bar, 300g.',
      slabs: const [PriceSlab(minQty: 3, pricePerUnit: 765), PriceSlab(minQty: 12, pricePerUnit: 750)],
    ),
    Product(
      id: 'p22', name: 'Harpic Toilet Cleaner', brand: 'Harpic', categoryId: 'c5',
      imageUrl: _img('cleaner%2Cbottle'), unit: 'Box (12 x 1L)', mrp: 1440, moq: 2, stock: 75,
      description: 'Power-plus toilet cleaner.',
      slabs: const [PriceSlab(minQty: 2, pricePerUnit: 1224), PriceSlab(minQty: 8, pricePerUnit: 1200)],
    ),

    // ---- Dairy & Bakery ----
    Product(
      id: 'p23', name: 'Amul Butter', brand: 'Amul', categoryId: 'c6',
      imageUrl: _img('butter'), unit: 'Box (40 x 100g)', mrp: 2400, moq: 1, stock: 50, isPopular: true,
      description: 'Pasteurised table butter, keep refrigerated.',
      slabs: const [PriceSlab(minQty: 1, pricePerUnit: 2160), PriceSlab(minQty: 5, pricePerUnit: 2120)],
    ),
    Product(
      id: 'p24', name: 'Amul Milk Powder', brand: 'Amul', categoryId: 'c6',
      imageUrl: _img('milk'), unit: 'Box (10 x 500g)', mrp: 2750, moq: 1, stock: 45, isFeatured: true,
      description: 'Full-cream milk powder pouches.',
      slabs: const [PriceSlab(minQty: 1, pricePerUnit: 2475), PriceSlab(minQty: 4, pricePerUnit: 2420)],
    ),
    Product(
      id: 'p25', name: 'Britannia Bread', brand: 'Britannia', categoryId: 'c6',
      imageUrl: _img('bread'), unit: 'Tray (20 loaves)', mrp: 800, moq: 2, stock: 60,
      description: 'Daily fresh sandwich bread.',
      slabs: const [PriceSlab(minQty: 2, pricePerUnit: 680), PriceSlab(minQty: 6, pricePerUnit: 660)],
    ),

    // ---- Packaged Food ----
    Product(
      id: 'p26', name: 'Maggi Noodles', brand: 'Maggi', categoryId: 'c7',
      imageUrl: _img('noodles'), unit: 'Carton (48 x 70g)', mrp: 672, moq: 4, stock: 220, isFeatured: true, isPopular: true,
      description: '2-minute masala noodles, top mover.',
      slabs: const [PriceSlab(minQty: 4, pricePerUnit: 564), PriceSlab(minQty: 16, pricePerUnit: 552), PriceSlab(minQty: 40, pricePerUnit: 540)],
    ),
    Product(
      id: 'p27', name: 'Kissan Mixed Jam', brand: 'Kissan', categoryId: 'c7',
      imageUrl: _img('jam'), unit: 'Box (12 x 500g)', mrp: 1560, moq: 2, stock: 55,
      description: 'Mixed fruit jam glass jars.',
      slabs: const [PriceSlab(minQty: 2, pricePerUnit: 1326), PriceSlab(minQty: 8, pricePerUnit: 1300)],
    ),
    Product(
      id: 'p28', name: 'MTR Ready Mix', brand: 'MTR', categoryId: 'c7',
      imageUrl: _img('packet%2Cfood'), unit: 'Box (30 packs)', mrp: 1500, moq: 2, stock: 40,
      description: 'Breakfast ready-mix assorted.',
      slabs: const [PriceSlab(minQty: 2, pricePerUnit: 1275), PriceSlab(minQty: 8, pricePerUnit: 1250)],
    ),

    // ---- Stationery ----
    Product(
      id: 'p29', name: 'Classmate Notebooks', brand: 'Classmate', categoryId: 'c8',
      imageUrl: _img('notebook'), unit: 'Bundle (60 books)', mrp: 3600, moq: 1, stock: 80, isPopular: true,
      description: '172-page long notebooks, single line.',
      slabs: const [PriceSlab(minQty: 1, pricePerUnit: 3060), PriceSlab(minQty: 5, pricePerUnit: 3000)],
    ),
    Product(
      id: 'p30', name: 'Cello Pens Box', brand: 'Cello', categoryId: 'c8',
      imageUrl: _img('pen'), unit: 'Box (50 pens)', mrp: 500, moq: 4, stock: 200,
      description: 'Blue gel pens, smooth flow.',
      slabs: const [PriceSlab(minQty: 4, pricePerUnit: 425), PriceSlab(minQty: 16, pricePerUnit: 415)],
    ),
  ];

  static const List<BannerModel> banners = [
    BannerModel(
      title: 'STOCK AVAILABLE',
      subtitle: 'All variants in stock — place demand now',
      tag: 'MEGA DEAL',
      image: 'assets/images/products/p3.jpg', // oil
      accent: Color(0xFFE2231A),
    ),
    BannerModel(
      title: 'FREE DELIVERY',
      subtitle: 'On every order above ₹5,000',
      tag: 'NO CHARGE',
      image: 'assets/images/products/p1.jpg', // rice
      accent: Color(0xFFE8590C),
    ),
    BannerModel(
      title: 'PAY LATER ON KHATA',
      subtitle: '15-day credit for trusted retailers',
      tag: 'CREDIT',
      image: 'assets/images/products/p24.jpg', // milk
      accent: Color(0xFF0CA678),
    ),
  ];

  static List<LedgerEntry> ledger(DateTime now) => [
        LedgerEntry(id: 'l1', date: now.subtract(const Duration(days: 2)), title: 'Order #SA10231 (Khata)', amount: 12480, isDebit: true),
        LedgerEntry(id: 'l2', date: now.subtract(const Duration(days: 5)), title: 'Payment received', amount: 10000, isDebit: false),
        LedgerEntry(id: 'l3', date: now.subtract(const Duration(days: 9)), title: 'Order #SA10198 (Khata)', amount: 8740, isDebit: true),
        LedgerEntry(id: 'l4', date: now.subtract(const Duration(days: 14)), title: 'Payment received', amount: 15000, isDebit: false),
        LedgerEntry(id: 'l5', date: now.subtract(const Duration(days: 20)), title: 'Order #SA10122 (Khata)', amount: 9320, isDebit: true),
      ];

  /// Product image placeholders use one consistent brand tint (not per-category
  /// colours) to keep the catalog looking cohesive and professional.
  static Color colorForCategory(String categoryId) => AppColors.primary;

  static IconData iconForCategory(String categoryId) {
    final match = categories.where((c) => c.id == categoryId);
    return match.isNotEmpty ? match.first.icon : Icons.inventory_2_outlined;
  }

  /// A representative real product photo used as each category's thumbnail.
  static const Map<String, String> _catThumb = {
    'c1': 'p1', 'c2': 'p9', 'c3': 'p12', 'c4': 'p16',
    'c5': 'p20', 'c6': 'p23', 'c7': 'p26', 'c8': 'p29',
  };

  static String categoryImage(String categoryId) =>
      'assets/images/products/${_catThumb[categoryId] ?? 'p1'}.jpg';
}
