import 'package:isar/isar.dart';
import 'package:to_read_list/model/status.dart';

part 'link.g.dart';

@collection
class Link {
  Id id = Isar.autoIncrement; // you can also use id = null to auto increment

  late String title;

  // TODO: 키워드 연결?
  // String? keywords;

  late String summary;

  late String url;

  late int createdDate;

  late String userUuid;

  @enumerated
  Status status = Status.unread;
}