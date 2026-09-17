import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/app_models.dart';
import '../models/app_state.dart';
import '../widgets/common_widgets.dart';
import 'main_menu_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ownerNameCtrl = TextEditingController();
  final _storeNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String _businessType = 'بقالة وسوبرماركت';
  String _province = '';
  String _district = '';
  bool _isLoading = false;

  final List<String> _businessTypes = [
    'بقالة وسوبرماركت',
    'مطعم وكافيه',
    'صيدلية',
    'محل ملابس',
    'مواد بناء',
    'إلكترونيات',
    'أخرى',
  ];

  final List<String> _provinces = [
    'صنعاء', 'عدن', 'تعز', 'حضرموت', 'الحديدة',
    'إب', 'ذمار', 'حجة', 'المحويت', 'أبين',
    'شبوة', 'مأرب', 'البيضاء', 'الجوف', 'أمانة العاصمة',
  ];

  @override
  void dispose() {
    _ownerNameCtrl.dispose();
    _storeNameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    final profile = UserProfile(
      ownerName: _ownerNameCtrl.text.trim(),
      storeName: _storeNameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      businessType: _businessType,
      province: _province,
      district: _district,
    );

    context.read<AppState>().login(profile);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainMenuScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 450),
            decoration: BoxDecoration(
              color: AppColors.appSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // الشعار
                  _buildBrand(),
                  const SizedBox(height: 28),

                  // اسم التاجر
                  _buildLabel('اسم التاجر (المالك)', required: true),
                  const SizedBox(height: 6),
                  _buildInput(
                    controller: _ownerNameCtrl,
                    hint: 'مثال: محمد أحمد الريمي',
                    validator: (v) => v!.isEmpty ? 'هذا الحقل مطلوب' : null,
                  ),
                  const SizedBox(height: 16),

                  // اسم المتجر
                  _buildLabel('اسم المتجر / النشاط التجاري', required: true),
                  const SizedBox(height: 6),
                  _buildInput(
                    controller: _storeNameCtrl,
                    hint: 'مثال: سوبرماركت البركة',
                    validator: (v) => v!.isEmpty ? 'هذا الحقل مطلوب' : null,
                  ),
                  const SizedBox(height: 16),

                  // رقم الهاتف
                  _buildLabel('رقم الهاتف', required: true),
                  const SizedBox(height: 6),
                  _buildInput(
                    controller: _phoneCtrl,
                    hint: '77XXXXXXX',
                    keyboardType: TextInputType.phone,
                    validator: (v) =>
                        v!.isEmpty ? 'هذا الحقل مطلوب' : null,
                  ),
                  const SizedBox(height: 16),

                  // مجال النشاط
                  _buildLabel('مجال النشاط التجاري', required: true),
                  const SizedBox(height: 6),
                  _buildDropdown(
                    value: _businessType,
                    items: _businessTypes,
                    onChanged: (v) => setState(() => _businessType = v!),
                  ),
                  const SizedBox(height: 16),

                  // المحافظة والمديرية
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('المحافظة', required: true),
                            const SizedBox(height: 6),
                            _buildDropdown(
                              value: _province.isEmpty ? null : _province,
                              hint: 'اختر المحافظة',
                              items: _provinces,
                              onChanged: (v) =>
                                  setState(() => _province = v ?? ''),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('المديرية'),
                            const SizedBox(height: 6),
                            _buildInput(
                              hint: 'المديرية...',
                              onChanged: (v) => _district = v,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // زر التسجيل
                  PrimaryButton(
                    text: 'ابدأ الاستخدام',
                    onPressed: _handleRegister,
                    isLoading: _isLoading,
                    icon: Icons.arrow_forward_ios,
                  ),

                  const SizedBox(height: 16),
                  Text(
                    'بياناتك محفوظة على جهازك فقط',
                    style: TextStyle(
                      color: AppColors.textSub,
                      fontSize: 12,
                      fontFamily: 'Cairo',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrand() {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.accentBlue, AppColors.accentGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentGreen.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Center(
            child: Text('📊', style: TextStyle(fontSize: 32)),
          ),
        ),
        const SizedBox(height: 14),
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              fontFamily: 'Cairo',
              color: AppColors.textMain,
              letterSpacing: -0.5,
            ),
            children: [
              TextSpan(text: 'محاسب'),
              TextSpan(
                text: 'ك',
                style: TextStyle(color: AppColors.accentMint),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'إدارة أسهل... حسابات أدق',
          style: TextStyle(
            color: AppColors.textSub,
            fontSize: 13,
            fontFamily: 'Cairo',
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text, {bool required = false}) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            color: AppColors.textSub,
            fontSize: 13,
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w600,
          ),
          children: required
              ? [
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(color: AppColors.accentRed),
                  )
                ]
              : [],
        ),
      ),
    );
  }

  Widget _buildInput({
    TextEditingController? controller,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      validator: validator,
      style: const TextStyle(color: AppColors.textMain, fontFamily: 'Cairo'),
      decoration: InputDecoration(hintText: hint),
    );
  }

  Widget _buildDropdown({
    required List<String> items,
    String? value,
    String? hint,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      dropdownColor: AppColors.cardSurface,
      style: const TextStyle(color: AppColors.textMain, fontFamily: 'Cairo'),
      decoration: InputDecoration(hintText: hint),
      items: items
          .map((e) => DropdownMenuItem(
                value: e,
                child: Text(e, style: const TextStyle(fontFamily: 'Cairo')),
              ))
          .toList(),
    );
  }
}
