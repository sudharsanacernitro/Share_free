import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart' as shelf_router;
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';

import './qr_code_gen.dart';
import './ip.dart';

class FileHostingPage extends StatefulWidget {
  @override
  _FileHostingPageState createState() => _FileHostingPageState();
}

class _FileHostingPageState extends State<FileHostingPage> {
  List<String>? _filePaths;
  bool _serverStatus = false;
  HttpServer? _server;
  String? data = "https://www.example.com"; // The data you want to encode
  String? ip;
  Map<String, List<String>> file_size_info = {};
  Map<String, String> file_paths = {};

  @override
  void initState() {
    super.initState();
    _initialize(); // Call the async function
  }

  Future<void> _initialize() async {
    ip = await getPrivateIpAddress();
  }

  // Function to pick multiple files using File Picker
  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);

      if (result != null) {
        int total_size = 0;
        setState(() {
          _filePaths = result.paths.whereType<String>().toList();
          file_size_info = {};

          for (int i = 0; i < _filePaths!.length; i++) {
            String filePath = _filePaths![i];

            if (filePath.isNotEmpty) {
              try {
                total_size += File(filePath).lengthSync();
                String sanitizedFileName = sanitizeFileName(filePath.split('/').last);
                file_size_info[i.toString()] = [File(filePath).lengthSync().toString(),sanitizedFileName];
                file_paths[i.toString()] = filePath;

              } catch (e) {
                print("Error fetching file size for $filePath: $e");
              }
            }
          }
          file_size_info['total'] = [total_size.toString()];
          data = "http://${ip}:8080";
        });
        print(file_size_info);
      } else {
        print("No files picked.");
      }
    } catch (e) {
      print("Error in file picking: $e");
    }
  }

  // Function to start the Shelf server
  Future<void> _startServer() async {
    if (_server != null) {
      setState(() {
        _serverStatus = true;
      });
      print("Server is already running on port 8080");
      return;
    }

    if (_filePaths == null || _filePaths!.isEmpty) {
      setState(() {
        _serverStatus = true;
      });
      return;
    }

    final router = shelf_router.Router();

    // Serve the file when the route is accessed
    router.get('/files/<id>', (Request request, String id) async {
      dynamic file = File(file_paths[id]!);

      if (!await file.exists() || !_serverStatus) {
        return Response.notFound('File not found');
      }

      String fileName = file_paths[id]!.split('/').last;
      final mimeType = _getMimeType(fileName);

      // Serve the file
      return Response.ok(
        file.openRead(),
        headers: {
          'Content-Type': mimeType,
          'Content-Disposition': 'attachment; filename="$fileName"',
        },
      );
    });

    router.get('/file_details', (Request request) async {
      if (!_serverStatus) {
        return Response.notFound('File not found');
      }
      return Response.ok(
        jsonEncode(file_size_info),
        headers: {
          'Content-Type': 'application/json',
        },
      );
    });

    final handler = const Pipeline().addMiddleware(logRequests()).addHandler(router);

    // Start the server with shared flag set to true
    _server = await shelf_io.serve(
      handler,
      '0.0.0.0',
      8080,
      shared: true,
    );

    setState(() {
      _serverStatus = true;
    });
    print("Server started at http://${ip}:8080");
  }

  String _getMimeType(String fileName) {
    if (fileName.endsWith('.zip')) return 'application/zip';
    if (fileName.endsWith('.pdf')) return 'application/pdf';
    if (fileName.endsWith('.jpg') || fileName.endsWith('.jpeg')) return 'image/jpeg';
    if (fileName.endsWith('.png')) return 'image/png';
    if (fileName.endsWith('.txt')) return 'text/plain';
    return 'application/octet-stream'; // Default MIME type for unknown files
  }

  // Function to stop the server
  Future<void> _stopServer() async {
    if (_server != null) {
      await _server?.close(force: true);
      setState(() {
        _server = null;
        _serverStatus = false;
      });
      print("Server stopped");
    }
  }

String sanitizeFileName(String fileName) {
  return fileName
      .replaceAll(RegExp(r'[^\w\-. ]'), '_') // Replace invalid characters with underscores
      .replaceAll(' ', '_'); // Optionally replace spaces with underscores
}

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('Share Free', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 100, 95, 95),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 2,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      QrImageView(
                        data: data!,
                        version: QrVersions.auto,
                        size: 200.0,
                        gapless: false,
                      ),
                      SizedBox(height: 20),
                      Text(data!, style: TextStyle(fontSize: 16)),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _pickFiles,
                        child: Text('Pick files'),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: _startServer,
                            child: Text(
                              'Start Server',
                              style: TextStyle(color: _serverStatus ? Colors.green : Colors.red),
                            ),
                          ),
                          SizedBox(width: 20),
                          ElevatedButton(
                            onPressed: _stopServer,
                            child: Text('Stop Server'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                if (_filePaths != null && _filePaths!.isNotEmpty)
                  ..._filePaths!.map(
                    (filePath) => Container(
                      width: .9 * screenWidth,
                      height: .08 * screenHeight,
                      margin: EdgeInsets.all(7),
                      padding: EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 2,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          filePath.split('/').last,
                          style: const TextStyle(fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ).toList()
                else
                  const Text('No files selected', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
