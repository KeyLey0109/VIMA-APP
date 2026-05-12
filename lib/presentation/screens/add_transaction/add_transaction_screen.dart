import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/categories.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../blocs/transaction/transaction_bloc.dart';
import '../../blocs/transaction/transaction_event.dart';
import '../../blocs/transaction/transaction_state.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/premium_button.dart';
import '../../widgets/animated_rainbow.dart';
import 'add_transaction_image_helper.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _categoryController = TextEditingController();
  late final TransactionBloc _transactionBloc;
  late AnimationController _animController;

  final String _selectedCategory = AppCategories.categories.first.name;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  /// Platform-agnostic image state
  /// On mobile: imagePath is the file path
  /// On web: imagePath is a logical key (not a real file)
  String? _imageFilePath;

  @override
  void initState() {
    super.initState();
    _transactionBloc = sl<TransactionBloc>();
    _categoryController.text = _selectedCategory;
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _categoryController.dispose();
    _transactionBloc.close();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.borderRadiusLarge),
        ),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text('Chọn ảnh hóa đơn', style: AppTextStyles.heading3),
            const SizedBox(height: 20),
            Row(
              children: [
                // Camera option - hide on web if not supported
                if (!kIsWeb) ...[
                  Expanded(
                    child: _buildImageSourceOption(
                      icon: Icons.camera_alt_rounded,
                      label: 'Chụp ảnh',
                      color: AppColors.primary,
                      onTap: () async {
                        Navigator.pop(context);
                        final path = await pickImageFromCamera();
                        if (path != null) {
                          setState(() => _imageFilePath = path);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  child: _buildImageSourceOption(
                    icon: Icons.photo_library_rounded,
                    label: 'Thư viện',
                    color: AppColors.accent,
                    onTap: () async {
                      Navigator.pop(context);
                      final path = await pickImageFromGallery();
                      if (path != null) {
                        setState(() => _imageFilePath = path);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.body.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitTransaction() {
    if (_formKey.currentState!.validate()) {
      final amount = AppFormatters.parseCurrency(_amountController.text);
      final categoryText = _categoryController.text.trim();
      if (amount == null || amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng nhập số tiền hợp lệ')),
        );
        return;
      }

      if (categoryText.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng nhập nội dung chi tiêu')),
        );
        return;
      }

      final dateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final transaction = TransactionEntity(
        amount: amount,
        category: categoryText,
        dateTime: dateTime,
        imagePath: _imageFilePath,
      );

      // Robust focus dismissal for Web
      FocusManager.instance.primaryFocus?.unfocus();
      
      // Show immediate feedback that saving has started
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đang lưu chi tiêu...'),
          duration: Duration(milliseconds: 500),
        ),
      );
      
      _transactionBloc.add(AddTransaction(transaction));
    } else {
      // Show explicit error if validation fails
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập đầy đủ thông tin'),
          backgroundColor: AppColors.error,
        ),
      );
      HapticFeedback.vibrate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _transactionBloc,
      child: BlocListener<TransactionBloc, TransactionState>(
        listener: (context, state) async {
          if (state is TransactionAdded) {
            // Small delay to ensure keyboard is fully retracted and engine is stable
            await Future.delayed(const Duration(milliseconds: 100));
            if (context.mounted) {
              Navigator.pop(context, true);
            }
          } else if (state is TransactionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Thêm chi tiêu'),
            leading: IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: FadeTransition(
            opacity: _animController,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── Amount Input ────────────────
                    _buildAmountInput(),
                    const SizedBox(height: 32),

                    // ─── Category Selection ─────────
                    Row(
                      children: [
                        const Icon(Icons.category_rounded,
                            color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Text('Loại chi tiêu', style: AppTextStyles.heading3),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildCategoryInput(),
                    const SizedBox(height: 32),

                    // ─── Date & Time ────────────────
                    Row(
                      children: [
                        const Icon(Icons.event_note_rounded,
                            color: AppColors.accent, size: 20),
                        const SizedBox(width: 8),
                        Text('Ngày và giờ', style: AppTextStyles.heading3),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildDateTimePickers(),
                    const SizedBox(height: 32),

                    // ─── Receipt Image ──────────────
                    Row(
                      children: [
                        const Icon(Icons.camera_rounded,
                            color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Text('Ảnh hóa đơn', style: AppTextStyles.heading3),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildImagePicker(),
                    const SizedBox(height: 48),

                    // ─── Submit Button ──────────────
                    _buildSubmitButton(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountInput() {
    return Column(
      children: [
        Text(
          'SỐ TIỀN CHI TIÊU',
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 2.0,
            color: AppColors.accent,
          ),
        ),
        const SizedBox(height: 12),
        GlassCard(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
          borderRadius: 32,
          hasGlow: true,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              AnimatedRainbow(
                child: Text(
                  '₫',
                  style: AppTextStyles.amountLarge.copyWith(
                    fontSize: 28,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 50, maxWidth: 300),
                  child: AnimatedRainbow(
                    child: TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    autofocus: true,
                    style: AppTextStyles.amountHero.copyWith(
                      color: Colors.white,
                      height: 1.0,
                    ),
                    inputFormatters: [
                      CurrencyInputFormatter(),
                    ],
                    decoration: InputDecoration(
                      hintText: '0',
                      hintStyle: AppTextStyles.amountHero.copyWith(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                      filled: false,
                      errorStyle: const TextStyle(
                        color: AppColors.error,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submitTransaction(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập số tiền';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text Input for Description/Category
        TextFormField(
          controller: _categoryController,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : AppColors.primary,
          ),
          decoration: InputDecoration(
            hintText: 'VD: Ăn phở, Xăng xe, Mua áo...',
            hintStyle: AppTextStyles.body.copyWith(
              color: AppColors.textHint.withValues(alpha: 0.5),
            ),
            filled: true,
            fillColor: Theme.of(context).brightness == Brightness.dark
                ? AppColors.surfaceLight.withValues(alpha: 0.4)
                : Colors.grey.withValues(alpha: 0.1),
            prefixIcon: const Icon(Icons.edit_note_rounded, color: AppColors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          validator: (value) =>
              (value == null || value.trim().isEmpty) ? 'Vui lòng nhập nội dung' : null,
        ),
        const SizedBox(height: 16),
        
        // Quick Selection Labels
        Text(
          'GỢI Ý NHANH:',
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 9,
            letterSpacing: 1.0,
            color: AppColors.textHint,
          ),
        ),
        const SizedBox(height: 12),
        
        // Horizontal Recommendation List
        SizedBox(
          height: 48,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: AppCategories.categories.length,
            itemBuilder: (context, index) {
              final category = AppCategories.categories[index];
              final isMatch = _categoryController.text.trim() == category.name;
              
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _categoryController.text = category.name;
                    });
                    HapticFeedback.lightImpact();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isMatch 
                          ? category.color.withValues(alpha: 0.2)
                          : AppColors.surfaceLight.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isMatch ? category.color : Colors.white10,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          category.icon,
                          size: 16,
                          color: isMatch ? category.color : AppColors.textHint,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          category.name,
                          style: AppTextStyles.caption.copyWith(
                            color: isMatch ? Colors.white : AppColors.textSecondary,
                            fontWeight: isMatch ? FontWeight.w700 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimePickers() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius:
                    BorderRadius.circular(AppConstants.borderRadiusSmall),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    AppFormatters.formatDate(_selectedDate),
                    style: AppTextStyles.body,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: _pickTime,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius:
                    BorderRadius.circular(AppConstants.borderRadiusSmall),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time_rounded,
                      color: AppColors.accent, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    _selectedTime.format(context),
                    style: AppTextStyles.body,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePicker() {
    if (_imageFilePath != null) {
      return GlassCard(
        padding: EdgeInsets.zero,
        child: Stack(
          children: [
            // Show placeholder image on web, actual image on mobile
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius:
                    BorderRadius.circular(AppConstants.borderRadius),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: AppColors.success, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    'Ảnh đã được chọn',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (!kIsWeb) ...[
                    const SizedBox(height: 4),
                    ReceiptImagePreview(imagePath: _imageFilePath!),
                  ],
                ],
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                onTap: () => setState(() => _imageFilePath = null),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.delete_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return GlassCard(
      onTap: _showImageSourceDialog,
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border:
                  Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: const Icon(Icons.add_a_photo_rounded,
                color: AppColors.primary, size: 32),
          ),
          const SizedBox(height: 12),
          Text(
            kIsWeb ? 'Chọn ảnh hóa đơn' : 'Chụp hoặc chọn ảnh hóa đơn',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textHint,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        final isLoading = state is TransactionLoading;
        return PremiumButton(
          text: 'Lưu chi tiêu',
          icon: Icons.check_rounded,
          onTap: isLoading ? null : _submitTransaction,
          isLoading: isLoading,
          gradient: AppColors.accentGradient,
        );
      },
    );
  }
}
