import 'dart:io';
import 'package:ctevt_solution/Result_sec/test/directory_path.dart';
import 'package:ctevt_solution/Login/Groups/helper/check_permission.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as Path;

class FileList extends StatefulWidget {
  FileList({Key? key}) : super(key: key);

  @override
  State<FileList> createState() => _FileListState();
}

class _FileListState extends State<FileList> {
  bool isPermission = false;
  var checkAllPermission = CheckPermission();
  checkPermission() async {
    var permission = await checkAllPermission.isStoragePermission();
    if (permission) {
      setState(() {
        isPermission = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    checkPermission();
  }

  final dataList = [
    {
      "id": "2",
      "title": "file Video 1",
      "url": "https://download.samplelib.com/mp4/sample-5s.mp4"
    },
    {
      "id": "3",
      "title": "file Video 2",
      "url": "https://download.samplelib.com/mp4/sample-10s.mp4"
    },
    {
      "id": "4",
      "title": "file Video 3",
      "url": "https://download.samplelib.com/mp4/sample-20s.mp4"
    },
    {
      "id": "5",
      "title": "file Video 4",
      "url": "https://download.samplelib.com/mp4/sample-20s.mp4"
    },
    {
      "id": "6",
      "title": "file PDF 6",
      "url": "https://www.irs.gov/pub/irs-pdf/p463.pdf"
    },
    {
      "id": "10",
      "title": "file PDF 7",
      "url": "https://www.irs.gov/pub/irs-pdf/p463.pdf"
    },
    {
      "id": "10",
      "title": "C++ Tutorial",
      "url": "https://www.irs.gov/pub/irs-pdf/p463.pdf"
    },
    {
      "id": "11",
      "title": "file PDF 9",
      "url": "https://www.irs.gov/pub/irs-pdf/p463.pdf"
    },
    {
      "id": "12",
      "title": "file PDF 10",
      "url": "https://www.irs.gov/pub/irs-pdf/p463.pdf"
    },
    {
      "id": "13",
      "title": "file PDF 12",
      "url": "https://www.irs.gov/pub/irs-pdf/p463.pdf"
    },
    {
      "id": "14",
      "title": "file PDF 11",
      "url": "https://www.irs.gov/pub/irs-pdf/p463.pdf"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isPermission
          ? ListView.builder(
              itemCount: dataList.length,
              itemBuilder: (BuildContext context, int index) {
                var data = dataList[index];
                return TileList(
                  fileUrl: data['url']!,
                  title: data['title']!,
                );
              },
            )
          : TextButton(
              onPressed: () {
                checkPermission();
              },
              child: const Center(
                child: Text("Permission issue"),
              ),
            ),
    );
  }
}

class TileList extends StatefulWidget {
  const TileList({Key? key, required this.fileUrl, required this.title})
      : super(key: key);
  final String fileUrl;
  final String title;

  @override
  State<TileList> createState() => _TileListState();
}

class _TileListState extends State<TileList> {
  bool dowloading = false;
  bool fileExists = false;
  double progress = 0;
  String fileName = "";
  late String filePath;
  late CancelToken cancelToken;

  var getPathFile = DirectoryPath();

  startDownload() async {
    cancelToken = CancelToken();
    var storePath = await getPathFile.getPath();
    filePath = '$storePath/$fileName';
    try {
      await Dio().download(widget.fileUrl, filePath,
          onReceiveProgress: (count, total) {
        setState(
          () {
            progress = (count / total);
          },
        );
        setState(() {
          dowloading = false;
          fileExists = true;
        });
      }, cancelToken: cancelToken);
    } catch (e) {
      setState(() {
        dowloading = false;
      });
    }
  }

  cancelDownload() {
    cancelToken.cancel();
    setState(() {
      dowloading = false;
    });
  }

  checkFileExit() async {
    var storePath = await getPathFile.getPath();
    filePath = '$storePath/$fileName';
    bool fileExistCheck = await File(filePath).exists();
    setState(() {
      fileExists = fileExistCheck;
    });
  }

  opernfile() {
    OpenFile.open(filePath);
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      fileName = Path.basename(widget.fileUrl);
    });
    checkFileExit();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      shadowColor: Colors.grey,
      child: ListTile(
        title: Text(widget.title),
        leading: IconButton(
          onPressed: () {
            fileExists && dowloading == false ? opernfile() : cancelDownload();
          },
          icon: fileExists && dowloading == false
              ? const Icon(
                  Icons.window,
                  color: Colors.green,
                )
              : const Icon(Icons.close),
        ),
        trailing: IconButton(
          onPressed: () {
            fileExists && dowloading == false ? opernfile() : startDownload();
          },
          icon: fileExists
              ? const Icon(
                  Icons.save,
                  color: Colors.green,
                )
              : dowloading
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 3,
                          backgroundColor: Colors.grey,
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                        Text(
                          "${(progress * 100).toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 12.0,
                          ),
                        ),
                      ],
                    )
                  : const Icon(Icons.download),
        ),
      ),
    );
  }
}
