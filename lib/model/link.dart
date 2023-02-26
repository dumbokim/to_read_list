part 'link.g.dart';

@collection
class Link {
  Id id = Isar.autoIncrement; // you can also use id = null to auto increment

  @Index(type: IndexType.value)
  String? title;

  // TODO: 키워드 연결?
  // String? keywords;

  String? summary;

  String? url;

  @enumerated
  Status status = Status.unread;
}