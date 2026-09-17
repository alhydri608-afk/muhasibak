import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/app_state.dart';
import '../models/app_models.dart';
import '../widgets/common_widgets.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      backgroundColor: AppColors.appSurface,
      appBar: AppBar(
        backgroundColor: AppColors.cardDark,
        leading: IconButton(
          icon: const Icon(Icons.chevron_right, color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('المخزون والمنتجات'),
        actions: [
          IconButton(
            icon: Icon(
              _showSearch ? Icons.close : Icons.search,
              color: AppColors.textMain,
            ),
            onPressed: () => setState(() {
              _showSearch = !_showSearch;
              if (!_showSearch) {
                _searchQuery = '';
                _searchCtrl.clear();
              }
            }),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accentGreen,
          labelColor: AppColors.accentGreen,
          unselectedLabelColor: AppColors.textSub,
          labelStyle: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700),
          tabs: const [
            Tab(text: 'المخزون'),
            Tab(text: 'أكمل الإعداد'),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_showSearch)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
              child: SearchBar2(
                hint: 'بحث عن صنف أو قسم...',
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
            ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildInventoryTab(state),
                _buildSetupTab(state),
              ],
            ),
          ),
          _buildFooter(state),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProductDialog(context, state),
        backgroundColor: AppColors.accentGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildInventoryTab(AppState state) {
    final filtered = _getFiltered(state.productsByCategory);

    if (filtered.isEmpty) {
      return const EmptyState(
        message: 'لا توجد منتجات\nاضغط + لإضافة منتج جديد',
        icon: Icons.inventory_2_outlined,
      );
    }

    return ListView(
      padding: const EdgeInsets.all(12),
      children: filtered.entries.map((entry) {
        return AccordionSection(
          title: entry.key,
          badge: '${entry.value.length}',
          initiallyExpanded: true,
          children: entry.value
              .map((p) => _buildProductRow(p, state))
              .toList(),
        );
      }).toList(),
    );
  }

  Widget _buildSetupTab(AppState state) {
    final incomplete = state.incompleteProducts;

    if (incomplete.isEmpty) {
      return const EmptyState(
        message: 'جميع الأصناف مكتملة ✓',
        icon: Icons.check_circle_outline,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: incomplete.length,
      itemBuilder: (ctx, i) => _buildProductRow(incomplete[i], state),
    );
  }

  Widget _buildProductRow(Product product, AppState state) {
    final isLowStock =
        product.minQty > 0 && product.qtyExist <= product.minQty;

    return InkWell(
      onTap: () => _showProductDetails(context, product, state),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.borderColor, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          color: AppColors.textMain,
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      if (isLowStock) ...[
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.warning_amber,
                          color: AppColors.accentAmber,
                          size: 14,
                        ),
                      ],
                    ],
                  ),
                  Text(
                    'بيع: ${formatMoney(product.sellPrice)} | تكلفة: ${formatMoney(product.costPrice)}',
                    style: const TextStyle(
                      color: AppColors.textSub,
                      fontFamily: 'Cairo',
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            AppBadge(
              text: '${product.qtyExist.toInt()} وحدة',
              color: isLowStock
                  ? AppColors.accentAmber
                  : AppColors.accentGreen,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(AppState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.cardSurface,
        border: Border(top: BorderSide(color: AppColors.borderColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'إجمالي قيمة التكلفة',
                style: TextStyle(
                    color: AppColors.textSub,
                    fontSize: 11,
                    fontFamily: 'Cairo'),
              ),
              Text(
                formatMoney(state.totalInventoryCost),
                style: const TextStyle(
                  color: AppColors.textMain,
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'إجمالي قيمة البيع',
                style: TextStyle(
                    color: AppColors.textSub,
                    fontSize: 11,
                    fontFamily: 'Cairo'),
              ),
              Text(
                formatMoney(state.totalInventorySell),
                style: const TextStyle(
                  color: AppColors.accentBlue,
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Map<String, List<Product>> _getFiltered(Map<String, List<Product>> map) {
    if (_searchQuery.isEmpty) return map;
    final q = _searchQuery.toLowerCase();
    final result = <String, List<Product>>{};
    for (var entry in map.entries) {
      if (entry.key.toLowerCase().contains(q)) {
        result[entry.key] = entry.value;
      } else {
        final matched =
            entry.value.where((p) => p.name.toLowerCase().contains(q)).toList();
        if (matched.isNotEmpty) result[entry.key] = matched;
      }
    }
    return result;
  }

  void _showProductDetails(
      BuildContext context, Product product, AppState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ProductDetailSheet(product: product, state: state),
    );
  }

  void _showAddProductDialog(BuildContext context, AppState state) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => AddProductScreen(state: state)),
    );
  }
}

// شاشة إضافة صنف مؤقت
class AddProductScreen extends StatefulWidget {
  final AppState state;
  const AddProductScreen({super.key, required this.state});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _nameCtrl = TextEditingController();
  final _sellPriceCtrl = TextEditingController();
  final _costPriceCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _minQtyCtrl = TextEditingController();
  String _category = '';
  String _newCategory = '';
  bool _showNewCategory = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _sellPriceCtrl.dispose();
    _costPriceCtrl.dispose();
    _qtyCtrl.dispose();
    _minQtyCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_nameCtrl.text.trim().isEmpty ||
        _sellPriceCtrl.text.trim().isEmpty ||
        _category.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب تعبئة اسم الصنف والنوع وسعر البيع',
              style: TextStyle(fontFamily: 'Cairo')),
          backgroundColor: AppColors.accentRed,
        ),
      );
      return;
    }

    final cat = _showNewCategory ? _newCategory : _category;
    final product = Product(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameCtrl.text.trim(),
      category: cat,
      sellPrice: double.tryParse(_sellPriceCtrl.text) ?? 0,
      costPrice: double.tryParse(_costPriceCtrl.text) ?? 0,
      qtyExist: double.tryParse(_qtyCtrl.text) ?? 0,
      minQty: double.tryParse(_minQtyCtrl.text) ?? 0,
      isTemporary: true,
    );

    widget.state.addProduct(product);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.state.categories;

    return Scaffold(
      backgroundColor: AppColors.appSurface,
      appBar: AppBar(
        backgroundColor: AppColors.cardDark,
        leading: IconButton(
          icon: const Icon(Icons.chevron_right, color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('إضافة صنف'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.accentBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: AppColors.accentBlue.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline,
                      color: AppColors.accentBlue, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'يمكن حفظ الصنف بعد تعبئة اسم الصنف والنوع وسعر البيع فقط',
                      style: TextStyle(
                        color: AppColors.accentBlue,
                        fontFamily: 'Cairo',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: AppTextField(
                    label: 'اسم الصنف',
                    hint: 'اسم الصنف',
                    controller: _nameCtrl,
                    required: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 6),
                        child: Text(
                          'القسم / النوع *',
                          style: TextStyle(
                            color: AppColors.textSub,
                            fontSize: 13,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ),
                      DropdownButtonFormField<String>(
                        value: _category.isEmpty ? null : _category,
                        onChanged: (v) {
                          setState(() {
                            _category = v!;
                            _showNewCategory = v == '__new__';
                          });
                        },
                        dropdownColor: AppColors.cardSurface,
                        style: const TextStyle(
                            color: AppColors.textMain, fontFamily: 'Cairo'),
                        decoration: const InputDecoration(
                            hintText: 'اختر...'),
                        items: [
                          ...categories.map((c) => DropdownMenuItem(
                              value: c,
                              child: Text(c,
                                  style: const TextStyle(
                                      fontFamily: 'Cairo')))),
                          const DropdownMenuItem(
                            value: '__new__',
                            child: Text('+ قسم جديد',
                                style: TextStyle(
                                    fontFamily: 'Cairo',
                                    color: AppColors.accentGreen)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_showNewCategory) ...[
              const SizedBox(height: 12),
              AppTextField(
                label: 'اسم القسم الجديد',
                hint: 'مثال: صيانة، تسويق...',
                onChanged: (v) => _newCategory = v,
              ),
            ],
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'الكمية الموجودة',
                    hint: 'لم يحدد بعد',
                    controller: _qtyCtrl,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    label: 'الكمية المباعة',
                    hint: '0',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'سعر التكلفة',
                    hint: 'لم يحدد بعد',
                    controller: _costPriceCtrl,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    label: 'سعر البيع',
                    hint: '0.00',
                    controller: _sellPriceCtrl,
                    required: true,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            AppTextField(
              label: 'الحد الأدنى للكمية',
              hint: 'مثال: 5',
              controller: _minQtyCtrl,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),

            PrimaryButton(text: 'حفظ الصنف', onPressed: _save),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _ProductDetailSheet extends StatelessWidget {
  final Product product;
  final AppState state;

  const _ProductDetailSheet({required this.product, required this.state});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            product.name,
            style: const TextStyle(
              color: AppColors.textMain,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 4),
          AppBadge(text: product.category, color: AppColors.accentBlue),
          const SizedBox(height: 20),
          _DetailRow('سعر البيع', formatMoney(product.sellPrice),
              AppColors.accentMint),
          _DetailRow('سعر التكلفة', formatMoney(product.costPrice),
              AppColors.textSub),
          _DetailRow('الكمية الموجودة', '${product.qtyExist.toInt()} وحدة',
              AppColors.accentGreen),
          _DetailRow('الكمية المباعة', '${product.qtySold.toInt()} وحدة',
              AppColors.textSub),
          _DetailRow('الربح المحقق', formatMoney(product.profit),
              AppColors.accentGreen),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    state.deleteProduct(product.id);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.delete, color: AppColors.accentRed),
                  label: const Text('حذف',
                      style: TextStyle(
                          color: AppColors.accentRed, fontFamily: 'Cairo')),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.accentRed),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.edit),
                  label: const Text('تعديل',
                      style: TextStyle(fontFamily: 'Cairo')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentBlue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _DetailRow(this.label, this.value, this.valueColor);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSub,
              fontFamily: 'Cairo',
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
