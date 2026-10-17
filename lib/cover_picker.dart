// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;

/// يفتح نافذة اختيار صورة من الجهاز، ثم يقصّها بنسبة 3:4 ويصغّرها ويضغطها
/// ويعيدها كنص (data URL) جاهز للحفظ مع القصة. يعيد null إذا أُلغي الاختيار.
Future<String?> pickCoverImage() {
  const outW = 300, outH = 400;
  final done = Completer<String?>();
  final input = html.FileUploadInputElement()..accept = 'image/*';

  input.onChange.listen((_) {
    final file = input.files?.isNotEmpty == true ? input.files!.first : null;
    if (file == null) {
      done.complete(null);
      return;
    }
    if (file.size > 15 * 1024 * 1024) {
      done.completeError('حجم الصورة كبير جداً (الحد 15 ميجابايت).');
      return;
    }
    final reader = html.FileReader();
    reader.onError.listen((_) => done.completeError('تعذّرت قراءة الصورة.'));
    reader.onLoad.listen((_) {
      final img = html.ImageElement(src: reader.result as String);
      img.onError.listen((_) => done.completeError('الملف ليس صورة صالحة.'));
      img.onLoad.listen((_) {
        final w = img.naturalWidth.toDouble(), h = img.naturalHeight.toDouble();
        if (w <= 0 || h <= 0) {
          done.completeError('الملف ليس صورة صالحة.');
          return;
        }
        // قصّ من المنتصف بنسبة 3:4
        double sx = 0, sy = 0, sw = w, sh = h;
        if (w / h > outW / outH) {
          sw = h * outW / outH;
          sx = (w - sw) / 2;
        } else {
          sh = w * outH / outW;
          sy = (h - sh) / 2;
        }
        final canvas = html.CanvasElement(width: outW, height: outH);
        final ctx = canvas.context2D;
        ctx.fillStyle = '#ffffff';
        ctx.fillRect(0, 0, outW, outH);
        ctx.drawImageScaledFromSource(img, sx, sy, sw, sh, 0, 0, outW, outH);
        done.complete(canvas.toDataUrl('image/jpeg', 0.8));
      });
    });
    reader.readAsDataUrl(file);
  });

  input.click();
  return done.future;
}
