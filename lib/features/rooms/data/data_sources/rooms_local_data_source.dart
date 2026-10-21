import '../../domain/entities/room.dart';

const _f = RoomStatus.free;
const _b = RoomStatus.busy;
const _h = RoomStatus.held;
const _o = RoomStatus.maintenance;

const _single = ('مفردة', 'سرير مفرد');
const _double = ('مزدوجة', 'سريران');
const _triple = ('ثلاثية', 'ثلاثة أسرّة');
const _suite = ('جناح', 'غرفتان + صالة');

Room _r(String no, RoomStatus s, (String, String) kind, String view) =>
    Room(no, s, kind.$1, kind.$2, view);

/// Sample data from the design. Replace with an API data source.
class RoomsLocalDataSource {
  const RoomsLocalDataSource();

  List<Floor> getFloors() => [
    Floor('الطابق الأول', [
      _r('101', _f, _single, 'إطلالة داخلية'),
      _r('102', _b, _double, 'إطلالة شارع'),
      _r('103', _f, _single, 'إطلالة داخلية'),
      _r('104', _h, _double, 'إطلالة شارع'),
      _r('105', _o, _double, 'إطلالة داخلية'),
      _r('106', _f, _suite, 'إطلالة زاوية'),
      _r('107', _f, _double, 'إطلالة شارع'),
      _r('108', _b, _double, 'إطلالة شارع'),
      _r('109', _f, _single, 'إطلالة داخلية'),
      _r('110', _b, _double, 'إطلالة داخلية'),
      _r('111', _f, _triple, 'إطلالة شارع'),
      _r('112', _f, _double, 'إطلالة داخلية'),
      _r('113', _o, _single, 'إطلالة داخلية'),
      _r('114', _b, _double, 'إطلالة شارع'),
      _r('115', _f, _double, 'إطلالة شارع'),
      _r('116', _h, _triple, 'إطلالة داخلية'),
      _r('117', _f, _single, 'إطلالة داخلية'),
      _r('118', _f, _suite, 'إطلالة زاوية'),
    ]),
    Floor('الطابق الثاني', [
      _r('201', _b, _double, 'إطلالة شارع'),
      _r('202', _b, _double, 'إطلالة شارع'),
      _r('203', _f, _double, 'إطلالة شارع'),
      _r('204', _f, _double, 'إطلالة داخلية'),
      _r('205', _o, _single, 'إطلالة داخلية'),
      _r('206', _b, _triple, 'إطلالة شارع'),
    ]),
    Floor('الطابق الثالث', [
      _r('301', _b, _triple, 'إطلالة شارع'),
      _r('302', _b, _triple, 'إطلالة شارع'),
      _r('303', _b, _triple, 'إطلالة داخلية'),
      _r('304', _f, _double, 'إطلالة داخلية'),
      _r('305', _f, _suite, 'إطلالة بانورامية'),
      _r('306', _f, _single, 'إطلالة داخلية'),
    ]),
  ];
}
