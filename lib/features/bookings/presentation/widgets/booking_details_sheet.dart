import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/booking_quote.dart';
import '../../domain/repositories/bookings_repository.dart'
    show BookingPartlySaved;
import '../../../dashboard/presentation/controllers/dashboard_controller.dart';
import '../../../rooms/presentation/controllers/floors_controller.dart';
import '../controllers/add_booking_controller.dart';
import '../controllers/bookings_controller.dart';

/// Step 2 of adding a booking: guest details, payment and pricing.
/// Resolves to true when the booking was created.
Future<bool?> showBookingDetails(
  BuildContext context,
  AddBookingController controller,
) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.sheet,
    barrierColor: AppColors.scrim,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.r28)),
    ),
    builder: (ctx) => FractionallySizedBox(
      heightFactor: .92,
      child: _BookingDetails(controller: controller),
    ),
  );
}

class _BookingDetails extends ConsumerStatefulWidget {
  const _BookingDetails({required this.controller});

  final AddBookingController controller;

  @override
  ConsumerState<_BookingDetails> createState() => _BookingDetailsState();
}

class _BookingDetailsState extends ConsumerState<_BookingDetails> {
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
                  AppSpacing.s18,
                  AppSpacing.s16,
                  AppSpacing.s18,
                  AppSpacing.s20 + MediaQuery.viewInsetsOf(context).bottom,
                ),
                children: [
                  if (c.isGroup) ...[
                    NzTextField(
                      label: 'اسم الحملة / الجهة',
                      hint: 'شركة الأفق للسفر',
                      controller: c.groupName,
                      style: AppText.body(16),
                    ),
                    SizedBox(height: AppSpacing.s16),
                  ],
                  NzTextField(
                    label: c.isGroup ? 'اسم مسؤول الحملة' : 'اسم النزيل',
                    hint: 'سعد المطيري',
                    controller: c.guestName,
                    style: AppText.body(16),
                  ),
                  SizedBox(height: AppSpacing.s16),
                  NzTextField(
                    label: 'رقم الهوية / الجواز',
                    hint: 'A1234567',
                    controller: c.nationalId,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.right,
                    style: AppText.num(16, weight: FontWeight.w500),
                  ),
                  SizedBox(height: AppSpacing.s16),
                  NzTextField(
                    label: c.isGroup ? 'هاتف مسؤول الحملة' : 'رقم الهاتف',
                    hint: '07700000000',
                    controller: c.phone,
                    keyboardType: TextInputType.phone,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.right,
                    style: AppText.num(16, weight: FontWeight.w500),
                  ),
                  SizedBox(height: AppSpacing.s16),
                  Row(
                    children: [
                      Expanded(
                        child: _DateField(
                          label: 'تاريخ الدخول',
                          value: c.checkIn,
                          // Yesterday too, for a guest who arrived after midnight.
                          firstDate: DateUtils.dateOnly(DateTime.now())
                              .subtract(const Duration(days: 1)),
                          onPicked: (d) => c.setDates(checkIn: d),
                        ),
                      ),
                      SizedBox(width: AppSpacing.s10),
                      Expanded(
                        child: _DateField(
                          label: 'تاريخ الخروج',
                          value: c.checkOut,
                          firstDate: c.checkIn.add(const Duration(days: 1)),
                          onPicked: (d) => c.setDates(checkOut: d),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.s16),
                  _peopleStepper(),
                  SizedBox(height: AppSpacing.s16),
                  _seg<int>(
                    'نظام الوجبات',
                    const [NzSegment(0, 'مع إفطار'), NzSegment(1, 'بدون')],
                    c.mealIncluded,
                    (v) => c.set(() => c.mealIncluded = v),
                  ),
                  // Taking money needs FINANCE_CREATE; without it the whole
                  // amount is due on checkout and there is nothing to choose.
                  if (c.canRecordPayment) ...[
                    SizedBox(height: AppSpacing.s16),
                    _seg<int>(
                      'طريقة الدفع',
                      const [NzSegment(0, 'نقداً'), NzSegment(1, 'بطاقة')],
                      c.payByCard,
                      (v) => c.set(() => c.payByCard = v),
                    ),
                    SizedBox(height: AppSpacing.s16),
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
                  ],
                  SizedBox(height: AppSpacing.s16),
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
                  SizedBox(height: AppSpacing.s16),
                  _usdCard(q),
                  SizedBox(height: AppSpacing.s16),
                  _iqdCard(),
                  SizedBox(height: AppSpacing.s16),
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

  Future<void> _confirm() async {
    final problem = c.validate();
    if (problem != null) {
      showNzToast(context, problem);
      return;
    }
    final router = GoRouter.of(context);
    final navigator = Navigator.of(context);
    String? partly;
    try {
      await c.confirm();
    } on BookingPartlySaved catch (error) {
      // Some of it is saved: close the form so it can't be sent twice, and
      // open the bookings list where the rest can be finished.
      partly = error.message;
    } catch (error) {
      if (mounted) showNzToast(context, errorText(error));
      return;
    }
    // The new booking changes the lists and the room map.
    ref.invalidate(bookingsControllerProvider);
    ref.invalidate(floorsControllerProvider);
    ref.invalidate(dashboardProvider);
    if (mounted) showNzToast(context, partly ?? 'تم تأكيد الحجز');
    navigator.pop(true);
    router.go(partly == null ? AppRoutes.home : AppRoutes.bookings);
  }

  Widget _header() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.s18,
        AppSpacing.s10,
        AppSpacing.s18,
        AppSpacing.s14,
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.line)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40.r,
              height: 5.r,
              decoration: BoxDecoration(
                color: AppColors.grabber,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.s10),
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
                size: 40.r,
                radius: AppRadius.r12,
                iconSize: 17.r,
                iconColor: AppColors.inkMuted,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.s10),
          Wrap(
            spacing: AppSpacing.s6,
            runSpacing: AppSpacing.s6,
            children: [
              for (final n in c.selected)
                Container(
                  height: 30.r,
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.s12),
                  decoration: BoxDecoration(
                    color: AppColors.goldTint,
                    borderRadius: BorderRadius.circular(AppRadius.full),
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
      radius: AppRadius.r16,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.s14,
        vertical: AppSpacing.s12,
      ),
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
            width: 44.r,
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
        SizedBox(height: 7.r),
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
    double? height,
  }) {
    final fieldHeight = height ?? 50.r;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: AppText.body(12.5, color: AppColors.inkMuted)),
        SizedBox(height: AppSpacing.s6),
        NzTextField(
          controller: controller,
          hint: hint,
          height: fieldHeight,
          radius: AppRadius.r14,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.right,
          style: AppText.num(fieldHeight < 50.r ? 16 : 17),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _usdCard(BookingQuote q) {
    return NzCard(
      padding: EdgeInsets.all(AppSpacing.s14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: _CardLabel('دولار')),
              Container(
                height: 24.r,
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.s10),
                decoration: BoxDecoration(
                  color: AppColors.goldTint,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                alignment: Alignment.center,
                child: Text(
                  'السعر يُحدَّد لهذا الحجز',
                  style: AppText.body(12, color: AppColors.goldDarkest),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.s12),
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
              SizedBox(width: AppSpacing.s10),
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
      padding: EdgeInsets.all(AppSpacing.s14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CardLabel('دينار'),
          SizedBox(height: AppSpacing.s12),
          Row(
            children: [
              Expanded(child: _moneyField(rateLabel, hint: '—')),
              SizedBox(width: AppSpacing.s10),
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
      padding: EdgeInsets.all(AppSpacing.s14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CardLabel('الحساب والخصم · دولار'),
          SizedBox(height: AppSpacing.s12),
          line(
            c.basis == PriceBasis.perPerson
                ? 'الأشخاص × الليالي'
                : 'الغرف × الليالي',
            '${q.units} × ${q.nights}',
          ),
          SizedBox(height: AppSpacing.s12),
          line('قبل الخصم', fmtNum(q.gross)),
          SizedBox(height: AppSpacing.s12),
          rule,
          SizedBox(height: AppSpacing.s12),
          Text('الخصم', style: AppText.body(13, color: AppColors.inkMuted)),
          SizedBox(height: AppSpacing.s12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: Row(
              children: [
                for (final (i, o) in c.discountOptions.indexed) ...[
                  if (i > 0) SizedBox(width: AppSpacing.s8),
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
            SizedBox(height: AppSpacing.s12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: _moneyField(
                    c.discountLabel,
                    controller: _discount,
                    height: 48.r,
                    onChanged: (v) => c.set(() => c.discountValue = _digits(v)),
                  ),
                ),
                SizedBox(width: AppSpacing.s10),
                Expanded(
                  child: _Readout(
                    label: 'قيمة الخصم',
                    value: q.discountAmount > 0
                        ? '−${fmtNum(q.discountAmount)}'
                        : '0',
                    height: 48.r,
                    highlight: true,
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: AppSpacing.s12),
          rule,
          SizedBox(height: AppSpacing.s12),
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
          SizedBox(height: AppSpacing.s12),
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
        AppSpacing.s18,
        AppSpacing.s12,
        AppSpacing.s18,
        30.r + MediaQuery.paddingOf(context).bottom,
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
              height: 54.r,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          SizedBox(width: AppSpacing.s10),
          Expanded(
            flex: 2,
            child: NzPrimaryButton(
              label: c.isSaving ? 'جارٍ الحفظ...' : 'تأكيد الحجز',
              icon: LucideIcons.check,
              weight: FontWeight.w500,
              disabled: c.isSaving,
              onPressed: _confirm,
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
    this._height,
    this.highlight = false,
  });

  final String label;
  final String value;
  final double? _height;
  double get height => _height ?? 50.r;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: AppText.body(12.5, color: AppColors.inkMuted)),
        SizedBox(height: AppSpacing.s6),
        Container(
          height: height,
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.s12),
          decoration: BoxDecoration(
            color: highlight ? AppColors.goldTint : AppColors.paper,
            borderRadius: BorderRadius.circular(AppRadius.r14),
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
    required this.firstDate,
    required this.onPicked,
  });

  static final _fmt = DateFormat('yyyy/MM/dd', 'en_US');

  final String label;
  final DateTime value;

  /// The earliest day the picker offers. The latest is two years on from
  /// whichever is later, today or [value], so the range never runs out.
  final DateTime firstDate;
  final ValueChanged<DateTime> onPicked;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: AppText.body(13, color: AppColors.inkMuted)),
        SizedBox(height: 7.r),
        GestureDetector(
          onTap: () async {
            final today = DateUtils.dateOnly(DateTime.now());
            final from = value.isBefore(firstDate) ? value : firstDate;
            final last = (value.isAfter(today) ? value : today).add(
              const Duration(days: 731),
            );
            final d = await showDatePicker(
              context: context,
              initialDate: value,
              firstDate: from,
              lastDate: last,
            );
            if (d != null) onPicked(d);
          },
          child: Container(
            height: 52.r,
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.s12),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppRadius.r16),
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
                SizedBox(width: AppSpacing.s8),
                Icon(
                  LucideIcons.calendar,
                  size: 16.r,
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
