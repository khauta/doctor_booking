import 'package:auto_route/auto_route.dart';
import 'package:doctor_booking_flutter/app/common/auth/domain/params/new_user.dart';
import 'package:doctor_booking_flutter/app/common/auth/domain/params/user_credentials.dart';
import 'package:doctor_booking_flutter/app/common/auth/providers.dart';
import 'package:doctor_booking_flutter/app/patient/auth/data/models/patient.dart';
import 'package:doctor_booking_flutter/core/di/di_providers.dart';
import 'package:doctor_booking_flutter/core/service_exceptions/service_exception.dart';
import 'package:doctor_booking_flutter/core/validators/text_field_validators.dart';
import 'package:doctor_booking_flutter/lib.dart';
import 'package:doctor_booking_flutter/src/constants/constants.dart';
import 'package:doctor_booking_flutter/src/extensions/context.dart';
import 'package:doctor_booking_flutter/src/router/navigator.dart';
import 'package:doctor_booking_flutter/src/widgets/alert_dialog.dart';
import 'package:doctor_booking_flutter/src/widgets/loader/loader.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_animate/flutter_animate.dart';

@RoutePage(name: 'patientLogin')
class PatientLoginScreen extends HookConsumerWidget {
  const PatientLoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //text controllers
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final forgotPasswordEmailController = useTextEditingController();
    //remember me checkbox
    final rememberMe = useState(false);

    // auth provider
    final auth = ref.read(authRepoProvider);
    //formKey
    final GlobalKey<FormState> formKey = GlobalKey();

    return Scaffold(
      appBar: AppBar(),
      body: Form(
        key: formKey,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          children: [
            KText(
              'Welcome!',
              fontSize: 20.sp,
              fontWeight: FontWeight.w500,
              color: context.primary,
            ).animate(onPlay: (controller) => controller.repeat()).shimmer(
                duration: const Duration(seconds: 2), color: context.onPrimary),
            KText(
              'Glad to see you again! 👋',
              fontSize: 16.sp,
            ),
            SizedBox(
              height: 56.h,
            ),

            ///Textfield for email address
            DefaultTextFormField(
                label: 'Email address',
                hint: 'user@example.com',
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Email address is required';
                  } else if (value.isNotEmpty &&
                      !TextFieldValidator.emailExp.hasMatch(value)) {
                    return 'Email address not valid';
                  }
                  return null;
                }),

            ///Textfield for password
            Padding(
              padding: EdgeInsets.only(top: 16.h),
              child: PasswordTextField(
                label: 'Password',
                controller: passwordController,
                emptyTextError: 'Password is required',
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 25,
                      width: 25,
                      child: Checkbox(
                          value: rememberMe.value,
                          onChanged: (value) {
                            rememberMe.value = value!;
                          }),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 8.w),
                      child: const KText('Remember Me'),
                    )
                  ],
                ),

                ///FORGOT PASSWORD
                InkWell(
                  onTap: () async {
                    ///Open BOTTOM SHEET and CONTACT FIREBASE HERE
                    showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return Padding(
                          padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom),
                          child: SingleChildScrollView(
                            child: SizedBox(
                              height: 450.h,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16.w, vertical: 24.h),
                                child: Column(
                                  children: [
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: IconButton(
                                        onPressed: () => Navigator.pop(context),
                                        icon: const Icon(
                                          Icons.cancel,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 16.h,
                                    ),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: KText(
                                        'Enter your email address here to reset password',
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 24.h,
                                      ),
                                      child: DefaultTextFormField(
                                        label: 'Email address',
                                        hint: 'user@example.com',
                                        controller:
                                            forgotPasswordEmailController,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                      ),
                                    ),
                                    SizedBox(
                                      width: double.maxFinite,
                                      child: FilledButton(
                                        onPressed: () async {
                                          //get email in plain text
                                          String email =
                                              forgotPasswordEmailController.text
                                                  .trim();
                                          //check if email is valid, then send 'forget password' request to server
                                          if (TextFieldValidator.emailExp
                                              .hasMatch(email)) {
                                            Loader.show(context);

                                            final result = await auth
                                                .forgotPassword(email);
                                            result.when(success: (_) {
                                              Loader.hide(context);
                                              AutoRouter.of(context)
                                                  .popUntilRoot();
                                            }, apiFailure: (e, _) {
                                              Loader.hide(context);
                                              AppNavigator.of(context).pop();
                                              showMessageAlertDialog(context,
                                                  text: e.message);
                                            });
                                          } else {
                                            //if email is no valid, prompt user to input valid mail
                                            showMessageAlertDialog(context,
                                                text:
                                                    'Provide a valid email address to continue to password reset');
                                          }
                                        },
                                        child: const Text(
                                          'Reset password',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: const KText(
                    'Forgot Password?',
                    fontWeight: FontWeight.w500,
                  ),
                )
              ],
            ),

            ///LOGIN BUTTON
            Padding(
              padding: EdgeInsets.symmetric(vertical: 32.h),
              child: FilledButton(
                  onPressed: () async {
                    //if form is valid, try to login
                    if (formKey.currentState!.validate()) {
                      Loader.show(context);
                      UserCred user = UserCred(
                          email: emailController.text.trim(),
                          password: passwordController.text);
                      final result = await auth.patientLogin(user);
                      Loader.hide(context);
                      result.when(success: (data) {
                        ref.read(storeProvider).savePatientInfo(Patient(
                            fullName: data.user?.displayName ?? '',
                            emailAddress: emailController.text,
                            userId: data.user!.uid));
                        AppNavigator.of(context)
                            .replaceAll([const PatientHome()]);
                        //if the login was successful, navigate to home screen
                      }, apiFailure: (e, _) {
                        showMessageAlertDialog(context, text: e.message);
                      });
                    }
                  },
                  child: const KText('Login')),
            ),

            const Row(
              children: [
                Expanded(child: Divider()),
                KText('  Or Login with  '),
                Expanded(child: Divider())
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: OutlinedButton(
                  onPressed: () async {
                    Loader.show(context);
                    final result = await auth.googleSignIn();
                    Loader.hide(context);
                    result.when(success: (data) async {
                      //check if user exist in db, if not, save user details to db
                      final firebaseApi = ref.read(firebaseApiProvider);
                      bool exists =
                          await firebaseApi.getPatient(data.user?.email ?? '');
                      if (!exists) {
                        final user = NewUser(
                            fullName: data.user?.displayName ?? '',
                            emailAddress: data.user?.email ?? '',
                            password: '',
                            userId: data.user?.uid ?? '');
                        await firebaseApi.storePatientData(
                            newUser: user, credential: data);
                      }
                      //save user details here and navigator to the next screen
                      ref.read(storeProvider).savePatientInfo(Patient(
                          fullName: data.user?.displayName ?? '',
                          emailAddress: emailController.text,
                          userId: data.user!.uid));
                      AppNavigator.of(context)
                          .replaceAll([const PatientHome()]);
                    }, apiFailure: (e, _) {
                      showMessageAlertDialog(context, text: e.message);
                    });
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: SvgPicture.asset(AppAssets.googleIcon),
                      ),
                      const KText('Login with Google'),
                    ],
                  )),
            ),
            GestureDetector(
              onTap: () {},
              /* => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SignUpScreen())),*/
              child: Text.rich(
                TextSpan(children: [
                  const TextSpan(text: 'Don\'t have an account?  '),
                  TextSpan(
                      text: 'Signup',
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          context.pushRoute(const PatientSignUp());
                        },
                      style: AppStyle.textStyle
                          .copyWith(fontWeight: FontWeight.w500))
                ]),
                textAlign: TextAlign.center,
                style: AppStyle.textStyle.copyWith(fontSize: 16.sp),
              ),
            )
          ],
        ),
      ),
    );
  }
}
