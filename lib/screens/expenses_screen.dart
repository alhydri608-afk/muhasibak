import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/app_state.dart';
import '../models/app_models.dart';
import '../widgets/common_widgets.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  String _filterPeriod = 'الكل';
  final List<String> _periods = ['الكل', 'اليوم', 'هذا الأسبوع', 'هذا الشهر'];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final grouped = _groupByCategory(state.expenses);
    final total = state.expenses.fold(0.0, (s, e) => s + e.amount);

    return Scaffold(
      backgroundColor: AppColors.appSurface,
      appBar: AppBar(
        backgroundColor: AppColors.cardDark,
        leading: IconButton(
          icon: const Icon(Icons.chevron_right, color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('سجل المصروفات'),
      ),
      body: Column(
        children: [
          // فلتر
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Row(
              children: [
                const Icon(Icons.filter_list,
                    color: AppColors.textSub, size: 18),
                const SizedBox(width: 8),
                const Text(
                  'الترتيب والتصفية:',
                  style: TextStyle(
                    color: AppColors.textSub,
                    fontFamily: 'Cairo',
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _periods
                          .map((p) => Padding(
                                padding: const EdgeInsets.only(left: 6),
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
                                    fontSize: 12,
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

          // القائمة
          Expanded(
            child: grouped.isEmpty
                ? const EmptyState(
                    message: 'لا توجد مصروفات مسجلة',
                    icon: Icons.account_balance_wallet_outlined,
                  )
                : ListView(
                    padding: const EdgeInsets.all(12),
                    children: grouped.entries.map((entry) {
                      return AccordionSection(
                        title: entry.key,
                        badge:
                            formatMoney(entry.value.fold(0.0, (s, e) => s + e.amount)),
                        initiallyExpanded: true,
                        children: entry.value.map((exp) => _ExpenseRow(
                              expense: exp,
                              onDelete: () => state.deleteExpense(exp.id),
                            )).toList(),
                      );
                    }).toList(),
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
                const Text(
                  'إجمالي المصروفات:',
                  style: TextStyle(
                    color: AppColors.textSub,
                    fontFamily: 'Cairo',
                    fontSize: 14,
                  ),
                ),
                Text(
                  formatMoney(total),
                  style: const TextStyle(
                    color: AppColors.accentRed,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddExpense(context, state),
        backgroundColor: AppColors.accentGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Map<String, List<Expense>> _groupByCategory(List<Expense> expenses) {
    final map = <String, List<Expense>>{};
    for (var e in expenses) {
      map.putIfAbsent(e.category, () => []).add(e);
    }
    return map;
  }

  void _showAddExpense(BuildContext context, AppState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AddExpenseSheet(state: state),
    );
  }
}

class _ExpenseRow extends StatelessWidget {
  final Expense expense;
  final VoidCallback onDelete;

  const _ExpenseRow({required this.expense, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                Text(
                  expense.note ?? expense.category,
                  style: const TextStyle(
                    color: AppColors.textMain,
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${expense.date.day}/${expense.date.month}/${expense.date.year}',
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
            formatMoney(expense.amount),
            style: const TextStyle(
              color: AppColors.accentRed,
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.delete_outline,
                color: AppColors.accentRed, size: 18),
            onPressed: onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }
}

class _AddExpenseSheet extends StatefulWidget {
  final AppState state;
  const _AddExpenseSheet({required this.state});

  @override
  State<_AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<_AddExpenseSheet> {
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final _newCategoryCtrl = TextEditingController();
  String _category = 'إيجار';
  bool _showNewCategory = false;

  final List<String> _defaultCategories = [
    'إيجار',
    'كهرباء',
    'مياه',
    'رواتب',
    'صيانة',
    'تسويق',
    'نقل',
    'أخرى',
  ];

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    _newCategoryCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_amountCtrl.text.isEmpty) return;

    final cat = _showNewCategory ? _newCategoryCtrl.text.trim() : _category;
    if (cat.isEmpty) return;

    final expense = Expense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      category: cat,
      amount: double.tryParse(_amountCtrl.text) ?? 0,
      date: DateTime.now(),
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
    );

    widget.state.addExpense(expense);
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
            'إضافة مصروف جديد',
            style: TextStyle(
              color: AppColors.textMain,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _category,
            onChanged: (v) => setState(() {
              _category = v!;
              _showNewCategory = v == 'أخرى';
            }),
            dropdownColor: AppColors.cardSurface,
            style: const TextStyle(
                color: AppColors.textMain, fontFamily: 'Cairo'),
            decoration:
                const InputDecoration(labelText: 'الفئة'),
            items: _defaultCategories
                .map((c) => DropdownMenuItem(
                      value: c,
                      child:
                          Text(c, style: const TextStyle(fontFamily: 'Cairo')),
                    ))
                .toList(),
          ),
          if (_showNewCategory) ...[
            const SizedBox(height: 10),
            AppTextField(
              hint: 'مثال: صيانة، تسويق...',
              controller: _newCategoryCtrl,
            ),
          ],
          const SizedBox(height: 12),
          AppTextField(
            label: 'المبلغ',
            hint: '0.00',
            controller: _amountCtrl,
            keyboardType: TextInputType.number,
            required: true,
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: 'ملاحظة',
            hint: 'وصف المصروف...',
            controller: _noteCtrl,
          ),
          const SizedBox(height: 16),
          PrimaryButton(text: 'حفظ المصروف', onPressed: _save),
        ],
      ),
    );
  }
}
