import 'package:flutter/foundation.dart';
import 'app_models.dart';

class AppState extends ChangeNotifier {
  UserProfile? userProfile;
  List<Product> products = [];
  List<Invoice> invoices = [];
  List<PurchaseInvoice> purchaseInvoices = [];
  List<Expense> expenses = [];
  List<Contact> contacts = [];

  // الأصناف في الفاتورة الحالية
  List<InvoiceItem> currentCart = [];

  bool get isLoggedIn => userProfile != null;

  // تسجيل الدخول
  void login(UserProfile profile) {
    userProfile = profile;
    _loadSampleData();
    notifyListeners();
  }

  void logout() {
    userProfile = null;
    currentCart.clear();
    notifyListeners();
  }

  // إدارة السلة
  void addToCart(Product product) {
    final existing = currentCart.indexWhere((i) => i.product.id == product.id);
    if (existing >= 0) {
      currentCart[existing].qty++;
    } else {
      currentCart.add(InvoiceItem(product: product));
    }
    notifyListeners();
  }

  void updateCartQty(String productId, double delta) {
    final idx = currentCart.indexWhere((i) => i.product.id == productId);
    if (idx < 0) return;
    currentCart[idx].qty += delta;
    if (currentCart[idx].qty <= 0) {
      currentCart.removeAt(idx);
    }
    notifyListeners();
  }

  void clearCart() {
    currentCart.clear();
    notifyListeners();
  }

  double get cartTotal => currentCart.fold(0, (s, i) => s + i.total);

  // حفظ فاتورة
  void saveInvoice(Invoice invoice) {
    invoices.add(invoice);
    // تحديث المخزون
    for (var item in invoice.items) {
      final idx = products.indexWhere((p) => p.id == item.product.id);
      if (idx >= 0) {
        products[idx].qtySold += item.qty;
        products[idx].qtyExist -= item.qty;
      }
    }
    clearCart();
    notifyListeners();
  }

  // إضافة منتج
  void addProduct(Product product) {
    products.add(product);
    notifyListeners();
  }

  void updateProduct(Product product) {
    final idx = products.indexWhere((p) => p.id == product.id);
    if (idx >= 0) {
      products[idx] = product;
      notifyListeners();
    }
  }

  void deleteProduct(String id) {
    products.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  // إضافة مصروف
  void addExpense(Expense expense) {
    expenses.add(expense);
    notifyListeners();
  }

  void deleteExpense(String id) {
    expenses.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  // إضافة عميل/مورد
  void addContact(Contact contact) {
    contacts.add(contact);
    notifyListeners();
  }

  void updateContact(Contact contact) {
    final idx = contacts.indexWhere((c) => c.id == contact.id);
    if (idx >= 0) {
      contacts[idx] = contact;
      notifyListeners();
    }
  }

  void deleteContact(String id) {
    contacts.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  // الأصناف غير المكتملة
  List<Product> get incompleteProducts =>
      products.where((p) => p.costPrice == 0 || p.qtyExist == 0).toList();

  // الأصناف بدون فاتورة مشتريات
  List<Product> get productsWithoutPurchaseInvoice =>
      products.where((p) => !p.isComplete && !p.isTemporary).toList();

  // ديون العملاء
  List<Invoice> get customerDebts =>
      invoices.where((inv) => inv.isDebt && inv.remaining > 0).toList();

  // تحميل بيانات تجريبية
  void _loadSampleData() {
    products = [
      Product(
        id: '1',
        name: 'مياه معدنية',
        category: 'المشروبات',
        costPrice: 1.5,
        sellPrice: 2.0,
        qtyExist: 100,
        qtySold: 30,
      ),
      Product(
        id: '2',
        name: 'عصير برتقال',
        category: 'المشروبات',
        costPrice: 3.0,
        sellPrice: 4.5,
        qtyExist: 50,
        qtySold: 15,
      ),
      Product(
        id: '3',
        name: 'خبز توست',
        category: 'المخبوزات',
        costPrice: 2.5,
        sellPrice: 3.5,
        qtyExist: 30,
        qtySold: 20,
      ),
      Product(
        id: '4',
        name: 'أرز بسمتي',
        category: 'الحبوب والبقوليات',
        costPrice: 8.0,
        sellPrice: 12.0,
        qtyExist: 80,
        qtySold: 10,
      ),
      Product(
        id: '5',
        name: 'زيت زيتون',
        category: 'الزيوت',
        costPrice: 15.0,
        sellPrice: 22.0,
        qtyExist: 25,
        qtySold: 5,
      ),
    ];

    contacts = [
      Contact(id: 'c1', name: 'أحمد علي', phone: '771234567', isSupplier: false),
      Contact(id: 'c2', name: 'محمد سالم', phone: '775678901', isSupplier: false),
      Contact(id: 's1', name: 'شركة الأمانة للتوزيع', phone: '773456789', isSupplier: true),
      Contact(id: 's2', name: 'مورد الحبوب', phone: '776543210', isSupplier: true),
    ];

    expenses = [
      Expense(
        id: 'e1',
        category: 'إيجار',
        amount: 500,
        date: DateTime.now().subtract(const Duration(days: 5)),
        note: 'إيجار شهر سبتمبر',
      ),
      Expense(
        id: 'e2',
        category: 'كهرباء',
        amount: 120,
        date: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ];
  }

  // الأصناف حسب القسم
  Map<String, List<Product>> get productsByCategory {
    final map = <String, List<Product>>{};
    for (var p in products) {
      map.putIfAbsent(p.category, () => []).add(p);
    }
    return map;
  }

  double get totalInventoryCost =>
      products.fold(0, (s, p) => s + p.totalCostValue);

  double get totalInventorySell =>
      products.fold(0, (s, p) => s + p.totalSellValue);

  List<String> get categories =>
      products.map((p) => p.category).toSet().toList();
}
