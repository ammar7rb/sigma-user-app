import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sixvalley_ecommerce/di_container.dart' as di;
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_sixvalley_ecommerce/features/profile/controllers/profile_contrroller.dart';

Future<void> changeCustomerProfileImage(BuildContext context) async {
  try {
    final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85);
    if (image == null || !context.mounted) return;
    if (await image.length() > 5 * 1024 * 1024) {
      throw StateError('اختر صورة أقل من 5 ميجابايت.');
    }
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final progress = ValueNotifier<double?>(null);
    if (!context.mounted) {
      progress.dispose();
      return;
    }
    showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => PopScope(
            canPop: false,
            child: AlertDialog(
                title: const Text('رفع صورة الملف الشخصي'),
                content: ValueListenableBuilder<double?>(
                    valueListenable: progress,
                    builder: (ctx, value, child) =>
                        Column(mainAxisSize: MainAxisSize.min, children: [
                          LinearProgressIndicator(value: value),
                          const SizedBox(height: 16),
                          Text(value == null
                              ? 'جاري الرفع'
                              : '${(value * 100).round()}%')
                        ])))));
    try {
      await di.sl<DioClient>().post('/api/v1/customer/profile-image',
          data: FormData.fromMap({
            'image':
                await MultipartFile.fromFile(image.path, filename: image.name)
          }), onSendProgress: (sent, total) {
        progress.value = total > 0 ? sent / total : null;
      });
      if (context.mounted) {
        await Provider.of<ProfileController>(context, listen: false)
            .getUserInfo(context);
      }
      messenger.showSnackBar(
          const SnackBar(content: Text('تم تحديث صورة الملف الشخصي.')));
    } finally {
      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
      progress.dispose();
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'تعذر تحديث الصورة. اختر صورة JPG أو PNG أو WebP أقل من 5 ميجابايت وأعد المحاولة.')));
    }
  }
}
