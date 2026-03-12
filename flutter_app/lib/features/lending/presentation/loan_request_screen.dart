import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../lending/data/loan_models.dart';
import '../../lending/logic/loan_providers.dart';

class LoanRequestScreen extends ConsumerStatefulWidget {
  const LoanRequestScreen({super.key});

  @override
  ConsumerState<LoanRequestScreen> createState() => _LoanRequestScreenState();
}

class _LoanRequestScreenState extends ConsumerState<LoanRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _borrowerContactCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _interestCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime? _dueDate;

  @override
  void dispose() {
    _borrowerContactCtrl.dispose();
    _amountCtrl.dispose();
    _interestCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 5)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a due date')),
      );
      return;
    }

    final amount = double.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid loan amount')),
      );
      return;
    }

    final interest = double.tryParse(_interestCtrl.text.trim()) ?? 0.0;

    final payload = CreateLoanPayload(
      // The backend will lookup the user name using contact, so we can ignore this field
      borrowerName: '',
      borrowerContact: _borrowerContactCtrl.text.trim(),
      amount: amount,
      interest: interest,
      dueDate: _dueDate!.toIso8601String().split('T').first,
      note: _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
    );

    final success = await ref.read(createLoanProvider.notifier).createLoan(payload);
    if (success && mounted) {
      ref.invalidate(outgoingLoanRequestsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Loan request sent successfully'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final createState = ref.watch(createLoanProvider);
    final isLoading = createState.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Send Loan Request')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Borrower Identity', style: AppTextStyles.headlineSmall),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Enter the Monetra registered phone number of the borrower.',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.neutralMid),
              ),
              const SizedBox(height: AppSpacing.xl),

              _FieldLabel(label: 'Phone Number (Required)'),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                controller: _borrowerContactCtrl,
                hint: 'e.g. +91 98765 43210',
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Phone number is required' : null,
              ),
              const SizedBox(height: AppSpacing.xl),

              Text('Loan Details', style: AppTextStyles.headlineSmall),
              const SizedBox(height: AppSpacing.base),

              _FieldLabel(label: 'Loan Amount (₹)'),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                controller: _amountCtrl,
                hint: 'e.g. 5000',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.next,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Amount is required';
                  final n = double.tryParse(v);
                  if (n == null || n <= 0) return 'Enter a valid amount';
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.base),

              _FieldLabel(label: 'Interest Rate (%) - Optional'),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                controller: _interestCtrl,
                hint: 'e.g. 5',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppSpacing.base),

              _FieldLabel(label: 'Due Date'),
              const SizedBox(height: AppSpacing.sm),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.base,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      color: _dueDate != null ? AppColors.primary : AppColors.divider,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 18,
                        color: _dueDate != null ? AppColors.primary : AppColors.neutralMid,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        _dueDate != null
                            ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'
                            : 'Select due date',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: _dueDate != null ? AppColors.neutralDark : AppColors.neutralLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.base),

              _FieldLabel(label: 'Note (optional)'),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                controller: _notesCtrl,
                hint: 'What is this request for?',
                maxLines: 3,
                minLines: 3,
                textInputAction: TextInputAction.done,
              ),

              if (createState.hasError) ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.errorSurface,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.error, size: 16),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          createState.error.toString(),
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.xxl),
              AppButton(
                label: 'Send Request',
                onPressed: _submit,
                isLoading: isLoading,
                prefixIcon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
              ),
              const SizedBox(height: AppSpacing.huge),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.titleSmall.copyWith(
        textBaseline: TextBaseline.alphabetic,
        letterSpacing: 0.3,
      ),
    );
  }
}
