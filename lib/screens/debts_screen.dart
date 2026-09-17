import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/app_state.dart';
import '../models/app_models.dart';
import '../widgets/common_widgets.dart';

class DebtsScreen extends StatefulWidget {
  const DebtsScreen({super.key});

  @override
  State<DebtsScreen> createState() => _DebtsScreenState();
}

class _DebtsScreenState extends State<DebtsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _filterPeriod = 'الكل';

  final List<String> _periods = ['الكل', 'اليوم', 'هذا الأسبوع', 'هذا الشهر'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final customerDebts = state.customerDebts;
    final totalCustomer = customerDebts.fold(0.0, (s, inv) => s + inv.remaining);

    return Scaffold(
      backgroundColor: AppColors.appSurface,
      appBar: AppBar(
        backgroundColor: AppColors.cardDark,
        leading: IconButton(
          icon: const Icon(Icons.chevron_right, color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('سجل الديون غير المسددة'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accentGreen,
          labelColor: AppColors.accentGreen,
          unselectedLabelColor: AppColors.textSub,
          labelStyle:
              const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700),
          tabs: const [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people, size: 16),
                  SizedBox(width: 6),
                  Text('ديون العملاء'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_shipping, size: 16),
                  SizedBox(width: 6),
                  Text('ديون الموردين'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // فلتر الفترة
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            child: Row(
              children: [
                const Icon(Icons.filter_list,
                    color: AppColors.textSub, size: 16),
                const SizedBox(width: 6),
                const Text(
                  'عرض الديون:',
                  style: TextStyle(
                      color: AppColors.textSub,
                      fontFamily: 'Cairo',
                      fontSize: 12),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _periods
                          .map((p) => Padding(
                                padding: const EdgeInsets.only(left: 6),
                                child: ChoiceChip(
                                  label: Text(p,
                                      style: const TextStyle(
                                          fontFamily: 'Cairo', fontSize: 12)),
                                  selected: _filterPeriod == p,
                                  onSelected: (_) =>
                                      setState(() => _filterPeriod = p),
                                  selectedColor:
                                      AppColors.accentGreen.withOpacity(0.2),
                                  backgroundColor: AppColors.cardSurface,
                                  side: BorderSide(
                                    color: _filterPeriod == p
                                        ? AppColors.accentGreen
                                        : AppColors.borderColor,
                                  ),
                                  labelStyle: TextStyle(
                                    color: _filterPeriod == p
                                        ? AppColors.accentGreen
                                        : AppColors.textSub,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // قائمة الديون
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // ديون العملاء
                customerDebts.isEmpty
                    ? const EmptyState(
                        message: 'لا توجد ديون مسجلة للعملاء',
                        icon: Icons.people_outline,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: customerDebts.length,
                        itemBuilder: (ctx, i) {
                          final inv = customerDebts[i];
                          return _DebtCard(invoice: inv);
                        },
                      ),

                // ديون الموردين (فارغة افتراضياً)
                const EmptyState(
                  message: 'لا توجد ديون مسجلة للموردين',
                  icon: Icons.local_shipping,
                ),
              ],
            ),
          ),

          // شريط الإجمالي
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.cardSurface,
              border: Border(top: BorderSide(color: AppColors.borderColor)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _tabController.index == 0
                      ? 'إجمالي ديون العملاء:'
                      : 'إجمالي ديون الموردين:',
                  style: const TextStyle(
                    color: AppColors.textSub,
                    fontFamily: 'Cairo',
                    fontSize: 14,
                  ),
                ),
                Text(
                  formatMoney(totalCustomer),
                  style: const TextStyle(
                    color: AppColors.accentAmber,
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DebtCard extends StatelessWidget {
  final Invoice invoice;
  const _DebtCard({required this.invoice});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      onTap: () => _showDetails(context),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.accentAmber.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.person, color: AppColors.accentAmber, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invoice.customerName ?? 'عميل غير معروف',
                  style: const TextStyle(
                    color: AppColors.textMain,
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${invoice.date.day}/${invoice.date.month}/${invoice.date.year}',
                  style: const TextStyle(
                    color: AppColors.textSub,
                    fontFamily: 'Cairo',
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatMoney(invoice.remaining),
                style: const TextStyle(
                  color: AppColors.accentAmber,
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              const Text(
                'متبقي',
                style: TextStyle(
                  color: AppColors.textSub,
                  fontFamily: 'Cairo',
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
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
              'تفاصيل دين: ${invoice.customerName ?? ""}',
              style: const TextStyle(
                color: AppColors.textMain,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 16),
            ...invoice.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${item.product.name} × ${item.qty.toInt()}',
                        style: const TextStyle(
                            color: AppColors.textSub, fontFamily: 'Cairo'),
                      ),
                      Text(
                        formatMoney(item.total),
                        style: const TextStyle(
                            color: AppColors.textMain, fontFamily: 'Cairo'),
                      ),
                    ],
                  ),
                )),
            const Divider(color: AppColors.borderColor),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('الإجمالي',
                    style:
                        TextStyle(color: AppColors.textSub, fontFamily: 'Cairo')),
                Text(formatMoney(invoice.totalAmount),
                    style: const TextStyle(
                        color: AppColors.textMain,
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('المدفوع',
                    style: TextStyle(
                        color: AppColors.textSub, fontFamily: 'Cairo')),
                Text(formatMoney(invoice.paidAmount),
                    style: const TextStyle(
                        color: AppColors.accentGreen,
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('المتبقي',
                    style: TextStyle(
                        color: AppColors.textSub, fontFamily: 'Cairo')),
                Text(formatMoney(invoice.remaining),
                    style: const TextStyle(
                        color: AppColors.accentAmber,
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              text: 'تسجيل دفعة',
              onPressed: () => Navigator.pop(context),
              icon: Icons.payment,
            ),
          ],
        ),
      ),
    );
  }
}
