import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class FileDownloadPage extends StatefulWidget {
  final String fileUrl;  // URL from which to download
  String file_name;

  FileDownloadPage({required this.fileUrl,required this.file_name});

  @override
  _FileDownloadPageState createState() => _FileDownloadPageState();
}

class _FileDownloadPageState extends State<FileDownloadPage> {
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String? _fileName;

  Dio dio = Dio();


  // Request storage permissions (for Android)
  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      return result == PermissionStatus.granted;
    }
  }

  // Function to save the video with the fetched file name
  Future<bool> saveFile(String url, String fileName) async {
    Directory? directory;
    try {
      if (Platform.isAndroid) {
        if (await _requestPermission(Permission.manageExternalStorage)) {
          directory = await getExternalStorageDirectory();
          print("Directory: ${directory?.path}");
        } else {
          return false;
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory != null) {
        File saveFile = File("${directory.path}/$fileName");

        // Ensure the directory exists
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }

        if (await directory.exists()) {
          // Download and save the file
          await dio.download(url, saveFile.path, onReceiveProgress: (received, total) {
            if (total != -1) {
              print("=====>"+total.toString());
              setState(() {
                _downloadProgress = received / total;
              });
            }
          });
          print("File saved at: ${saveFile.path}");
          return true;
        }
      }
      return false;
    } catch (e) {
      print("Error saving file: $e");
      return false;
    }
  }

  // Function to start downloading the file
  Future<void> _downloadFile() async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    try {
      // Get the original filename from the header
      _fileName =widget.file_name;

      // Start the download and save file
      bool downloaded = await saveFile(widget.fileUrl, _fileName!);

      // Show a success or failure message
      if (downloaded) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Downloaded $_fileName successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed!')),
        );
      }
    } catch (e) {
      // Handle any errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download failed: $e')),
      );
    } finally {
      setState(() {
        _isDownloading = false;
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isDownloading)
              Column(
                children: [
                   Container(
                    margin: EdgeInsets.all(10),
                     child: LinearProgressIndicator(
                      value: _downloadProgress,
                      minHeight: 8.0,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                                       ),
                   ),
                  SizedBox(height: 10),
                  Text('downloaded'),
                ],
              )
            else
              Column(
                children: [
                  ElevatedButton(
                  onPressed: _downloadFile,
                  child: Text('Download File'),
                ),
                 ElevatedButton(
                  onPressed:() {
                    Navigator.pop(context);
                  },
                  child: Text('Close'),
                ),
                
                ]
              ),
          ],
    );
  }
}
