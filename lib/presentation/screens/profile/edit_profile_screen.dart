import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../widgets/animated_rainbow.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/premium_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _displayNameController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    final state = context.read<AuthBloc>().state;
    if (state is Authenticated) {
      _displayNameController.text = state.user.displayName ?? '';
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _saveDisplayName() {
    final newName = _displayNameController.text.trim();
    if (newName.isEmpty) {
      _showSnackBar('Tên hiển thị không được để trống', isError: true);
      return;
    }
    context.read<AuthBloc>().add(UpdateUserRequested(displayName: newName));
  }

  void _changePassword() {
    final current = _currentPasswordController.text;
    final newPass = _newPasswordController.text;
    final confirm = _confirmPasswordController.text;

    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      _showSnackBar('Vui lòng điền đầy đủ thông tin', isError: true);
      return;
    }
    if (newPass.length < 6) {
      _showSnackBar('Mật khẩu mới phải có ít nhất 6 ký tự', isError: true);
      return;
    }
    if (newPass != confirm) {
      _showSnackBar('Mật khẩu xác nhận không khớp', isError: true);
      return;
    }
    if (current == newPass) {
      _showSnackBar('Mật khẩu mới phải khác mật khẩu hiện tại', isError: true);
      return;
    }

    context.read<AuthBloc>().add(ChangePasswordRequested(
          currentPassword: current,
          newPassword: newPass,
        ));
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is ProfileUpdated) {
          _showSnackBar('Cập nhật thông tin thành công!');
        } else if (state is PasswordChanged) {
          _showSnackBar('Đổi mật khẩu thành công!');
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
        } else if (state is AuthError) {
          _showSnackBar(state.message, isError: true);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: AnimatedRainbow(
            child: Text(
              'THÔNG TIN CÁ NHÂN',
              style: AppTextStyles.heading3.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // ─── Account Info ────────────────────────
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  String username = '';
                  String createdAt = '';
                  if (state is Authenticated) {
                    username = state.user.username;
                    createdAt =
                        '${state.user.createdAt.day}/${state.user.createdAt.month}/${state.user.createdAt.year}';
                  }
                  return GlassCard(
                    padding: const EdgeInsets.all(20),
                    borderRadius: 20,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            color: AppColors.accent,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tên đăng nhập',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textHint,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                username,
                                style: AppTextStyles.subtitle.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tham gia: $createdAt',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textHint,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // ─── Display Name Section ───────────────
              _buildSectionTitle('TÊN HIỂN THỊ'),
              const SizedBox(height: 12),
              GlassCard(
                padding: const EdgeInsets.all(20),
                borderRadius: 20,
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _displayNameController,
                      label: 'Tên hiển thị',
                      icon: Icons.badge_rounded,
                      hint: 'Nhập tên hiển thị mới',
                    ),
                    const SizedBox(height: 16),
                    PremiumButton(
                      text: 'Lưu tên hiển thị',
                      icon: Icons.save_rounded,
                      onTap: _saveDisplayName,
                      height: 48,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ─── Change Password Section ────────────
              _buildSectionTitle('ĐỔI MẬT KHẨU'),
              const SizedBox(height: 12),
              GlassCard(
                padding: const EdgeInsets.all(20),
                borderRadius: 20,
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _currentPasswordController,
                      label: 'Mật khẩu hiện tại',
                      icon: Icons.lock_outline_rounded,
                      hint: 'Nhập mật khẩu hiện tại',
                      isPassword: true,
                      obscure: _obscureCurrent,
                      onToggleObscure: () =>
                          setState(() => _obscureCurrent = !_obscureCurrent),
                    ),
                    const SizedBox(height: 14),
                    _buildTextField(
                      controller: _newPasswordController,
                      label: 'Mật khẩu mới',
                      icon: Icons.lock_rounded,
                      hint: 'Nhập mật khẩu mới (tối thiểu 6 ký tự)',
                      isPassword: true,
                      obscure: _obscureNew,
                      onToggleObscure: () =>
                          setState(() => _obscureNew = !_obscureNew),
                    ),
                    const SizedBox(height: 14),
                    _buildTextField(
                      controller: _confirmPasswordController,
                      label: 'Xác nhận mật khẩu',
                      icon: Icons.lock_rounded,
                      hint: 'Nhập lại mật khẩu mới',
                      isPassword: true,
                      obscure: _obscureConfirm,
                      onToggleObscure: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                    const SizedBox(height: 20),
                    PremiumButton(
                      text: 'Đổi mật khẩu',
                      icon: Icons.vpn_key_rounded,
                      onTap: _changePassword,
                      height: 48,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.brand,
                          AppColors.brand.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.caption.copyWith(
        letterSpacing: 1.5,
        fontWeight: FontWeight.w700,
        color: AppColors.textHint,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onToggleObscure,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.accent.withValues(alpha: 0.15),
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword && obscure,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.body.copyWith(
                color: AppColors.textHint.withValues(alpha: 0.5),
              ),
              prefixIcon: Icon(icon, color: AppColors.accent, size: 20),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        obscure
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: AppColors.textHint,
                        size: 20,
                      ),
                      onPressed: onToggleObscure,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
