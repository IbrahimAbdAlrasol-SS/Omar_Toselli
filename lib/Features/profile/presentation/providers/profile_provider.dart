import 'dart:async';
import 'package:Tosell/core/model_core/User.dart';
import 'package:Tosell/core/utils/helpers/SharedPreferencesHelper.dart';
import 'package:Tosell/features/profile/data/services/profile_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_provider.g.dart';

@riverpod
class profileNotifier extends _$profileNotifier {
  @override
  FutureOr<User> build() async {
    var user = await SharedPreferencesHelper.getUser() ?? User();
    return user;
  }

  FutureOr<(User?, String?)> updateUser({required User user}) async {
    ProfileService profileService = ProfileService();
    var result = await profileService.updateUser(user: user);
    return (result.$1, result.$2);
  }

  FutureOr<(User?, String?)> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    ProfileService profileService = ProfileService();
    var result = await profileService.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
    if (result.$2 != null) return (null, result.$2);
    return result;
  }
}