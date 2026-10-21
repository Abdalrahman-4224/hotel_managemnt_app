import '../../domain/entities/campaign.dart';

/// Sample data from the design. Replace with an API data source.
class CampaignsLocalDataSource {
  const CampaignsLocalDataSource();

  List<Campaign> getCampaigns() => const [
    Campaign(
      id: '1043',
      name: 'وفد شركة الأفق',
      manager: 'سعد المطيري',
      phone: '0781 442 9010',
      rooms: ['201', '202', '301', '302', '303', '304', '305'],
      heads: 24,
      nights: 5,
      checkIn: '19/8/2026 · 13:20',
      checkOut: '24/8/2026 · 12:00',
      status: CampaignStatus.staying,
      priceBasis: 'على الشخص · 20 دولار / ليلة',
      document: 'كتاب رسمي · شركة الأفق',
      total: DualAmount('4,970', '6,450,000'),
      paid: DualAmount('3,200', '4,100,000'),
      due: DualAmount('1,770', '2,350,000'),
      paidPercent: 64,
      members: [
        CampaignMember('سعد المطيري · مسؤول الحملة', '301', '5', '100 \$'),
        CampaignMember('ماجد الدوسري', '302', '5', '130,000 د.ع'),
        CampaignMember('هند القحطاني', '304', '3', '+60 \$'),
        CampaignMember('نورة الشمري', '305', '5', '100 \$'),
      ],
      trail: [
        CampaignEvent(
          'أُنشئ حجز الحملة — 24 فرداً · 7 غرف',
          '18/8/2026 16:05 · مدير الفندق',
        ),
        CampaignEvent(
          'دفعة 3,200 دولار — تحويل',
          '19/8/2026 13:40 · فاطمة العزاوي',
        ),
        CampaignEvent(
          'نقل فردين من غرفة 303 إلى غرفة 305',
          '20/8/2026 09:15 · الاستقبال',
        ),
        CampaignEvent(
          'إضافة فرد منتصف الإقامة — غرفة 304',
          '21/8/2026 11:20 · الاستقبال',
        ),
      ],
    ),
    Campaign(
      id: '1051',
      name: 'وفد وزارة النقل',
      manager: 'أمين السرّاج',
      phone: '0770 118 2245',
      rooms: ['203', '204'],
      heads: 4,
      nights: 3,
      checkIn: '22/8/2026 · 14:00',
      checkOut: '25/8/2026 · 12:00',
      status: CampaignStatus.upcoming,
      priceBasis: 'على الغرفة · 240 دولار / ليلة',
      document: 'كتاب رسمي · وزارة النقل',
      total: DualAmount('1,440', '—'),
      paid: DualAmount('0', '—'),
      due: DualAmount('1,440', '—'),
      paidPercent: 0,
      members: [],
      trail: [
        CampaignEvent(
          'أُنشئ حجز الحملة — 4 أفراد · غرفتان',
          '20/8/2026 10:20 · مدير الفندق',
        ),
        CampaignEvent(
          'بلا دفعة — كامل عند الوصول',
          '20/8/2026 10:22 · مدير الفندق',
        ),
      ],
    ),
    Campaign(
      id: '1036',
      name: 'حملة مكتب الرافدين',
      manager: 'حيدر الموسوي',
      phone: '0751 907 3311',
      rooms: ['101', '103', '106'],
      heads: 6,
      nights: 4,
      checkIn: '12/8/2026 · 11:10',
      checkOut: '16/8/2026 · 12:00',
      status: CampaignStatus.departed,
      priceBasis: 'على الشخص · 25 دولار / ليلة',
      document: 'هوية مكتب الرافدين',
      total: DualAmount('—', '7,200,000'),
      paid: DualAmount('—', '7,200,000'),
      due: DualAmount('—', '0'),
      paidPercent: 100,
      members: [
        CampaignMember(
          'حيدر الموسوي · مسؤول الحملة',
          '106',
          '4',
          '1,200,000 د.ع',
        ),
        CampaignMember('زينب الحسني', '101', '4', '1,200,000 د.ع'),
      ],
      trail: [
        CampaignEvent(
          'أُنشئ حجز الحملة — 6 أفراد · 3 غرف',
          '11/8/2026 18:40 · مدير الفندق',
        ),
        CampaignEvent('تسوية كاملة ومغادرة', '16/8/2026 11:30 · يوسف الحلبي'),
      ],
    ),
  ];
}
