import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/app_state.dart';
import '../models/app_models.dart';
import '../widgets/common_widgets.dart';

class SavedInvoicesScreen extends StatefulWidget {
  const SavedInvoicesScreen({super.key});

  @override
  State<SavedInvoicesScreen> createState() => _SavedInvoicesScreenState();
}

class _SavedInvoicesScreenState extends State<SavedInvoicesScreen> {
  String _filter = 'الكل';
  final List<String> _filters = ['الكل', 'اليوم', 'هذا الأسبوع', 'هذا الشهر', 'ديون فقط'];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final invoices = _getFiltered(state.invoices);
    final total = invoices.fold(0.0, (s, inv) => s + inv.totalAmount);

    return Scaffold(
      backgroundColor: AppColors.appSurface,
      appBar: AppBar(
        backgroundColor: AppColors.cardDark,
        leading: IconButton(
          icon: const Icon(Icons.chevron_right, color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('الفواتير المحفوظة'),
      ),
      body: Column(
        children: [
          // فلتر
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _filters.map((f) => Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: FilterChip(
                          label: Text(f, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12)),
                          selected: _filter == f,
                          onSelected: (_) => setState(() => _filter = f),
                          selectedColor: AppColors.accentGreen.withOpacity(0.2),
                          checkmarkColor: AppColors.accentGreen,
                          backgroundColor: AppColors.cardSurface,
                          side: BorderSide(
                            color: _filter == f ? AppColors.accentGreen : AppColors.borderColor,
                          ),
                          labelStyle: TextStyle(
                            color: _filter == f ? AppColors.accentGreen : AppColors.textSub,
                          ),
                        ),
                      )).toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'العدد: ${invoices.length}',
                  style: const TextStyle(color: AppColors.textSub, fontFamily: 'Cairo', fontSize: 12),
                ),
              ],
            ),
          ),

          // القائمة
          Expanded(
            child: invoices.isEmpty
                ? const EmptyState(
                    message: 'لا توجد فواتير محفوظة بعد',
                    icon: Icons.receipt_long,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: invoices.length,
                    itemBuilder: (ctx, i) => _InvoiceCard(
                      invoice: invoices[i],
                      onTap: () => _showDetails(context, invoices[i]),
                    ),
                  ),
          ),

          // الإجمالي
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.cardSurface,
              border: Border(top: BorderSide(color: AppColors.borderColor)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('إجمالي القائمة:', style: TextStyle(color: AppColors.textSub, fontFamily: 'Cairo')),
                Text(
                  formatMoney(total),
                  style: const TextStyle(
                    color: AppColors.accentMint,
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

  List<Invoice> _getFiltered(List<Invoice> all) {
    final now = DateTime.now();
    switch (_filter) {
      case 'اليوم':
        return all.where((inv) =>
          inv.date.year == now.year && inv.date.month == now.month && inv.date.day == now.day).toList();
      case 'هذا الأسبوع':
        final weekAgo = now.subtract(const Duration(days: 7));
        return all.where((inv) => inv.date.isAfter(weekAgo)).toList();
      case 'هذا الشهر':
        return all.where((inv) => inv.date.year == now.year && inv.date.month == now.month).toList();
      case 'ديون فقط':
        return all.where((inv) => inv.isDebt && inv.remaining > 0).toList();
      default:
        return all;
    }
  }

  void _showDetails(BuildContext context, Invoice invoice) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (_, ctrl) => _InvoiceDetailSheet(invoice: invoice, controller: ctrl),
      ),
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  final Invoice invoice;
  final VoidCallback onTap;

  const _InvoiceCard({required this.invoice, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final displayName = invoice.title ?? invoice.customerName ?? 'فاتورة #${invoice.id.substring(invoice.id.length - 4)}';

    return AppCard(
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: invoice.isDebt
                  ? AppColors.accentAmber.withOpacity(0.15)
                  : AppColors.accentGreen.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              invoice.isDebt ? Icons.money_off : Icons.receipt_long,
              color: invoice.isDebt ? AppColors.accentAmber : AppColors.accentGreen,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    color: AppColors.textMain,
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${invoice.date.day}/${invoice.date.month}/${invoice.date.year}',
                  style: const TextStyle(color: AppColors.textSub, fontFamily: 'Cairo', fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatMoney(invoice.totalAmount),
                style: const TextStyle(
                  color: AppColors.accentMint,
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              if (invoice.isDebt && invoice.remaining > 0)
                AppBadge(text: 'دَيْن', color: AppColors.accentAmber),
            ],
          ),
        ],
      ),
    );
  }
}

class _InvoiceDetailSheet extends StatelessWidget {
  final Invoice invoice;
  final ScrollController controller;

  const _InvoiceDetailSheet({required this.invoice, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: controller,
      padding: const EdgeInsets.all(20),
      children: [
        Center(
          child: Container(
            width: 40, height: 4,
            decoration: BoxDecoration(color: AppColors.borderColor, borderRadius: BorderRadius.circular(2)),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              invoice.customerName ?? 'فاتورة مبيعات',
              style: const TextStyle(color: AppColors.textMain, fontSize: 18, fontWeight: FontWeight.w700, fontFamily: 'Cairo'),
            ),
            IconButton(
              icon: const Icon(Icons.share, color: AppColors.accentBlue),
              onPressed: () {},
            ),
          ],
        ),
        Text(
          '${invoice.date.day}/${invoice.date.month}/${invoice.date.year}',
          style: const TextStyle(color: AppColors.textSub, fontFamily: 'Cairo'),
        ),
        const SizedBox(height: 16),
        const Divider(color: AppColors.borderColor),
        ...invoice.items.map((item) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: Text('${item.product.name}',
                    style: const TextStyle(color: AppColors.textMain, fontFamily: 'Cairo')),
              ),
              Text('× ${item.qty.toInt()}',
                  style: const TextStyle(color: AppColors.textSub, fontFamily: 'Cairo')),
              const SizedBox(width: 12),
              Text(formatMoney(item.total),
                  style: const TextStyle(color: AppColors.textMain, fontFamily: 'Cairo', fontWeight: FontWeight.w600)),
            ],
          ),
        )),
        const Divider(color: AppColors.borderColor),
        _SummaryRow('الإجمالي', formatMoney(invoice.totalAmount), AppColors.textMain),
        _SummaryRow('المدفوع', formatMoney(invoice.paidAmount), AppColors.accentGreen),
        if (invoice.remaining > 0)
          _SummaryRow('المتبقي (دَيْن)', formatMoney(invoice.remaining), AppColors.accentAmber),
        _SummaryRow('طريقة الدفع', invoice.paymentMethod, AppColors.accentBlue),
        if (invoice.note != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: Text(invoice.note!, style: const TextStyle(color: AppColors.textSub, fontFamily: 'Cairo')),
          ),
        ],
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _SummaryRow(this.label, this.value, this.valueColor);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSub, fontFamily: 'Cairo', fontSize: 14)),
          Text(value, style: TextStyle(color: valueColor, fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 14)),
        ],
      ),
    );
  }
}
