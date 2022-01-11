import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class ImageConversion {
  static Image imageFromBase64String(String base64String) {
    return Image.memory(
      base64Decode(base64String),
      fit: BoxFit.fill,
    );
  }

  static Uint8List dataFromBase64String(String base64String) {
    return base64Decode(base64String);
  }

  static String base64String(Uint8List data) {
    return base64Encode(data);
  }

  static Future<File> getImageFromBase64(String base64) async {
    Random random = Random();
    final decodedBytes = base64Decode(base64);
    final directory = await getApplicationDocumentsDirectory();
    var fileImg = File('${directory.path}/${random.nextInt(12000)}.png');
    print(fileImg.path);
    fileImg.writeAsBytesSync(List.from(decodedBytes));
    return fileImg;
  }
}
