import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/app_state.dart';
import '../models/app_models.dart';
import '../widgets/common_widgets.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
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
    final isSupplierTab = _tabController.index == 1;

    final contacts = state.contacts
        .where((c) => c.isSupplier == isSupplierTab)
        .where((c) =>
            _searchQuery.isEmpty ||
            c.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.appSurface,
      appBar: AppBar(
        backgroundColor: AppColors.cardDark,
        leading: IconButton(
          icon: const Icon(Icons.chevron_right, color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
        title: SearchBar2(
          hint: 'بحث...',
          controller: _searchCtrl,
          onChanged: (v) => setState(() => _searchQuery = v),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accentGreen,
          labelColor: AppColors.accentGreen,
          unselectedLabelColor: AppColors.textSub,
          labelStyle: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700),
          tabs: const [
            Tab(text: 'العملاء'),
            Tab(text: 'الموردين'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildContactsList(context, state, false),
          _buildContactsList(context, state, true),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddContactDialog(context, state, isSupplierTab),
        backgroundColor: AppColors.accentGreen,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          isSupplierTab ? 'إضافة مورد' : 'إضافة عميل',
          style: const TextStyle(color: Colors.white, fontFamily: 'Cairo'),
        ),
      ),
    );
  }

  Widget _buildContactsList(BuildContext context, AppState state, bool isSupplier) {
    final contacts = state.contacts
        .where((c) => c.isSupplier == isSupplier)
        .where((c) =>
            _searchQuery.isEmpty ||
            c.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    if (contacts.isEmpty) {
      return EmptyState(
        message: isSupplier
            ? 'لا يوجد موردون مسجلون بعد'
            : 'لا يوجد عملاء مسجلون بعد',
        icon: isSupplier ? Icons.local_shipping_outlined : Icons.people_outline,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: contacts.length,
      itemBuilder: (ctx, i) => _ContactCard(
        contact: contacts[i],
        onEdit: () => _showEditContactDialog(context, state, contacts[i]),
        onDelete: () => _confirmDelete(context, state, contacts[i]),
      ),
    );
  }

  void _showAddContactDialog(BuildContext context, AppState state, bool isSupplier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ContactFormSheet(
        state: state,
        isSupplier: isSupplier,
      ),
    );
  }

  void _showEditContactDialog(BuildContext context, AppState state, Contact contact) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ContactFormSheet(
        state: state,
        isSupplier: contact.isSupplier,
        existing: contact,
      ),
    );
  }

  void _confirmDelete(BuildContext context, AppState state, Contact contact) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardSurface,
        title: const Text('تأكيد الحذف',
            style: TextStyle(color: AppColors.textMain, fontFamily: 'Cairo')),
        content: Text(
          'هل تريد حذف "${contact.name}"؟',
          style: const TextStyle(color: AppColors.textSub, fontFamily: 'Cairo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
          ),
          TextButton(
            onPressed: () {
              state.deleteContact(contact.id);
              Navigator.pop(context);
            },
            child: const Text('حذف',
                style: TextStyle(color: AppColors.accentRed, fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final Contact contact;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ContactCard({
    required this.contact,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: contact.isSupplier
                ? AppColors.accentBlue.withOpacity(0.2)
                : AppColors.accentGreen.withOpacity(0.2),
            child: Text(
              contact.name.isNotEmpty ? contact.name[0] : '?',
              style: TextStyle(
                color: contact.isSupplier ? AppColors.accentBlue : AppColors.accentGreen,
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: const TextStyle(
                    color: AppColors.textMain,
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                if (contact.phone != null)
                  Row(
                    children: [
                      const Icon(Icons.phone, color: AppColors.textSub, size: 13),
                      const SizedBox(width: 4),
                      Text(
                        contact.phone!,
                        style: const TextStyle(
                          color: AppColors.textSub,
                          fontFamily: 'Cairo',
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                if (contact.address != null)
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: AppColors.textSub, size: 13),
                      const SizedBox(width: 4),
                      Text(
                        contact.address!,
                        style: const TextStyle(
                          color: AppColors.textSub,
                          fontFamily: 'Cairo',
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.textSub),
            color: AppColors.cardSurface,
            onSelected: (v) {
              if (v == 'edit') onEdit();
              if (v == 'delete') onDelete();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: AppColors.accentBlue, size: 18),
                    SizedBox(width: 8),
                    Text('تعديل', style: TextStyle(fontFamily: 'Cairo', color: AppColors.textMain)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: AppColors.accentRed, size: 18),
                    SizedBox(width: 8),
                    Text('حذف', style: TextStyle(fontFamily: 'Cairo', color: AppColors.accentRed)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContactFormSheet extends StatefulWidget {
  final AppState state;
  final bool isSupplier;
  final Contact? existing;

  const _ContactFormSheet({
    required this.state,
    required this.isSupplier,
    this.existing,
  });

  @override
  State<_ContactFormSheet> createState() => _ContactFormSheetState();
}

class _ContactFormSheetState extends State<_ContactFormSheet> {
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _addressCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existing?.name ?? '');
    _phoneCtrl = TextEditingController(text: widget.existing?.phone ?? '');
    _addressCtrl = TextEditingController(text: widget.existing?.address ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الاسم مطلوب', style: TextStyle(fontFamily: 'Cairo')),
          backgroundColor: AppColors.accentRed,
        ),
      );
      return;
    }

    final contact = Contact(
      id: widget.existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      address: _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
      isSupplier: widget.isSupplier,
    );

    if (widget.existing != null) {
      widget.state.updateContact(contact);
    } else {
      widget.state.addContact(contact);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    final label = widget.isSupplier ? 'مورد' : 'عميل';

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(color: AppColors.borderColor, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 16),
          Text(
            isEdit ? 'تعديل $label' : 'إضافة $label جديد',
            style: const TextStyle(
              color: AppColors.textMain, fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'الاسم',
            hint: 'اسم ${widget.isSupplier ? "المورد" : "العميل"}',
            controller: _nameCtrl,
            required: true,
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: 'رقم الهاتف',
            hint: '77XXXXXXX',
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: 'العنوان',
            hint: 'المدينة / الحي...',
            controller: _addressCtrl,
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            text: isEdit ? 'حفظ التعديلات' : 'إضافة $label',
            onPressed: _save,
            icon: isEdit ? Icons.save : Icons.add,
          ),
        ],
      ),
    );
  }
}
