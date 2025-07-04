// lib/Features/auth/auth_service.dart
import 'dart:async';
import 'package:Tosell/core/api/client/BaseClient.dart';
import 'package:Tosell/core/api/endpoints/APIendpoint.dart';
import 'package:Tosell/core/model_core/User.dart';
import 'package:Tosell/features/auth/pending_activation/data/services/activation_timer_service.dart';

class AuthService {
  final BaseClient<User> baseClient;

  AuthService()
      : baseClient = BaseClient<User>(fromJson: (json) => User.fromJson(json));

  Future<(User? data, String? error)> login({
    String? phoneNumber, 
    required String password
  }) async {
    try {
      var result = await baseClient.create(
        endpoint: AuthEndpoints.login, 
        data: {
          'phoneNumber': phoneNumber,
          'password': password,
        }
      );

      print('🔐 Auth Service - Login Response:');
      print('  - Has Single Data: ${result.singleData != null}');
      print('  - Has List Data: ${result.data?.isNotEmpty ?? false}');
      print('  - Message: ${result.message}');

      if (result.singleData != null) {
        final user = result.singleData!;
        
        print('👤 User Info:');
        print('  - Username: ${user.userName}');
        print('  - Type: ${user.type}');
        print('  - Is Active: ${user.isActive}');
        
        if (user.isActive == false) {
          print('⚠️ Account is not active - returning ACCOUNT_PENDING_ACTIVATION');
          return (user, "ACCOUNT_PENDING_ACTIVATION");
        }
        
        print('✅ Login successful - account is active');
        return (user, null);
      }
      
      print('❌ No user data in response');
      return (null, result.message ?? 'فشل تسجيل الدخول');
    } catch (e) {
      print('💥 Login Exception: $e');
      return (null, e.toString());
    }
  }

  Future<(User? data, String? error)> register({
    required String fullName,
    required String brandName,
    required String userName,
    required String phoneNumber,
    required String password,
    required String brandImg,
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

      print('🏷️ التحقق من النوع:');
      print('   - type: $type');
      if (type != 1 && type != 2) {
        print('⚠️ تحذير: type = $type (مقبول لكن غير معتاد، المتوقع: 1 أو 2)');
      } else {
        print('   - المعنى: ${type == 1 ? 'مركز' : 'أطراف'} ✅');
      }

      final requestData = {
        'merchantId': null,
        'fullName': fullName,
        'brandName': brandName,
        'brandImg': brandImg,
        'userName': userName,
        'phoneNumber': phoneNumber,
        'img': brandImg,
        'zones': zones,
        'password': password,
        'type': type,
      };

      print('📤 البيانات النهائية المرسلة:');
      print('📋 JSON كامل:');
      print(requestData);

      print('📏 إحصائيات:');
      print('   - حجم zones: ${zones.length} منطقة');
      print('   - طول brandImg: ${brandImg.length} حرف');
      print('   - طول fullName: ${fullName.length} حرف');
      print('   - طول brandName: ${brandName.length} حرف');

      var result = await baseClient.create(
        endpoint: AuthEndpoints.register,
        data: requestData,
      );

      if (result.code == 200 && result.message == "Operation successful") {
        // ✅ حفظ وقت التسجيل عند نجاح التسجيل
        await ActivationTimerService.saveRegistrationTime(DateTime.now());
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

  // ✅ إضافة دالة التواصل مع الدعم
  Future<(bool success, String? error)> contactSupport({
    required String message,
    String? phoneNumber,
  }) async {
    try {
      final result = await baseClient.create(
        endpoint: AuthEndpoints.contactSupport,
        data: {
          'message': message,
          'phoneNumber': phoneNumber,
          'type': 'activation_inquiry',
        },
      );
      
      if (result.code == 200) {
        return (true, null);
      }
      
      return (false, result.message ?? 'فشل في إرسال الرسالة');
    } catch (e) {
      return (false, e.toString());
    }
  }
}