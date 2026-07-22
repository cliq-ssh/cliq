import 'dart:convert';

import 'package:cliq/modules/settings/provider/sync.provider.dart';
import 'package:cliq/shared/data/store.dart';
import 'package:cliq/shared/ui/error_card.dart';
import 'package:cliq/shared/utils/input_formatters.dart';
import 'package:cliq/shared/utils/validators.dart';
import 'package:cliq_api/cliq_api.dart';
import 'package:cliq_ui/cliq_ui.dart' show CliqFontFamily;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../shared/utils/commons.dart';

enum _Step { hostUrl, login, register, registerVerify }

class RegisterOrLoginView extends HookConsumerWidget {
  const RegisterOrLoginView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final config = ref.watch(syncProvider).config;
    final step = useState<_Step>(.hostUrl);

    final hostCtrl = useTextEditingController(
      text: StoreKey.syncHost.readSync()?.hostUri.toString(),
    );
    final showHttpsWarning = useState<bool>(false);

    final usernameCtrl = useTextEditingController();
    final emailCtrl = useTextEditingController();
    final passwordCtrl = useTextEditingController();
    final passwordConfirmCtrl = useTextEditingController();

    final verificationCodeCtrl = useTextEditingController();

    final isFormValid = useState<bool>(false);
    final isLoading = useState<bool>(false);

    final routeOptions = useState<RouteOptions?>(null);

    useEffect(() {
      if (!isFormValid.value) return;
      final uri = Uri.tryParse(hostCtrl.text);
      if (uri == null) return;

      return null;
    }, [hostCtrl.text, isFormValid]);

    getBackButtonStep() {
      return switch (step.value) {
        .login => () => step.value = .hostUrl,
        .register => () => step.value = .hostUrl,
        _ => null,
      };
    }

    close() {
      passwordCtrl.clear();
      passwordConfirmCtrl.clear();

      Commons.showToast('sync_login_success'.tr());
      if (!context.mounted) return;
      context.pop();
    }

    Future<void> onTestHostUrl() async {
      // warn user if hostUrl starts with http://
      if (!showHttpsWarning.value && hostCtrl.text.startsWith('http://')) {
        showHttpsWarning.value = true;
        return;
      }

      final uri = Uri.tryParse(hostCtrl.text);
      if (uri == null) return;
      routeOptions.value = RouteOptions()..hostUri = uri;

      showHttpsWarning.value = false;
      isLoading.value = true;

      if (routeOptions.value == null) return;
      try {
        await ref
            .read(syncProvider.notifier)
            .retrieveConfig(routeOptions.value!);
        step.value = .login;
      } on CliqException catch (e) {
        Commons.showCliqException(e);
      } finally {
        isLoading.value = false;
        showHttpsWarning.value = false;
      }
    }

    Future<void> onLogin() async {
      isLoading.value = true;
      try {
        await ref
            .read(syncProvider.notifier)
            .login(
              routeOptions.value!,
              email: emailCtrl.text,
              password: utf8.encode(passwordCtrl.text),
            );
        close();
      } on CliqException catch (e) {
        // 2002 means the email is not verified yet, send to registerVerify step
        if (e.errorCode == 2002) {
          step.value = .registerVerify;
          return;
        }

        Commons.showCliqException(e);
      } finally {
        isLoading.value = false;
      }
    }

    Future<void> onRegister() async {
      isLoading.value = true;
      try {
        await ref
            .read(syncProvider.notifier)
            .register(
              routeOptions.value!,
              username: usernameCtrl.text,
              email: emailCtrl.text,
              password: utf8.encode(passwordCtrl.text),
            );

        // if email verification is not enabled, close the dialog and log in automatically
        if (config != null && !config.emailEnabled) {
          await ref
              .read(syncProvider.notifier)
              .login(
                routeOptions.value!,
                email: emailCtrl.text,
                password: utf8.encode(passwordCtrl.text),
              );

          close();
        } else {
          step.value = .registerVerify;
        }
      } on CliqException catch (e) {
        Commons.showCliqException(e);
      } finally {
        isLoading.value = false;
      }
    }

    Future<void> onRegisterVerify() async {
      isLoading.value = true;
      bool didVerify = false;
      try {
        await ref
            .read(syncProvider.notifier)
            .verifyRegistration(
              routeOptions.value!,
              verificationToken: verificationCodeCtrl.text,
              email: emailCtrl.text,
            );
        didVerify = true;
        await ref
            .read(syncProvider.notifier)
            .login(
              routeOptions.value!,
              email: emailCtrl.text,
              password: utf8.encode(passwordCtrl.text),
            );

        close();
      } on CliqException catch (e) {
        Commons.showCliqException(e);
        if (didVerify) step.value = .login;
      } finally {
        isLoading.value = false;
      }
    }

    Future<void> onResendVerification() async {
      isLoading.value = true;
      try {
        await ref
            .read(syncProvider.notifier)
            .resendVerificationEmail(
              routeOptions.value!,
              email: emailCtrl.text,
            );
      } on CliqException catch (e) {
        Commons.showCliqException(e);
      } finally {
        isLoading.value = false;
      }
    }

    buildHostUrlStep() {
      return [
        FTextFormField(
          key: ValueKey('host_url_field'),
          control: .managed(controller: hostCtrl),
          label: Text('sync_host_url'.tr()),
          description: Text('sync_host_url_subtitle'.tr()),
          hint: 'sync_host_url_placeholder'.tr(),
          autofillHints: [AutofillHints.url],
          autovalidateMode: .onUserInteraction,
          validator: (value) => Validators.syncServerUrl(context, value),
          readOnly: isLoading.value,
          enabled: !isLoading.value,
        ),
        if (showHttpsWarning.value)
          ErrorCard(text: 'sync_host_url_http_warning'.tr()),
        FButton(
          onPress: isFormValid.value && !isLoading.value ? onTestHostUrl : null,
          child: isLoading.value
              ? FCircularProgress()
              : Text(
                  showHttpsWarning.value
                      ? 'sync_test_host_url_anyway'.tr()
                      : 'sync_test_host_url'.tr(),
                ),
        ),
      ];
    }

    buildLoginStep() {
      final isLoginEnabled = config != null && config.localAuthProperties.login;
      final isRegisterEnabled =
          isLoginEnabled && config.localAuthProperties.registration;

      if (!isLoginEnabled) {
        return [
          Text(
            'sync_login_disabled'.tr(),
            textAlign: .center,
            style: context.theme.typography.body.md.copyWith(
              color: context.theme.colors.mutedForeground,
            ),
          ),
        ];
      }

      return [
        FTextFormField.email(
          key: ValueKey('email_field'),
          control: .managed(controller: emailCtrl),
          label: Text('email'.tr()),
          hint: 'email_placeholder'.tr(),
          autofillHints: [AutofillHints.email],
          validator: (value) => Validators.email(context, value),
          readOnly: isLoading.value,
          enabled: !isLoading.value,
        ),
        FTextFormField.password(
          key: ValueKey('password_field'),
          control: .managed(controller: passwordCtrl),
          label: Text('password'.tr()),
          autofillHints: [AutofillHints.password],
          readOnly: isLoading.value,
          enabled: !isLoading.value,
        ),
        Column(
          spacing: 8,
          children: [
            FButton(
              onPress: isFormValid.value && !isLoading.value ? onLogin : null,
              child: isLoading.value ? FCircularProgress() : Text('login'.tr()),
            ),
            if (isRegisterEnabled)
              FButton(
                variant: .outline,
                onPress: isLoading.value
                    ? null
                    : () {
                        step.value = .register;
                      },
                child: Text('sync_go_register'.tr()),
              ),
            Text(
              'sync_login_vault_hint'.tr(),
              textAlign: .center,
              style: context.theme.typography.body.xs.copyWith(
                color: context.theme.colors.mutedForeground,
              ),
            ),
          ],
        ),
      ];
    }

    buildRegisterStep() {
      return [
        FTextFormField(
          key: ValueKey('username_field'),
          control: .managed(controller: usernameCtrl),
          label: Text('username'.tr()),
          hint: 'username_placeholder'.tr(),
          autofillHints: [AutofillHints.newUsername],
          readOnly: isLoading.value,
          enabled: !isLoading.value,
        ),
        FTextFormField.email(
          key: ValueKey('email_field'),
          control: .managed(controller: emailCtrl),
          label: Text('email'.tr()),
          hint: 'email_placeholder'.tr(),
          autofillHints: [AutofillHints.email],
          validator: (value) => Validators.email(context, value),
          readOnly: isLoading.value,
          enabled: !isLoading.value,
        ),
        FTextFormField.password(
          key: ValueKey('password_field'),
          control: .managed(controller: passwordCtrl),
          label: Text('password'.tr()),
          autofillHints: [AutofillHints.newPassword],
          readOnly: isLoading.value,
          enabled: !isLoading.value,
        ),
        FTextFormField.password(
          key: ValueKey('password_confirm_field'),
          control: .managed(controller: passwordConfirmCtrl),
          label: Text('confirm_password'.tr()),
          autofillHints: [AutofillHints.newPassword],
          validator: (value) =>
              Validators.passwordConfirm(context, passwordCtrl.text, value),
          readOnly: isLoading.value,
          enabled: !isLoading.value,
        ),
        Column(
          spacing: 8,
          children: [
            FButton(
              onPress: isFormValid.value && !isLoading.value
                  ? onRegister
                  : null,
              child: isLoading.value
                  ? FCircularProgress()
                  : Text('register'.tr()),
            ),
            FButton(
              variant: .outline,
              onPress: isLoading.value
                  ? null
                  : () {
                      step.value = .login;
                    },
              child: Text('sync_go_login'.tr()),
            ),
          ],
        ),
      ];
    }

    buildRegisterVerifyStep() {
      return [
        FTextFormField(
          key: ValueKey('verification_code_field'),
          control: .managed(controller: verificationCodeCtrl),
          label: Text('verification_code'.tr()),
          description: Text('sync_verification_code_subtitle'.tr()),
          hint: 'sync_verification_code_placeholder'.tr(),
          autofillHints: [AutofillHints.oneTimeCode],
          autovalidateMode: .onUserInteraction,
          readOnly: isLoading.value,
          enabled: !isLoading.value,
          inputFormatters: InputFormatters.verificationToken(),
        ),
        Column(
          spacing: 8,
          children: [
            FButton(
              onPress: isFormValid.value && !isLoading.value
                  ? onRegisterVerify
                  : null,
              child: isLoading.value
                  ? FCircularProgress()
                  : Text('sync_verify_code'.tr()),
            ),
            FButton(
              variant: .outline,
              onPress: !isLoading.value ? onResendVerification : null,
              child: isLoading.value
                  ? FCircularProgress()
                  : Text('sync_resend_verify_code'.tr()),
            ),
          ],
        ),
      ];
    }

    return FScaffold(
      childPad: false,
      child: SingleChildScrollView(
        padding: const .symmetric(horizontal: 32, vertical: 20),
        child: Form(
          key: formKey,
          onChanged: () {
            final isValid = formKey.currentState?.validate() ?? false;
            isFormValid.value = isValid;
            if (!isValid) return;
            showHttpsWarning.value = false;
          },
          child: Column(
            spacing: 20,
            children: [
              Row(
                mainAxisAlignment: getBackButtonStep() != null
                    ? .spaceBetween
                    : .end,
                children: [
                  if (getBackButtonStep() != null)
                    FButton.icon(
                      variant: .outline,
                      onPress: getBackButtonStep(),
                      child: const Icon(LucideIcons.arrowLeft),
                    ),

                  FButton.icon(
                    variant: .outline,
                    onPress: () => context.pop(),
                    child: const Icon(LucideIcons.x),
                  ),
                ],
              ),
              Column(
                spacing: 16,
                children: switch (step.value) {
                  .hostUrl => buildHostUrlStep(),
                  .login => buildLoginStep(),
                  .register => buildRegisterStep(),
                  .registerVerify => buildRegisterVerifyStep(),
                },
              ),
              if (config != null)
                Text(
                  'backend:${config.serverVersion}',
                  style: context.theme.typography.body.xs.copyWith(
                    fontFamily: CliqFontFamily.secondary.fontFamily,
                    color: context.theme.colors.mutedForeground,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
