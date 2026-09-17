import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/app_state.dart';
import 'invoice_screen.dart';
import 'inventory_screen.dart';
import 'purchases_screen.dart';
import 'expenses_screen.dart';
import 'debts_screen.dart';
import 'saved_invoices_screen.dart';
import 'contacts_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final storeName = state.userProfile?.storeName ?? 'متجري';

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: AppColors.lightPrimary,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Text(
          storeName,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: () => _showHelp(context),
          ),
        ],
        elevation: 4,
      ),
      drawer: _buildDrawer(context, state),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // الصف الأول: مشتريات، مخزون، مصروفات
          Row(
            children: [
              _MenuCard(
                icon: Icons.shopping_cart,
                label: 'المشتريات',
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PurchasesScreen())),
              ),
              const SizedBox(width: 16),
              _MenuCard(
                icon: Icons.inventory_2,
                label: 'المخزون',
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const InventoryScreen())),
              ),
              const SizedBox(width: 16),
              _MenuCard(
                icon: Icons.account_balance_wallet,
                label: 'المصروفات',
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ExpensesScreen())),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // بطاقة فاتورة جديدة (كاملة العرض)
          _InvoiceCard(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const InvoiceScreen())),
          ),
          const SizedBox(height: 16),

          // الصف الثالث: ديون، فواتير محفوظة، عملاء وموردين
          Row(
            children: [
              _MenuCard(
                icon: Icons.monetization_on,
                label: 'الديون',
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const DebtsScreen())),
              ),
              const SizedBox(width: 16),
              _MenuCard(
                icon: Icons.archive,
                label: 'الفواتير\nالمحفوظة',
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const SavedInvoicesScreen())),
              ),
              const SizedBox(width: 16),
              _MenuCard(
                icon: Icons.people,
                label: 'العملاء\nوالموردين',
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ContactsScreen())),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, AppState state) {
    return Drawer(
      backgroundColor: AppColors.appSurface,
      child: Column(
        children: [
          // رأس القائمة الجانبية
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.accentBlue, AppColors.accentGreen],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                const Text('📊', style: TextStyle(fontSize: 40)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'محاسبك',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    Text(
                      state.userProfile?.storeName ?? '',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // معلومات التاجر
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.cardSurface,
            child: Column(
              children: [
                _DrawerInfoRow(
                  icon: Icons.person,
                  label: 'المالك',
                  value: state.userProfile?.ownerName ?? '-',
                ),
                const SizedBox(height: 8),
                _DrawerInfoRow(
                  icon: Icons.phone,
                  label: 'الهاتف',
                  value: state.userProfile?.phone ?? '-',
                ),
                const SizedBox(height: 8),
                _DrawerInfoRow(
                  icon: Icons.location_on,
                  label: 'المحافظة',
                  value: state.userProfile?.province ?? '-',
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.borderColor, height: 1),
          // روابط
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: [
                _DrawerItem(
                  icon: Icons.bar_chart,
                  label: 'التقارير',
                  onTap: () => Navigator.pop(context),
                ),
                _DrawerItem(
                  icon: Icons.settings,
                  label: 'الإعدادات',
                  onTap: () => Navigator.pop(context),
                ),
                _DrawerItem(
                  icon: Icons.info_outline,
                  label: 'عن التطبيق',
                  onTap: () {
                    Navigator.pop(context);
                    _showAbout(context);
                  },
                ),
                const Divider(color: AppColors.borderColor),
                _DrawerItem(
                  icon: Icons.logout,
                  label: 'تسجيل الخروج',
                  color: AppColors.accentRed,
                  onTap: () {
                    state.logout();
                    Navigator.of(context).popUntil((r) => r.isFirst);
                  },
                ),
              ],
            ),
          ),
          // الإصدار
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'محاسبك v2.0',
              style: TextStyle(
                color: AppColors.textSub,
                fontSize: 12,
                fontFamily: 'Cairo',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardSurface,
        title: const Text(
          'دليل المستخدم',
          style: TextStyle(color: AppColors.textMain, fontFamily: 'Cairo'),
        ),
        content: const Text(
          'ابدأ بإضافة منتجاتك في المخزون، ثم أنشئ فواتير المبيعات.\n\nللمساعدة تواصل معنا.',
          style: TextStyle(color: AppColors.textSub, fontFamily: 'Cairo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً', style: TextStyle(fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardSurface,
        title: const Text(
          'عن محاسبك',
          style: TextStyle(color: AppColors.textMain, fontFamily: 'Cairo'),
        ),
        content: const Text(
          'محاسبك - تطبيق محاسبة للمتاجر الصغيرة\nالإصدار: 2.0\nإدارة أسهل... حسابات أدق',
          style: TextStyle(color: AppColors.textSub, fontFamily: 'Cairo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق', style: TextStyle(fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.lightCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.lightBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.lightPrimary, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Cairo',
                  color: AppColors.lightTextMain,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  final VoidCallback onTap;
  const _InvoiceCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.accentBlue, Color(0xFF1D4ED8)],
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentBlue.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.receipt_long, color: Colors.white, size: 28),
            SizedBox(width: 12),
            Text(
              'فاتورة جديدة',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DrawerInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.accentGreen, size: 16),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            color: AppColors.textSub,
            fontSize: 12,
            fontFamily: 'Cairo',
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.textMain,
              fontSize: 13,
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.textSub, size: 22),
      title: Text(
        label,
        style: TextStyle(
          color: color ?? AppColors.textMain,
          fontFamily: 'Cairo',
          fontSize: 14,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}
