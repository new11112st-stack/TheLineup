// خدمة ضغط الصور — لرفع إشعارات التحويل
import 'dart:convert';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageService {
  /// ضغط صورة إلى base64 data URL صالح لـ Firestore
  static Future<String?> compressToDataUrl(File file) async {
    try {
      // نضغط بأبعاد مختلفة حتى نحصل على حجم مناسب (< 380KB)
      const steps = [
        (820, 72),
        (640, 55),
        (480, 42),
        (380, 32),
      ];

      for (final (maxDim, quality) in steps) {
        final result = await FlutterImageCompress.compressWithFile(
          file.path,
          minWidth: maxDim,
          minHeight: maxDim,
          quality: quality,
          format: CompressFormat.jpeg,
        );

        if (result == null) continue;

        final base64 = base64Encode(result);
        if (base64.length <= 380000) {
          return 'data:image/jpeg;base64,$base64';
        }
      }

      // كحل أخير: نعيد آخر نتيجة بغض النظر عن الحجم
      final lastResult = await FlutterImageCompress.compressWithFile(
        file.path,
        minWidth: 380,
        minHeight: 380,
        quality: 25,
        format: CompressFormat.jpeg,
      );
      if (lastResult != null) {
        return 'data:image/jpeg;base64,${base64Encode(lastResult)}';
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
