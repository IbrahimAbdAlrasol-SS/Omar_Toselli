// lib/Features/auth/Services/auth_service.dart
import 'dart:async';
import 'package:Tosell/core/Model/auth/User.dart';
import 'package:Tosell/core/Client/BaseClient.dart';
import 'package:Tosell/core/Client/APIendpoint.dart';

class AuthService {
  final BaseClient<User> baseClient;

  AuthService()
      : baseClient = BaseClient<User>(fromJson: (json) => User.fromJson(json));
  Future<(User? data, String? error)> login(
      {String? phoneNumber, required String password}) async {
    try {
      var result =
          await baseClient.create(endpoint: AuthEndpoints.login, data: {
        'phoneNumber': phoneNumber,
        'password': password,
      });

      if (result.singleData == null) return (null, result.message);
      return (result.getSingle, null);
    } catch (e) {
      return (null, e.toString());
    }
  }

  /// ✅ دالة تسجيل التاجر مع التعامل الصحيح مع الاستجابة
  Future<(User? data, String? error)> register({
    required String fullName,
    required String brandName,
    required String userName,
    required String phoneNumber,
    required String password,
    required String brandImg, // ✅ يجب أن يكون URL من رفع الصورة
    required List<Map<String, dynamic>> zones,
    required int type,
  }) async {
    try {
      final isValidUrl =
          brandImg.startsWith('https://') || brandImg.startsWith('http://');

      if (!isValidUrl) {
        return (null, 'صورة المتجر لم يتم معالجتها بشكل صحيح');
      }
      if (zones.isEmpty) {
        return (null, 'يجب اختيار منطقة واحدة على الأقل');
      }

      for (int i = 0; i < zones.length; i++) {
        final zone = zones[i];
        print('   📍 المنطقة ${i + 1}:');
        print(
            '      - zoneId: ${zone['zoneId']} ${zone['zoneId'] != null && zone['zoneId'] > 0 ? '✅' : '❌'}');
        print(
            '      - nearestLandmark: "${zone['nearestLandmark']}" ${zone['nearestLandmark']?.toString().isNotEmpty == true ? '✅' : '❌'}');
        print('      - lat: ${zone['lat']} ${zone['lat'] != null ? '✅' : '❌'}');
        print(
            '      - long: ${zone['long']} ${zone['long'] != null ? '✅' : '❌'}');

        // ✅ التحقق من صحة بيانات المنطقة
        if (zone['zoneId'] == null || zone['zoneId'] <= 0) {
          print('❌ خطأ: zoneId غير صحيح في المنطقة ${i + 1}');
          return (null, 'معرف المنطقة غير صحيح');
        }

        if (zone['nearestLandmark'] == null ||
            zone['nearestLandmark'].toString().trim().isEmpty) {
          print('❌ خطأ: nearestLandmark فارغ في المنطقة ${i + 1}');
          return (null, 'أقرب نقطة دالة مطلوبة لكل منطقة');
        }

        if (zone['lat'] == null || zone['long'] == null) {
          print('❌ خطأ: إحداثيات ناقصة في المنطقة ${i + 1}');
          return (null, 'يجب تحديد الموقع على الخريطة لكل منطقة');
        }
      }

      // ✅ تدقيق النوع
      print('🏷️ التحقق من النوع:');
      print('   - type: $type');
      if (type != 1 && type != 2) {
        print('⚠️ تحذير: type = $type (مقبول لكن غير معتاد، المتوقع: 1 أو 2)');
      } else {
        print('   - المعنى: ${type == 1 ? 'مركز' : 'أطراف'} ✅');
      }

      // ✅ تحضير البيانات بالشكل المطلوب تماماً
      final requestData = {
        'merchantId': null, // ✅ null كما طلب
        'fullName': fullName,
        'brandName': brandName,
        'brandImg': brandImg, // ✅ URL من رفع الصورة
        'userName': userName,
        'phoneNumber': phoneNumber,
        'img': brandImg, // ✅ نفس brandImg كما مطلوب
        'zones': zones, // ✅ قائمة بالشكل المطلوب
        'password': password,
        'type': type, // ✅ نوع المنطقة
      };

      print('📤 البيانات النهائية المرسلة:');
      print('📋 JSON كامل:');
      print(requestData);

      // ✅ طباعة حجم البيانات للتأكد
      print('📏 إحصائيات:');
      print('   - حجم zones: ${zones.length} منطقة');
      print('   - طول brandImg: ${brandImg.length} حرف');
      print('   - طول fullName: ${fullName.length} حرف');
      print('   - طول brandName: ${brandName.length} حرف');

      // ✅ إرسال الطلب
      var result = await baseClient.create(
        endpoint: AuthEndpoints.register,
        data: requestData,
      );

      if (result.code == 200 && result.message == "Operation successful") {
        // ✅ إرجاع حالة خاصة للتمييز
        return (null, "REGISTRATION_SUCCESS_PENDING_APPROVAL");
      }

      User? user;
      if (result.singleData != null) {
        user = result.singleData;

        return (user, null);
      } else if (result.data != null && result.data!.isNotEmpty) {
        user = result.data!.first;

        return (user, null);
      }

      return (null, result.message ?? 'استجابة غير متوقعة من الخادم');
    } catch (e) {
      return (null, 'خطأ في التسجيل: ${e.toString()}');
    }
  }
}
