import 'dart:async';

import 'package:any_link_preview/any_link_preview.dart' as al;
import 'package:flutter/material.dart';
import 'package:flutter_sharing_intent/flutter_sharing_intent.dart';
import 'package:flutter_sharing_intent/model/sharing_file.dart';
import 'package:isar/isar.dart' as isar;
import 'package:to_read_list/model/model.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final isar.Isar? _isar;
  late StreamSubscription _intentDataStreamSubscription;

  final _dataList = <Link>[];

  @override
  void initState() {
    super.initState();
    _initializeStream();
    _initializeIsar().then(
      (_) => _getInitialShared(),
    );
  }

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              child: ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onLongPress: () async {
                        await _showDeleteDialog(index);
                      },
                      onTap: () async {
                        final url = _dataList[index].url;
                        await launchUrlString(url,
                            mode: LaunchMode.externalApplication);
                        await _changeEntityStatus(
                          link: _dataList[index],
                          status: Status.read,
                        );
                      },
                      child: Ink(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          foregroundDecoration: BoxDecoration(
                            color: _dataList[index].status == Status.read
                                ? const Color(0x5A000000)
                                : Colors.transparent,
                          ),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                          ),
                          child: IgnorePointer(
                            child: al.AnyLinkPreview.builder(
                              link: _dataList[index].url,
                              itemBuilder: (
                                BuildContext context,
                                al.Metadata meta,
                                ImageProvider<Object>? img,
                              ) {
                                return Row(
                                  children: [
                                    img != null
                                        ? Container(
                                            height: 50,
                                            width: 50,
                                            decoration: BoxDecoration(
                                              image:
                                                  DecorationImage(image: img),
                                            ),
                                          )
                                        : Container(
                                            height: 50,
                                            width: 50,
                                            color: Colors.grey,
                                          ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            meta.title ?? '',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            meta.desc ?? '',
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return Container(
                      height: 2,
                      color: Color(0xC0CCCCCC),
                    );
                  },
                  itemCount: _dataList.length),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteDialog(int index) async {
    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            height: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 20),
                const Text('해당 링크를 삭제하시겠습니까?'),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.maybePop(context);
                      },
                      child: Text('취소'),
                    ),
                    const SizedBox(width: 20),
                    TextButton(
                      onPressed: () async {
                        await _changeEntityStatus(
                          link: _dataList[index],
                          status: Status.deleted,
                        );

                        if (!mounted) {
                          return;
                        }
                        Navigator.maybePop(context);
                      },
                      child: Text('삭제'),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _changeEntityStatus({
    required Link link,
    required Status status,
  }) async {
    await _isar?.writeTxn(() async {
      await _isar?.links.put(link..status = status);
    });

    if (!mounted) {
      return;
    }

    _getDataFromDb();
  }

  Future<void> _initializeIsar() async {
    _isar = await isar.Isar.open([LinkSchema]);
  }

  Future<void> _initializeStream() async {
    _intentDataStreamSubscription = FlutterSharingIntent.instance
        .getMediaStream()
        .listen((List<SharedFile> value) async {
      final link = value.map((f) => f.value).join(",");

      if (link.isEmpty) {
        return;
      }

      final newLink = Link()
        ..url = link
        ..summary = ''
        ..status = Status.unread
        ..userUuid = ''
        ..title = ''
        ..createdDate = DateTime.now().millisecondsSinceEpoch;

      await _isar?.writeTxn(() async {
        await _isar?.links.put(newLink); // insert & update
      });

      await _getDataFromDb();
    }, onError: (err) {
      print("getIntentDataStream error: $err");
    });
  }

  Future<void> _getInitialShared() async {
    FlutterSharingIntent.instance.getInitialSharing().then((value) async {
      final link = value.map((f) => f.value).join(",");
      if (link.isEmpty) {
        return;
      }

      final newLink = Link()
        ..url = link
        ..summary = ''
        ..status = Status.unread
        ..userUuid = ''
        ..title = ''
        ..createdDate = DateTime.now().millisecondsSinceEpoch;

      await _isar?.writeTxn(() async {
        await _isar?.links.put(newLink); // insert & update
      });

      await _getDataFromDb();
    });
  }

  Future<void> _getDataFromDb() async {
    final datas = ((await _isar?.links
                .filter()
                .urlContains('http')
                .and()
                .statusLessThan(Status.deleted)
                .findAll()) ??
            [])
        .reversed;
    _dataList.clear();
    _dataList.addAll(datas);

    setState(() {});
  }
}
