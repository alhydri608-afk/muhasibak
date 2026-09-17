import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/app_state.dart';
import '../models/app_models.dart';
import '../widgets/common_widgets.dart';
import 'invoice_payment_screen.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();
  final Set<String> _expandedCategories = {};

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final productsByCategory = _getFilteredProducts(state);

    return Scaffold(
      backgroundColor: AppColors.appSurface,
      appBar: AppBar(
        backgroundColor: AppColors.cardDark,
        leading: IconButton(
          icon: const Icon(Icons.chevron_right, color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('فاتورة جديدة'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _searchQuery = v),
              style: const TextStyle(color: AppColors.textMain, fontFamily: 'Cairo'),
              decoration: InputDecoration(
                hintText: 'بحث عن صنف...',
                hintStyle: const TextStyle(color: AppColors.textSub),
                prefixIcon: const Icon(Icons.search, color: AppColors.textSub),
                filled: true,
                fillColor: AppColors.cardSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ),
      ),
      body: productsByCategory.isEmpty
          ? const EmptyState(
              message: 'لا توجد منتجات\nأضف منتجات من المخزون أولاً',
              icon: Icons.inventory_2_outlined,
            )
          : ListView(
              padding: const EdgeInsets.all(12),
              children: productsByCategory.entries.map((entry) {
                return _buildCategorySection(entry.key, entry.value, state);
              }).toList(),
            ),
      bottomNavigationBar: _buildCartBar(context, state),
    );
  }

  Map<String, List<Product>> _getFilteredProducts(AppState state) {
    final query = _searchQuery.toLowerCase();
    final map = <String, List<Product>>{};
    for (var p in state.products) {
      if (query.isEmpty ||
          p.name.toLowerCase().contains(query) ||
          p.category.toLowerCase().contains(query)) {
        map.putIfAbsent(p.category, () => []).add(p);
      }
    }
    return map;
  }

  Widget _buildCategorySection(
      String category, List<Product> products, AppState state) {
    final isExpanded = _expandedCategories.contains(category);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor, width: 0.8),
      ),
      child: Column(
        children: [
          // رأس القسم
          InkWell(
            onTap: () => setState(() {
              if (isExpanded) {
                _expandedCategories.remove(category);
              } else {
                _expandedCategories.add(category);
              }
            }),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
              decoration: const BoxDecoration(
                color: Color(0xFF1E2D42),
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.category, color: AppColors.accentMint, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      category,
                      style: const TextStyle(
                        color: AppColors.textMain,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Cairo',
                        fontSize: 14,
                      ),
                    ),
                  ),
                  AppBadge(
                    text: '${products.length} صنف',
                    color: AppColors.accentGreen,
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.textSub,
                  ),
                ],
              ),
            ),
          ),
          // محتوى القسم
          if (isExpanded || _searchQuery.isNotEmpty)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.82,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: products.length,
              itemBuilder: (ctx, i) =>
                  _ProductCard(product: products[i], state: state),
            ),
        ],
      ),
    );
  }

  Widget _buildCartBar(BuildContext context, AppState state) {
    if (state.currentCart.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardDark.withOpacity(0.95),
        border: const Border(
          top: BorderSide(color: AppColors.borderColor),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${state.currentCart.length} أصناف',
                style: const TextStyle(
                  color: AppColors.textSub,
                  fontSize: 12,
                  fontFamily: 'Cairo',
                ),
              ),
              Text(
                formatMoney(state.cartTotal),
                style: const TextStyle(
                  color: AppColors.accentMint,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const InvoicePaymentScreen()),
              ),
              icon: const Icon(Icons.receipt_long),
              label: const Text(
                'إتمام الفاتورة',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Cairo',
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentGreen,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final AppState state;

  const _ProductCard({required this.product, required this.state});

  @override
  Widget build(BuildContext context) {
    final cartItem = state.currentCart
        .where((i) => i.product.id == product.id)
        .firstOrNull;
    final qty = cartItem?.qty ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.appSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: qty > 0 ? AppColors.accentGreen : AppColors.borderColor,
          width: qty > 0 ? 1.5 : 0.8,
        ),
      ),
      child: Column(
        children: [
          // صورة المنتج / أيقونة
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: product.imageUrl != null
                      ? ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12)),
                          child: Image.network(
                            product.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.image_not_supported,
                                    color: AppColors.textSub, size: 40),
                          ),
                        )
                      : const Center(
                          child: Icon(Icons.shopping_bag,
                              color: AppColors.textSub, size: 36),
                        ),
                ),
                if (qty > 0)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.accentGreen,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'x${qty.toInt()}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // معلومات المنتج
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    color: AppColors.textMain,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Cairo',
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  formatMoney(product.sellPrice),
                  style: const TextStyle(
                    color: AppColors.accentMint,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
          // أزرار الكمية
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: Row(
              children: [
                _QtyBtn(
                  icon: Icons.add,
                  color: AppColors.accentGreen,
                  onTap: () => state.addToCart(product),
                ),
                const SizedBox(width: 6),
                Text(
                  qty.toInt().toString(),
                  style: const TextStyle(
                    color: AppColors.textMain,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(width: 6),
                _QtyBtn(
                  icon: Icons.remove,
                  color: AppColors.accentRed,
                  onTap: qty > 0
                      ? () => state.updateCartQty(product.id, -1)
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _QtyBtn({required this.icon, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: onTap != null ? color : AppColors.borderColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }
}
