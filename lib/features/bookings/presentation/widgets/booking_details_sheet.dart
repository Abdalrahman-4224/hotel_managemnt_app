import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/booking_quote.dart';
import '../controllers/add_booking_controller.dart';

/// Step 2 of adding a booking: guest details, payment and pricing.
Future<void> showBookingDetails(
  BuildContext context,
  AddBookingController controller,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.sheet,
    barrierColor: AppColors.scrim,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (ctx) => FractionallySizedBox(
      heightFactor: .92,
      child: _BookingDetails(controller: controller),
    ),
  );
}

class _BookingDetails extends StatefulWidget {
  const _BookingDetails({required this.controller});

  final AddBookingController controller;

  @override
  State<_BookingDetails> createState() => _BookingDetailsState();
}

class _BookingDetailsState extends State<_BookingDetails> {
  AddBookingController get c => widget.controller;
  late final _rate = TextEditingController(text: '${c.rate}');
  late final _discount = TextEditingController(text: '${c.discountValue}');

  @override
  void dispose() {
    _rate.dispose();
    _discount.dispose();
    super.dispose();
  }

  int _digits(String s) => int.tryParse(s.replaceAll(RegExp(r'\D'), '')) ?? 0;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: c,
      builder: (context, _) {
        final q = c.quote;
        return Column(
          children: [
            _header(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  18,
                  16,
                  18,
                  20 + MediaQuery.viewInsetsOf(context).bottom,
                ),
                children: [
                  NzTextField(
                    label: c.isGroup ? 'اسم الحملة / الجهة' : 'اسم النزيل',
                    hint: c.isGroup ? 'شركة الأفق للسفر' : 'سعد المطيري',
                    style: AppText.body(16),
                  ),
                  const SizedBox(height: 16),
                  NzTextField(
                    label: c.isGroup
                        ? 'هاتف مسؤول الحملة'
                        : 'رقم الهوية / الجواز أو الهاتف',
                    hint: '07700000000',
                    keyboardType: TextInputType.number,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.right,
                    style: AppText.num(16, weight: FontWeight.w500),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _DateField(
                          label: 'تاريخ الدخول',
                          value: c.checkIn,
                          onPicked: (d) => c.setDates(checkIn: d),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _DateField(
                          label: 'تاريخ الخروج',
                          value: c.checkOut,
                          onPicked: (d) => c.setDates(checkOut: d),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _peopleStepper(),
                  const SizedBox(height: 16),
                  _seg<int>(
                    'نظام الوجبات',
                    const [NzSegment(0, 'مع إفطار'), NzSegment(1, 'بدون')],
                    c.mealIncluded,
                    (v) => c.set(() => c.mealIncluded = v),
                  ),
                  const SizedBox(height: 16),
                  _seg<int>(
                    'طريقة الدفع',
                    const [NzSegment(0, 'نقداً'), NzSegment(1, 'بطاقة')],
                    c.payByCard,
                    (v) => c.set(() => c.payByCard = v),
                  ),
                  const SizedBox(height: 16),
                  _seg<PaymentTiming>(
                    'توقيت الدفع',
                    const [
                      NzSegment(PaymentTiming.fullNow, 'كامل الآن'),
                      NzSegment(PaymentTiming.depositNow, 'دفعة الآن'),
                      NzSegment(PaymentTiming.onCheckout, 'عند المغادرة'),
                    ],
                    c.timing,
                    (v) => c.set(() => c.timing = v),
                    fontSize: 13,
                  ),
                  const SizedBox(height: 16),
                  _seg<PriceBasis>(
                    'أساس حساب السعر',
                    const [
                      NzSegment(PriceBasis.perRoom, 'على الغرفة'),
                      NzSegment(PriceBasis.perPerson, 'على الشخص'),
                    ],
                    c.basis,
                    (v) {
                      c.set(() {
                        c.basis = v;
                        c.discount = DiscountType.none;
                        c.discountValue = 0;
                      });
                      _rate.text = '${c.rate}';
                    },
                  ),
                  const SizedBox(height: 16),
                  _usdCard(q),
                  const SizedBox(height: 16),
                  _iqdCard(),
                  const SizedBox(height: 16),
                  _calcCard(q),
                ],
              ),
            ),
            _footer(context),
          ],
        );
      },
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.line)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.grabber,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الخطوة 2 من 2',
                      style: AppText.body(12.5, color: AppColors.inkMuted),
                    ),
                    Text(c.kindLabel, style: AppText.display(21)),
                  ],
                ),
              ),
              NzIconButton(
                icon: LucideIcons.x,
                tooltip: 'إغلاق',
                size: 40,
                radius: 12,
                iconSize: 17,
                iconColor: AppColors.inkMuted,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final n in c.selected)
                Container(
                  height: 30,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.goldTint,
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(color: AppColors.goldBorder),
                  ),
                  child: Center(
                    widthFactor: 1,
                    child: Text(
                      n,
                      style: AppText.num(
                        14,
                        color: AppColors.goldDarkest,
                        height: 1,
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

  Widget _peopleStepper() {
    return NzCard(
      radius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.isGroup ? 'عدد أفراد الحملة' : 'عدد الأشخاص',
                  style: AppText.body(14.5, weight: FontWeight.w500),
                ),
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: 'الليالي: '),
                      TextSpan(
                        text: '${c.nights}',
                        style: AppText.num(12.5, color: AppColors.ink),
                      ),
                    ],
                  ),
                  style: AppText.body(12.5, color: AppColors.inkMuted),
                ),
              ],
            ),
          ),
          NzStepButton(
            label: '−',
            tooltip: 'إنقاص',
            onTap: () => c.changeHeads(-1),
          ),
          SizedBox(
            width: 44,
            child: Text(
              '${c.heads}',
              textAlign: TextAlign.center,
              style: AppText.num(20, height: 1),
            ),
          ),
          NzStepButton(
            label: '+',
            tooltip: 'زيادة',
            dark: true,
            onTap: () => c.changeHeads(1),
          ),
        ],
      ),
    );
  }

  Widget _seg<T>(
    String label,
    List<NzSegment<T>> segs,
    T value,
    ValueChanged<T> onChanged, {
    double fontSize = 14.5,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: AppText.body(13, color: AppColors.inkMuted)),
        const SizedBox(height: 7),
        NzSegmented<T>(
          segments: segs,
          selected: value,
          onChanged: onChanged,
          fontSize: fontSize,
        ),
      ],
    );
  }

  Widget _moneyField(
    String label, {
    TextEditingController? controller,
    String? hint,
    ValueChanged<String>? onChanged,
    double height = 50,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: AppText.body(12.5, color: AppColors.inkMuted)),
        const SizedBox(height: 6),
        NzTextField(
          controller: controller,
          hint: hint,
          height: height,
          radius: 14,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.right,
          style: AppText.num(height < 50 ? 16 : 17),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _usdCard(BookingQuote q) {
    return NzCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: _CardLabel('دولار')),
              Container(
                height: 24,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: AppColors.goldTint,
                  borderRadius: BorderRadius.circular(99),
                ),
                alignment: Alignment.center,
                child: Text(
                  'السعر يُحدَّد لهذا الحجز',
                  style: AppText.body(12, color: AppColors.goldDarkest),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: _moneyField(
                  c.basis == PriceBasis.perPerson
                      ? 'سعر الليلة للشخص'
                      : 'سعر الليلة للغرفة',
                  controller: _rate,
                  onChanged: (v) => c.setRate(_digits(v)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Readout(
                  label: 'المستلم الآن',
                  value: fmtNum(q.receivedNow),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _iqdCard() {
    final rateLabel = c.basis == PriceBasis.perPerson
        ? 'سعر الليلة للشخص'
        : 'سعر الليلة للغرفة';
    return NzCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CardLabel('دينار'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _moneyField(rateLabel, hint: '—')),
              const SizedBox(width: 10),
              Expanded(child: _moneyField('المستلم الآن', hint: '—')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _calcCard(BookingQuote q) {
    Widget line(String k, String v, {Color color = AppColors.ink}) => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(k, style: AppText.body(14, color: AppColors.inkMuted)),
        Text(
          v,
          textDirection: TextDirection.ltr,
          style: AppText.num(15, color: color, height: 1),
        ),
      ],
    );
    const rule = NzDivider(color: AppColors.lineStrong);
    return NzCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CardLabel('الحساب والخصم · دولار'),
          const SizedBox(height: 12),
          line(
            c.basis == PriceBasis.perPerson
                ? 'الأشخاص × الليالي'
                : 'الغرف × الليالي',
            '${q.units} × ${q.nights}',
          ),
          const SizedBox(height: 12),
          line('قبل الخصم', fmtNum(q.gross)),
          const SizedBox(height: 12),
          rule,
          const SizedBox(height: 12),
          Text('الخصم', style: AppText.body(13, color: AppColors.inkMuted)),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: Row(
              children: [
                for (final (i, o) in c.discountOptions.indexed) ...[
                  if (i > 0) const SizedBox(width: 8),
                  NzChoicePill(
                    label: o.label,
                    selected: c.discount == o.type,
                    onTap: () {
                      c.pickDiscount(o);
                      _discount.text = '${o.defaultValue}';
                    },
                  ),
                ],
              ],
            ),
          ),
          if (c.discount != DiscountType.none) ...[
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: _moneyField(
                    c.discountLabel,
                    controller: _discount,
                    height: 48,
                    onChanged: (v) => c.set(() => c.discountValue = _digits(v)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _Readout(
                    label: 'قيمة الخصم',
                    value: q.discountAmount > 0
                        ? '−${fmtNum(q.discountAmount)}'
                        : '0',
                    height: 48,
                    highlight: true,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          rule,
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'الصافي بعد الخصم',
                style: AppText.body(14.5, weight: FontWeight.w500),
              ),
              Text(fmtNum(q.total), style: AppText.num(22, height: 1)),
            ],
          ),
          const SizedBox(height: 12),
          line(
            'يُستوفى عند المغادرة',
            fmtNum(q.dueOnCheckout),
            color: AppColors.goldDeep,
          ),
        ],
      ),
    );
  }

  Widget _footer(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        18,
        12,
        18,
        30 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.sheet,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: Row(
        children: [
          Expanded(
            child: NzOutlineButton(
              label: 'رجوع',
              height: 54,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: NzPrimaryButton(
              label: 'تأكيد الحجز',
              icon: LucideIcons.check,
              weight: FontWeight.w500,
              onPressed: () {
                final router = GoRouter.of(context);
                showNzToast(context, 'تم تأكيد الحجز');
                Navigator.of(context).pop();
                router.go(AppRoutes.home);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CardLabel extends StatelessWidget {
  const _CardLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: AppText.body(
      13,
      weight: FontWeight.w600,
      color: AppColors.goldDeep,
      height: 1,
    ),
  );
}

/// Read-only computed value styled like an input.
class _Readout extends StatelessWidget {
  const _Readout({
    required this.label,
    required this.value,
    this.height = 50,
    this.highlight = false,
  });

  final String label;
  final String value;
  final double height;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: AppText.body(12.5, color: AppColors.inkMuted)),
        const SizedBox(height: 6),
        Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: highlight ? AppColors.goldTint : AppColors.paper,
            borderRadius: BorderRadius.circular(14),
            border: highlight ? null : Border.all(color: AppColors.line),
          ),
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            value,
            textDirection: TextDirection.ltr,
            style: AppText.num(
              highlight ? 16 : 17,
              color: highlight ? AppColors.goldDarkest : AppColors.ink,
            ),
          ),
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onPicked,
  });

  static final _fmt = DateFormat('yyyy/MM/dd', 'en_US');

  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onPicked;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: AppText.body(13, color: AppColors.inkMuted)),
        const SizedBox(height: 7),
        GestureDetector(
          onTap: () async {
            final d = await showDatePicker(
              context: context,
              initialDate: value,
              firstDate: DateTime(2024),
              lastDate: DateTime(2030),
            );
            if (d != null) onPicked(d);
          },
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.lineStrong),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _fmt.format(value),
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.right,
                    style: AppText.num(15, weight: FontWeight.w500),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  LucideIcons.calendar,
                  size: 16,
                  color: AppColors.goldDeep,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
