import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/invoice.dart';

/// The invoice rendered as a sheet of paper.
class InvoicePaper extends StatelessWidget {
  const InvoicePaper({super.key, required this.invoice});

  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    final inv = invoice;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D1C1B19),
            offset: Offset(0, 2),
            blurRadius: 6,
          ),
          BoxShadow(
            color: Color(0x591C1B19),
            offset: Offset(0, 24),
            blurRadius: 50,
            spreadRadius: -28,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _letterhead(inv),
          const SizedBox(height: 18),
          _guestBox(inv),
          const SizedBox(height: 18),
          _LinesTable(lines: inv.lines),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(child: _Total('الإجمالي · دولار', inv.totalUsd)),
              const SizedBox(width: 10),
              Expanded(
                child: _Total('الإجمالي · دينار', inv.totalIqd, end: true),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _payments(inv),
          const SizedBox(height: 18),
          Text(
            'تُدفع كل عملة على حدة — لا تحويل بين الدولار والدينار.\nالموظف: ${inv.staff}',
            textAlign: TextAlign.center,
            style: AppText.body(11.5, color: AppColors.inkFaint, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _letterhead(Invoice inv) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const NzBrandMark(size: 30, radius: 10),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(inv.hotelName, style: AppText.display(18)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                inv.hotelAddress,
                style: AppText.body(12.5, color: AppColors.inkMuted),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'رقم الفاتورة',
              style: AppText.body(11.5, color: AppColors.inkMuted),
            ),
            Text(inv.number, style: AppText.num(20, height: 1.2)),
            Text(
              inv.issuedOn,
              style: AppText.num(
                12,
                weight: FontWeight.w500,
                color: AppColors.inkMuted,
                height: 1.4,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _guestBox(Invoice inv) {
    Widget cell(String k, Widget v) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(k, style: AppText.body(11.5, color: AppColors.inkMuted)),
        v,
      ],
    );
    final numStyle = AppText.num(13, weight: FontWeight.w500, height: 1.5);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: cell(
                  'النزيل',
                  Text(
                    inv.guest,
                    style: AppText.body(14, weight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: cell(
                  'الغرفة',
                  Text(inv.room, style: AppText.num(14, height: 1.5)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: cell('الدخول', Text(inv.checkIn, style: numStyle)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: cell('الخروج', Text(inv.checkOut, style: numStyle)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _payments(Invoice inv) {
    return CustomPaint(
      painter: _DashedTopBorder(),
      child: Padding(
        padding: const EdgeInsets.only(top: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'الدفعات',
              style: AppText.body(
                12.5,
                weight: FontWeight.w600,
                color: AppColors.ink3,
              ),
            ),
            for (final p in inv.payments) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    p.description,
                    style: AppText.body(13, color: AppColors.inkMuted),
                  ),
                  Text(p.amount, style: AppText.num(13, height: 1)),
                ],
              ),
            ],
            if (inv.paidInFull) ...[
              const SizedBox(height: 12),
              Container(
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.goldTint,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      LucideIcons.check,
                      size: 15,
                      color: AppColors.goldDeep,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'مسدّدة بالكامل',
                      style: AppText.body(
                        13,
                        weight: FontWeight.w600,
                        color: AppColors.goldDarkest,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LinesTable extends StatelessWidget {
  const _LinesTable({required this.lines});

  final List<InvoiceLine> lines;

  @override
  Widget build(BuildContext context) {
    final head = AppText.body(
      12,
      weight: FontWeight.w600,
      color: AppColors.inkMuted,
      height: 1,
    );
    final num = AppText.num(13.5, height: 1);
    final dash = AppText.num(13.5, color: AppColors.inkFaint, height: 1);

    Widget row(List<Widget> cells) => Row(
      children: [
        Expanded(flex: 5, child: cells[0]),
        Expanded(flex: 2, child: cells[1]),
        Expanded(flex: 3, child: cells[2]),
        Expanded(flex: 3, child: cells[3]),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(height: 2, color: AppColors.ink),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: row([
            Text('البيان', style: head),
            Text('الكمية', style: head, textAlign: TextAlign.center),
            Text('دولار', style: head, textAlign: TextAlign.end),
            Text('دينار', style: head, textAlign: TextAlign.end),
          ]),
        ),
        const NzDivider(color: AppColors.lineStrong),
        for (var i = 0; i < lines.length; i++) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: row([
              Text(lines[i].description, style: AppText.body(13.5)),
              Text(
                '${lines[i].quantity}',
                style: num,
                textAlign: TextAlign.center,
              ),
              Text(
                lines[i].usd ?? '—',
                style: lines[i].usd == null ? dash : num,
                textAlign: TextAlign.end,
              ),
              Text(
                lines[i].iqd ?? '—',
                style: lines[i].iqd == null ? dash : num,
                textAlign: TextAlign.end,
              ),
            ]),
          ),
          i == lines.length - 1
              ? Container(height: 2, color: AppColors.ink)
              : const NzDivider(),
        ],
      ],
    );
  }
}

class _Total extends StatelessWidget {
  const _Total(this.label, this.value, {this.end = false});

  final String label;
  final String value;
  final bool end;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: end
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.body(12.5, color: AppColors.inkMuted)),
        const SizedBox(height: 4),
        Text(value, style: AppText.num(28, height: 1.1)),
      ],
    );
  }
}

class _DashedTopBorder extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = AppColors.lineStrong
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 7) {
      canvas.drawLine(Offset(x, 0), Offset(x + 4, 0), p);
    }
  }

  @override
  bool shouldRepaint(_DashedTopBorder oldDelegate) => false;
}
