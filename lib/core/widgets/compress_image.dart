import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

Future<File?> compressImage(File file, {int quality = 70}) async {
  final dir = await getTemporaryDirectory();
  final targetPath = path.join(dir.path, "compressed_${path.basename(file.path)}");

  final XFile? compressedXFile = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path,
    targetPath,
    quality: quality,
  );

  if (compressedXFile == null) return null;

  return File(compressedXFile.path);
}
