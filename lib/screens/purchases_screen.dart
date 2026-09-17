import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/app_state.dart';
import '../models/app_models.dart';
import '../widgets/common_widgets.dart';

class PurchasesScreen extends StatefulWidget {
  const PurchasesScreen({super.key});

  @override
  State<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends State<PurchasesScreen> {
  String _searchQuery = '';
  String _filterPeriod = 'الكل';

  final List<String> _periods = ['الكل', 'اليوم', 'هذا الأسبوع', 'هذا الشهر'];

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
        title: const Text('فواتير المشتريات'),
        actions: [
          const Icon(Icons.inventory_2, color: AppColors.accentBlue, size: 22),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // شريط البحث والتصفية
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                SearchBar2(
                  hint: 'بحث باسم المورد...',
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _periods
                        .map((p) => Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: FilterChip(
                                label: Text(p,
                                    style:
                                        const TextStyle(fontFamily: 'Cairo')),
                                selected: _filterPeriod == p,
                                onSelected: (_) =>
                                    setState(() => _filterPeriod = p),
                                selectedColor:
                                    AppColors.accentGreen.withOpacity(0.2),
                                checkmarkColor: AppColors.accentGreen,
                                labelStyle: TextStyle(
                                  color: _filterPeriod == p
                                      ? AppColors.accentGreen
                                      : AppColors.textSub,
                                ),
                                backgroundColor: AppColors.cardSurface,
                                side: BorderSide(
                                  color: _filterPeriod == p
                                      ? AppColors.accentGreen
                                      : AppColors.borderColor,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),

          // تنبيه أصناف بدون فاتورة
          InkWell(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.accentAmber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.accentAmber.withOpacity(0.4)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.file_open,
                      color: AppColors.accentAmber, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'أصناف بدون فاتورة مشتريات',
                      style: TextStyle(
                        color: AppColors.accentAmber,
                        fontFamily: 'Cairo',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_left,
                      color: AppColors.accentAmber, size: 18),
                ],
              ),
            ),
          ),

          // قائمة الفواتير
          Expanded(
            child: state.purchaseInvoices.isEmpty
                ? const EmptyState(
                    message: 'لا توجد فواتير مشتريات بعد\nاضغط + لإضافة فاتورة',
                    icon: Icons.receipt_long,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: state.purchaseInvoices.length,
                    itemBuilder: (ctx, i) {
                      final inv = state.purchaseInvoices[i];
                      return AppCard(
                        padding: const EdgeInsets.all(14),
                        onTap: () {},
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color:
                                    AppColors.accentBlue.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.receipt_long,
                                  color: AppColors.accentBlue, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    inv.supplierName ?? 'بدون اسم مورد',
                                    style: const TextStyle(
                                      color: AppColors.textMain,
                                      fontFamily: 'Cairo',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '${inv.date.day}/${inv.date.month}/${inv.date.year}',
                                    style: const TextStyle(
                                      color: AppColors.textSub,
                                      fontFamily: 'Cairo',
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              formatMoney(inv.totalCost),
                              style: const TextStyle(
                                color: AppColors.accentMint,
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewPurchaseForm(context, state),
        backgroundColor: AppColors.accentGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showNewPurchaseForm(BuildContext context, AppState state) {
    // نموذج إضافة فاتورة مشتريات
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _NewPurchaseSheet(state: state),
    );
  }
}

class _NewPurchaseSheet extends StatefulWidget {
  final AppState state;
  const _NewPurchaseSheet({required this.state});

  @override
  State<_NewPurchaseSheet> createState() => _NewPurchaseSheetState();
}

class _NewPurchaseSheetState extends State<_NewPurchaseSheet> {
  final _supplierCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  final List<PurchaseItem> _items = [];

  @override
  void dispose() {
    _supplierCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('أضف صنفاً واحداً على الأقل',
              style: TextStyle(fontFamily: 'Cairo')),
          backgroundColor: AppColors.accentRed,
        ),
      );
      return;
    }

    final invoice = PurchaseInvoice(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      supplierName: _supplierCtrl.text.trim().isEmpty
          ? null
          : _supplierCtrl.text.trim(),
      date: _date,
      items: _items,
    );

    widget.state.purchaseInvoices.add(invoice);
    widget.state.notifyListeners();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
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
          const Text(
            'فاتورة مشتريات جديدة',
            style: TextStyle(
              color: AppColors.textMain,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  label: 'اسم المورد',
                  hint: 'اسم المورد',
                  controller: _supplierCtrl,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'التاريخ',
                      style: TextStyle(
                        color: AppColors.textSub,
                        fontSize: 13,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: _date,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (d != null) setState(() => _date = d);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.cardSurface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.borderColor),
                        ),
                        child: Text(
                          '${_date.day}/${_date.month}/${_date.year}',
                          style: const TextStyle(
                            color: AppColors.textMain,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          PrimaryButton(text: 'حفظ الفاتورة', onPressed: _save),
        ],
      ),
    );
  }
}
