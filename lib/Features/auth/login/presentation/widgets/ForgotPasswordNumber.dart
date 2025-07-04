import 'package:Tosell/core/utils/extensions/extensions.dart';
import 'package:Tosell/core/widgets/Others/CustomAppBar.dart';
import 'package:Tosell/core/widgets/buttons/FillButton.dart';
import 'package:Tosell/core/widgets/inputs/CustomTextFormField.dart';
import 'package:Tosell/features/auth/login/data/provider/auth_provider.dart'
    show authNotifierProvider;
import 'package:Tosell/features/auth/registration/presentation/widgets/build_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ForgotPasswordNum extends ConsumerStatefulWidget {
  final String PageTitle;

  const ForgotPasswordNum({super.key, required this.PageTitle});

  @override
  ConsumerState<ForgotPasswordNum> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<ForgotPasswordNum> {
  final TextEditingController _phoneOrUsernameController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final bool isKeyboardVisible = keyboardHeight > 0;
    final loginState = ref.watch(authNotifierProvider);

    // loginState.when(
    //   initial: () {},
    //   loading: () {},
    //   success: (token) {
    //     context.pop();
    //     GlobalToast.show(
    //         message: "تم تسجيل الدخول بنجاح",
    //         backgroundColor: Colors.green,
    //         textColor: Colors.white);
    //     Future.microtask(() =>
    //         ref.read(userProfileControllerProvider.notifier).getUserProfile());
    //   },
    //   error: (failure) {
    //     print(failure.message);
    //   },
    // );

// رتبــها
    return loginState.when(
      data: (data) =>
          _buildUi(screenHeight, keyboardHeight, context, loginState),
      loading: () =>
          _buildUi(screenHeight, keyboardHeight, context, loginState),
      error: (error, stackTrace) => Center(
        child: Text(error.toString()),
      ),
    );
  }

  Widget _buildUi(double screenHeight, double keyboardHeight,
      BuildContext context, AsyncValue<void> loginState) {
    return Scaffold(
      body: Stack(
        children: [
          // Positioned Widget
          Column(
            children: [
              Expanded(
                child: buildBackground(
                  context: context,
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // محاذاة النصوص لليمين
                    children: [
                      const Gap(25),
                      const CustomAppBar(
                        title: "نسيان كلمة السر",
                        showBackButton: true,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: SvgPicture.asset("assets/svg/Logo.svg"),
                      ),
                      const Gap(16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          "أنشاء كلمة سر جديدة",
                          textAlign: TextAlign.right, // محاذاة النص لليمين
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 32,
                            color: const Color(
                                0xFFFBFAFF), // Surface color from light theme
                          ),
                        ),
                      ),
                      const Gap(8),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          "لا تقلق، فقط قم باتباع بعض الخطوات و سيتم تعيين كلمة سر جديدة و العودة الى حسابك بأمان.",
                          textAlign: TextAlign.right, // محاذاة النص لليمين
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            color: const Color(
                                0xFFFBFAFF), // Surface color from light theme
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // DraggableScrollableSheet for the bottom section
          DraggableScrollableSheet(
            initialChildSize: 0.66, // 69% of the screen height
            minChildSize: 0.66, // Minimum 69%
            maxChildSize: 0.66, // Maximum 90%
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color:
                      const Color(0xFFFBFAFF), // Surface color from light theme
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: CustomTextFormField(
                            label: "رقم الهاتف ",
                            hint: "07xx Xxx Xxx",
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                        const Gap(430),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              child: FillButton(
                                label: "ارسال رمز الـأكيد",
                                width: double.infinity,
                                height: 48,
                                onPressed: () {
                                  //setState(() {});
                                },
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/*
                          Padding(
                          padding: EdgeInsets.only(bottom: 20),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(),
                            child: FillButton(
                              label: "ارسال رمز الـأكيد",
                              width: 415,
                              height: 50,
                              onPressed: () {
                                //setState(() {});
                              },
                            ),
                          ),
                        ),
*/
