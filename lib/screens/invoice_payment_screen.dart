import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/app_state.dart';
import '../models/app_models.dart';
import '../widgets/common_widgets.dart';

class InvoicePaymentScreen extends StatefulWidget {
  const InvoicePaymentScreen({super.key});

  @override
  State<InvoicePaymentScreen> createState() => _InvoicePaymentScreenState();
}

class _InvoicePaymentScreenState extends State<InvoicePaymentScreen> {
  final _customerNameCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final _paidCtrl = TextEditingController();
  String _paymentMethod = 'نقداً';
  double _remaining = 0;
  bool _isDebt = false;

  final List<String> _paymentMethods = [
    'نقداً',
    'حوالة بنكية',
    'كريمي',
    'جاهزكاش',
    'سبأفون كاش',
    'دَيْن',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final total = context.read<AppState>().cartTotal;
      _paidCtrl.text = total.toStringAsFixed(2);
      _calculateRemaining();
    });
  }

  @override
  void dispose() {
    _customerNameCtrl.dispose();
    _noteCtrl.dispose();
    _paidCtrl.dispose();
    super.dispose();
  }

  void _calculateRemaining() {
    final state = context.read<AppState>();
    final total = state.cartTotal;
    final paid = double.tryParse(_paidCtrl.text) ?? 0;
    setState(() {
      _remaining = total - paid;
      _isDebt = _remaining > 0;
    });
  }

  void _saveInvoice() {
    final state = context.read<AppState>();
    if (_isDebt && _customerNameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب إدخال اسم العميل في حالة الدين',
              style: TextStyle(fontFamily: 'Cairo')),
          backgroundColor: AppColors.accentRed,
        ),
      );
      return;
    }

    final paid = double.tryParse(_paidCtrl.text) ?? state.cartTotal;
    final invoice = Invoice(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      customerName: _customerNameCtrl.text.trim().isEmpty
          ? null
          : _customerNameCtrl.text.trim(),
      date: DateTime.now(),
      items: List.from(state.currentCart),
      paymentMethod: _paymentMethod,
      paidAmount: paid,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      isDebt: _isDebt,
    );

    state.saveInvoice(invoice);
    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.accentGreen.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppColors.accentGreen,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'تم حفظ الفاتورة!',
              style: TextStyle(
                color: AppColors.textMain,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'تمت العملية بنجاح',
              style: TextStyle(color: AppColors.textSub, fontFamily: 'Cairo'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).popUntil((r) => r.isFirst ||
                  r.settings.name == '/main');
            },
            child: const Text(
              'العودة للرئيسية',
              style: TextStyle(
                color: AppColors.accentGreen,
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final total = state.cartTotal;

    return Scaffold(
      backgroundColor: AppColors.appSurface,
      appBar: AppBar(
        backgroundColor: AppColors.cardDark,
        leading: IconButton(
          icon: const Icon(Icons.chevron_right, color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('تسوية الفاتورة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: AppColors.textMain),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // إجمالي الفاتورة
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.accentGreen.withOpacity(0.2),
                    AppColors.accentBlue.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.accentGreen.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Text(
                    'المبلغ المطلوب سداده',
                    style: TextStyle(
                      color: AppColors.textSub,
                      fontFamily: 'Cairo',
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatMoney(total),
                    style: const TextStyle(
                      color: AppColors.accentMint,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ملخص الأصناف
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ملخص الأصناف',
                    style: TextStyle(
                      color: AppColors.textMain,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Cairo',
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...state.currentCart.map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${item.product.name} × ${item.qty.toInt()}',
                                style: const TextStyle(
                                  color: AppColors.textSub,
                                  fontFamily: 'Cairo',
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Text(
                              formatMoney(item.total),
                              style: const TextStyle(
                                color: AppColors.textMain,
                                fontFamily: 'Cairo',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // نموذج الدفع
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // اسم العميل
                  const Text(
                    'اسم العميل',
                    style: TextStyle(
                      color: AppColors.textSub,
                      fontSize: 13,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _customerNameCtrl,
                    style: const TextStyle(
                        color: AppColors.textMain, fontFamily: 'Cairo'),
                    decoration: const InputDecoration(
                        hintText: 'أدخل اسم العميل...'),
                  ),
                  const SizedBox(height: 14),

                  // طريقة الدفع
                  const Text(
                    'طريقة الدفع',
                    style: TextStyle(
                      color: AppColors.textSub,
                      fontSize: 13,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _paymentMethod,
                    onChanged: (v) => setState(() {
                      _paymentMethod = v!;
                      if (v == 'دَيْن') {
                        _paidCtrl.text = '0';
                        _calculateRemaining();
                      }
                    }),
                    dropdownColor: AppColors.cardSurface,
                    style: const TextStyle(
                        color: AppColors.textMain, fontFamily: 'Cairo'),
                    decoration: const InputDecoration(),
                    items: _paymentMethods
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e,
                                  style:
                                      const TextStyle(fontFamily: 'Cairo')),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 14),

                  // ملاحظة
                  const Text(
                    'ملاحظة',
                    style: TextStyle(
                      color: AppColors.textSub,
                      fontSize: 13,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _noteCtrl,
                    maxLines: 2,
                    style: const TextStyle(
                        color: AppColors.textMain, fontFamily: 'Cairo'),
                    decoration: const InputDecoration(
                        hintText: 'أضف ملاحظة على الفاتورة...'),
                  ),
                  const SizedBox(height: 14),

                  // المدفوع والمتبقي
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'المبلغ المدفوع',
                              style: TextStyle(
                                color: AppColors.textSub,
                                fontSize: 13,
                                fontFamily: 'Cairo',
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _paidCtrl,
                              keyboardType: TextInputType.number,
                              onChanged: (_) => _calculateRemaining(),
                              style: const TextStyle(
                                  color: AppColors.textMain,
                                  fontFamily: 'Cairo'),
                              decoration: const InputDecoration(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'المتبقي',
                              style: TextStyle(
                                color: AppColors.textSub,
                                fontSize: 13,
                                fontFamily: 'Cairo',
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: _remaining > 0
                                    ? AppColors.accentRed.withOpacity(0.1)
                                    : AppColors.accentGreen.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: _remaining > 0
                                      ? AppColors.accentRed
                                      : AppColors.accentGreen,
                                ),
                              ),
                              child: Text(
                                formatMoney(_remaining.abs()),
                                style: TextStyle(
                                  color: _remaining > 0
                                      ? AppColors.accentRed
                                      : AppColors.accentGreen,
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (_isDebt) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.accentAmber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.accentAmber.withOpacity(0.4)),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.warning_amber,
                              color: AppColors.accentAmber, size: 18),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'سيتم تسجيل الباقي كدَيْن على العميل',
                              style: TextStyle(
                                color: AppColors.accentAmber,
                                fontFamily: 'Cairo',
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // زر الحفظ
            PrimaryButton(
              text: 'حفظ الفاتورة النهائي',
              onPressed: _saveInvoice,
              icon: Icons.save,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
