// نماذج البيانات لتطبيق محاسبك

class UserProfile {
  String ownerName;
  String storeName;
  String phone;
  String businessType;
  String province;
  String district;

  UserProfile({
    required this.ownerName,
    required this.storeName,
    required this.phone,
    required this.businessType,
    required this.province,
    required this.district,
  });
}

class Product {
  String id;
  String name;
  String category;
  double costPrice;
  double sellPrice;
  double qtyExist;
  double qtySold;
  double minQty;
  String? imageUrl;
  bool isComplete;
  bool isTemporary;

  Product({
    required this.id,
    required this.name,
    required this.category,
    this.costPrice = 0,
    required this.sellPrice,
    this.qtyExist = 0,
    this.qtySold = 0,
    this.minQty = 0,
    this.imageUrl,
    this.isComplete = true,
    this.isTemporary = false,
  });

  double get totalCostValue => costPrice * qtyExist;
  double get totalSellValue => sellPrice * qtyExist;
  double get profit => (sellPrice - costPrice) * qtySold;
}

class InvoiceItem {
  Product product;
  double qty;

  InvoiceItem({required this.product, this.qty = 1});

  double get total => product.sellPrice * qty;
}

class Invoice {
  String id;
  String? title;
  String? customerName;
  DateTime date;
  List<InvoiceItem> items;
  String paymentMethod;
  double paidAmount;
  String? note;
  bool isDebt;

  Invoice({
    required this.id,
    this.title,
    this.customerName,
    required this.date,
    required this.items,
    this.paymentMethod = 'cash',
    required this.paidAmount,
    this.note,
    this.isDebt = false,
  });

  double get totalAmount => items.fold(0, (sum, item) => sum + item.total);
  double get remaining => totalAmount - paidAmount;
}

class PurchaseInvoice {
  String id;
  String? supplierName;
  DateTime date;
  List<PurchaseItem> items;
  bool hasFormalInvoice;

  PurchaseInvoice({
    required this.id,
    this.supplierName,
    required this.date,
    required this.items,
    this.hasFormalInvoice = true,
  });

  double get totalCost => items.fold(0, (sum, i) => sum + i.totalCost);
}

class PurchaseItem {
  String productName;
  String category;
  double qty;
  double costPrice;
  double sellPrice;

  PurchaseItem({
    required this.productName,
    required this.category,
    required this.qty,
    required this.costPrice,
    required this.sellPrice,
  });

  double get totalCost => costPrice * qty;
}

class Expense {
  String id;
  String category;
  double amount;
  DateTime date;
  String? note;

  Expense({
    required this.id,
    required this.category,
    required this.amount,
    required this.date,
    this.note,
  });
}

class Contact {
  String id;
  String name;
  String? phone;
  String? address;
  bool isSupplier;

  Contact({
    required this.id,
    required this.name,
    this.phone,
    this.address,
    this.isSupplier = false,
  });
}

class Debt {
  String id;
  String contactName;
  bool isSupplier;
  double amount;
  DateTime date;
  String? invoiceId;
  bool isPaid;

  Debt({
    required this.id,
    required this.contactName,
    required this.isSupplier,
    required this.amount,
    required this.date,
    this.invoiceId,
    this.isPaid = false,
  });
}
