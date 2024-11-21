import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:math';

import './download.dart';

class Download_ui extends StatefulWidget {
  final String url;

  Download_ui({required this.url});

  @override
  State<Download_ui> createState() => _Download_uiState();
}

class _Download_uiState extends State<Download_ui> {
  Map<String, List<String>>? file_details;
  int? total_size;

  @override
  void initState() {
    super.initState();
    _fetch_file_details();
  }

  // Fetch file details asynchronously
  Future<void> _fetch_file_details() async {
    print('Fetching file details from: ${widget.url}');

    try {
      Response response = await Dio().get('${widget.url}/file_details');
      print('Response: ${response.data}');

      // Ensure the response data is correctly formatted
      if (response.data != null && response.data is Map) {
        var data = response.data as Map<String, dynamic>;

        setState(() {
          // Safely cast the 'total' value
          total_size = int.tryParse(data['total']?.first ?? '0') ?? 0;
          
          // Safely cast file details to Map<String, List<String>>
          file_details = {};
          data.forEach((key, value) {
            if (value is List) {
              // Ensuring the value is of type List<String> (or at least convertible to that)
              List<String> fileData = List<String>.from(value.map((item) => item.toString()));
              if (key != 'total') {
                file_details![key] = fileData;
              }
            }
          });
        });
      } else {
        print('Invalid response format');
      }
    } catch (e) {
      print('Error fetching file details: $e');
    }
  }

  String formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    int i = (log(bytes) / log(1024)).floor();
    double size = bytes / pow(1024, i);
    return "${size.toStringAsFixed(decimals)} ${suffixes[i]}";
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(title: Text('Share_Free')),
      body: Center(
        child: file_details == null
            ? CircularProgressIndicator() // Show loading spinner
            : Column(
                children: [
                  // Display total size
                  Container(
                    width: width,
                    height: 0.12 * height,
                    alignment: Alignment.center, // Centers the text
                    decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 116, 153, 218)),
                    child: Text(
                      '${formatBytes(total_size!, 2)}',
                      style: TextStyle(
                          fontSize: 28,
                          color: const Color.fromARGB(255, 242, 243, 243)),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Display list of files
                  Expanded(
                    child: ListView(
                      children: file_details!.entries.map((entry) {
                        return InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                content: SizedBox(
                                  width: 300,
                                  height: 200,
                                  child: FileDownloadPage(
                                    fileUrl:
                                        '${widget.url}/files/${entry.key}',
                                    file_name: entry.value[1],
                                  ),
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: 0.9 * width,
                            margin: EdgeInsets.all(10),
                            height: 0.08 * height,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(3, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // File name display
                                Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(10, 0, 0, 0),
                                    child: Text(
                                      entry.value[1],
                                      style: TextStyle(fontSize: 16),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ),

                                // File size display
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    formatBytes(
                                        int.parse(entry.value[0]), 2),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),

                                // Close button
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                  child: IconButton(
                                    icon: Icon(Icons.close),
                                    onPressed: () {
                                      setState(() {
                                        file_details!.remove(entry.key);
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
