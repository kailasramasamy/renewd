import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_opacity.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/currency.dart';
import '../utils/exchange_rate.dart';

/// Shows a USD → user's currency converter below the amount field.
/// Hidden if user's default currency is USD.
class CurrencyConverter extends StatefulWidget {
  final TextEditingController amountController;

  const CurrencyConverter({super.key, required this.amountController});

  @override
  State<CurrencyConverter> createState() => _CurrencyConverterState();
}

class _CurrencyConverterState extends State<CurrencyConverter> {
  bool _showConverter = false;
  bool _isLoading = false;
  double? _rate;
  final _usdController = TextEditingController();

  String get _userCurrency => RenewdCurrency.userCurrency;
  String get _userSymbol => RenewdCurrency.symbol;

  Future<void> _fetchRate() async {
    setState(() => _isLoading = true);
    _rate = await ExchangeRate.usdTo(_userCurrency);
    setState(() => _isLoading = false);
  }

  void _onUsdChanged(String value) {
    final usd = double.tryParse(value);
    if (usd != null && _rate != null) {
      final converted = ExchangeRate.convert(usd, _rate!);
      widget.amountController.text = converted.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _usdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Don't show converter if user's currency is already USD
    if (_userCurrency == 'USD') return const SizedBox.shrink();

    if (!_showConverter) {
      return GestureDetector(
        onTap: () {
          setState(() => _showConverter = true);
          _fetchRate();
        },
        child: Padding(
          padding: const EdgeInsets.only(top: RenewdSpacing.xs),
          child: Text(
            'Convert from USD',
            style: RenewdTextStyles.caption
                .copyWith(color: RenewdColors.oceanBlue),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: RenewdSpacing.sm),
      padding: const EdgeInsets.all(RenewdSpacing.md),
      decoration: BoxDecoration(
        color: RenewdColors.oceanBlue.withValues(alpha: RenewdOpacity.subtle),
        borderRadius: RenewdRadius.mdAll,
        border: Border.all(
          color: RenewdColors.oceanBlue.withValues(alpha: RenewdOpacity.light),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('USD \u2192 $_userCurrency',
                  style: RenewdTextStyles.caption.copyWith(
                    color: RenewdColors.oceanBlue,
                    fontWeight: FontWeight.w600,
                  )),
              const Spacer(),
              if (_rate != null)
                Text('1 USD = $_userSymbol${_rate!.toStringAsFixed(2)}',
                    style: RenewdTextStyles.caption
                        .copyWith(color: RenewdColors.slate)),
              const SizedBox(width: RenewdSpacing.sm),
              GestureDetector(
                onTap: () => setState(() => _showConverter = false),
                child: Icon(Icons.close,
                    size: 16, color: RenewdColors.slate),
              ),
            ],
          ),
          const SizedBox(height: RenewdSpacing.sm),
          if (_isLoading)
            const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Row(
              children: [
                Text('\$ ',
                    style: RenewdTextStyles.body
                        .copyWith(color: RenewdColors.oceanBlue)),
                Expanded(
                  child: TextField(
                    controller: _usdController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: _onUsdChanged,
                    style: RenewdTextStyles.body,
                    decoration: InputDecoration(
                      hintText: 'Enter USD amount',
                      hintStyle: RenewdTextStyles.bodySmall
                          .copyWith(color: RenewdColors.slate),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: RenewdSpacing.md,
                        vertical: RenewdSpacing.sm,
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
