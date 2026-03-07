# Traffic App - AI Coding Agent Instructions

## Architecture Overview

This is a **Flutter traffic information app** using **GetX pattern** with feature-first architecture. Each feature module follows the structure: `bindings/`, `controllers/`, `views/`.

**Key architectural decisions:**

- **State Management**: GetX with dependency injection via Bindings
- **Navigation**: Centralized in [routes/app_pages.dart](../lib/routes/app_pages.dart) using GetX routing
- **Data Layer**: Repository pattern with clean separation (`data/models/`, `data/repositories/`, `data/services/`)
- **API**: Singleton `ApiService` ([data/services/api_service.dart](../lib/data/services/api_service.dart)) with automatic token refresh on 401 errors
- **Services**: Global GetX services initialized in [main.dart](../lib/main.dart): `StorageService`, `AssetsService`, `LocalizationService`

## Critical Workflows

### Running the App

```bash
# Setup environment first (required)
cp .env.example .env
# Edit .env with your BASE_URL and GOOGLE_MAPS_API_KEY

flutter pub get
flutter run
```

### Auto-Login Flow

Main entry point ([main.dart](../lib/main.dart)) checks stored credentials and attempts auto-login before app start. On success, navigates to `HOME`; on failure, goes to `LOGIN`.

### API Token Management

`ApiService` interceptor automatically:

1. Injects Bearer token from `StorageService` on every request
2. On 401 response, attempts re-login with stored credentials
3. Retries original request with new token or redirects to login

## Module Creation Pattern

When creating a new feature module (e.g., `settings`):

1. **Directory structure:**

   ```
   lib/modules/settings/
   ├── bindings/settings_binding.dart
   ├── controllers/settings_controller.dart
   └── views/settings_view.dart
   ```

2. **Binding** ([example](../lib/modules/home/bindings/home_binding.dart)):

   ```dart
   class SettingsBinding extends Bindings {
     @override
     void dependencies() {
       Get.lazyPut<SettingsController>(() => SettingsController());
     }
   }
   ```

3. **Controller** ([example](../lib/modules/home/controllers/home_controller.dart)):

   ```dart
   class SettingsController extends GetxController {
     var state = initialValue.obs; // Reactive state with .obs
   }
   ```

4. **View** - Use `GetView<Controller>` ([example](../lib/modules/home/views/home_view.dart)):

   ```dart
   class SettingsView extends GetView<SettingsController> {
     const SettingsView({super.key});
     @override
     Widget build(BuildContext context) {
       return Obx(() => /* access controller.state */);
     }
   }
   ```

5. **Register route** in [routes/app_pages.dart](../lib/routes/app_pages.dart):
   ```dart
   GetPage(
     name: _Paths.SETTINGS,
     page: () => const SettingsView(),
     binding: SettingsBinding(),
   )
   ```

## Styling & Responsive Design

**CRITICAL**: Always use `flutter_screenutil` extensions for responsive sizing:

- Width: `.w` (e.g., `100.w`)
- Height: `.h` (e.g., `50.h`)
- Border radius: `.r` (e.g., `16.r`)
- Font size: `.sp` (e.g., `14.sp`)

**Example** ([widgets/primary_button.dart](../lib/widgets/primary_button.dart)):

```dart
Container(
  width: 100.w,
  height: 50.h,
  decoration: BoxDecoration(borderRadius: BorderRadius.circular(16.r)),
  child: Text('Hello', style: TextStyle(fontSize: 14.sp)),
)
```

**Design tokens** are static constants in [theme/app_theme.dart](../lib/theme/app_theme.dart):

- Colors: `AppTheme.primaryColor`, `AppTheme.backgroundColor`, etc.
- Typography: Uses Google Fonts (Quicksand) via `GoogleFonts.quicksandTextTheme()`

**Never hardcode pixel values** - always use `.w`, `.h`, `.r`, `.sp` extensions.

## Data Layer Patterns

### Repository Pattern

Repositories handle API calls and error transformation ([example](../lib/data/repositories/auth_repository.dart)):

```dart
class FeatureRepository {
  final ApiService _apiService = ApiService();

  Future<Model> fetchData() async {
    try {
      final response = await _apiService.dio.get('/endpoint');
      return Model.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Default error message';
    }
  }
}
```

### Models

Models use `toJson()` and `fromJson()` ([example](../lib/data/models/login_request.dart)):

```dart
class Model {
  final String field;
  Model({required this.field});

  Map<String, dynamic> toJson() => {'field': field};
  factory Model.fromJson(Map<String, dynamic> json) => Model(field: json['field']);
}
```

## Widget Library (UI-Kit)

**CRITICAL**: When building any new view, you **MUST** use the components from `lib/widgets/` instead of raw Flutter widgets. Never use raw `ElevatedButton`, `TextButton`, `TextField`, `SnackBar`, `AlertDialog`, etc. when a UI-kit equivalent exists.

All widgets are in [lib/widgets/](../lib/widgets/). Import them from their respective files.

### `AppButton` ([widgets/app_button.dart](../lib/widgets/app_button.dart))

General-purpose button supporting primary/secondary styles, icon, and loading state.

```dart
AppButton(
  text: 'button_label'.tr,
  onPressed: controller.doSomething,
  type: ButtonType.primary,   // or ButtonType.secondary
  isLoading: controller.isLoading.value,
  icon: Icons.save,           // optional
  width: double.infinity,     // optional
)
```

### `PrimaryButton` ([widgets/primary_button.dart](../lib/widgets/primary_button.dart))

Simpler primary-only action button with loading state.

```dart
PrimaryButton(
  text: 'save'.tr,
  onPressed: controller.save,
  isLoading: controller.isLoading.value,
  width: double.infinity,
)
```

### `CustomTextField` ([widgets/custom_text_field.dart](../lib/widgets/custom_text_field.dart))

Styled text input with built-in password toggle and optional prefix icon.

```dart
CustomTextField(
  hintText: 'email_hint'.tr,
  prefixIcon: Icons.email_outlined,
  controller: controller.emailController,
  keyboardType: TextInputType.emailAddress,
  textInputAction: TextInputAction.next,
  isPassword: false,
  maxLines: 1,
)
```

### `CustomDropdown<T>` ([widgets/custom_dropdown.dart](../lib/widgets/custom_dropdown.dart))

Searchable/filterable dropdown with type safety.

```dart
CustomDropdown<Province>(
  hintText: 'select_province'.tr,
  prefixIcon: Icons.location_on_outlined,
  items: controller.provinces,
  itemLabel: (p) => p.name,
  value: controller.selectedProvince.value,
  onChanged: (v) => controller.selectedProvince.value = v,
)
```

### `CustomAlert` ([widgets/custom_alert.dart](../lib/widgets/custom_alert.dart))

Snackbar-style alert. Use instead of `Get.snackbar()` or `ScaffoldMessenger`.

```dart
// Types: AlertType.success | .error | .warning | .info
CustomAlert.show(message: 'save_success'.tr, type: AlertType.success);
CustomAlert.show(message: 'network_error'.tr, type: AlertType.error);
```

### `CustomDialog` ([widgets/custom_dialog.dart](../lib/widgets/custom_dialog.dart))

Modal dialog. Use instead of `showDialog` with raw `AlertDialog`.

```dart
// Info / confirmation dialog
CustomDialog.show(
  title: 'confirm_title'.tr,
  message: 'confirm_message'.tr,
  type: DialogType.warning,   // .success | .error | .warning | .info
  buttonText: 'confirm'.tr,
  onPressed: controller.confirm,
  cancelText: 'cancel'.tr,    // omit for single-button dialogs
  onCancel: Get.back,
);
```

### `LoadingWidget` ([widgets/loading_widget.dart](../lib/widgets/loading_widget.dart))

Lottie-based loading indicator from preloaded `AssetsService`.

```dart
// Inline loading indicator
LoadingWidget(height: 48.h)

// Full-screen centered loading
Center(child: LoadingWidget())
```

### `SocialButton` ([widgets/social_button.dart](../lib/widgets/social_button.dart))

OAuth/social login button accepting an icon or SVG asset path.

```dart
SocialButton(
  iconAssetPath: 'assets/icons/google.svg',
  onPressed: controller.loginWithGoogle,
)
```

### `LocationPermissionBanner` ([widgets/location_permission_banner.dart](../lib/widgets/location_permission_banner.dart))

Banner displayed when location permission is denied or service is disabled.

```dart
LocationPermissionBanner(
  isServiceDisabled: controller.isLocationServiceDisabled.value,
  onAction: controller.openLocationSettings,
  onDismiss: controller.dismissBanner,
)
```

### `UploadProgressOverlay` ([widgets/upload_progress_overlay.dart](../lib/widgets/upload_progress_overlay.dart))

Overlay widget showing file upload progress with optional cancel.

```dart
UploadProgressOverlay(
  progress: controller.uploadProgress.value,  // 0.0 – 1.0
  label: 'uploading_post'.tr,
  onCancel: controller.cancelUpload,
)
```

---

**Rules:**

1. **Always check `lib/widgets/` first** before writing any button, text field, dialog, alert, or loading UI.
2. **Never use raw Flutter equivalents** (`ElevatedButton`, `TextField`, `AlertDialog`, `SnackBar`) when a UI-kit widget covers the use case.
3. **Do not create one-off custom widgets** for things the UI-kit already handles — extend or reuse existing widgets instead.

## Localization

Uses GetX translations - keys stored in `assets/json/locales/` (`vi_VN.json` and `en_US.json`). Access via:

```dart
'key_name'.tr                          // Simple string
'key_with_param'.trParams({'x': val})  // Interpolation: use @x in locale value
```

**CRITICAL RULES — must be followed for every text string:**

1. **Never hardcode any user-visible text** — all strings (labels, hints, dialog titles/messages, button text, snackbar messages, error messages) MUST use `.tr`.
2. **Add the key to both locale files** (`vi_VN.json` AND `en_US.json`) before using it in code.
3. **Naming convention** — keys use `snake_case` prefixed by feature (e.g., `chatbot_title`, `profile_update_success`).
4. **Dynamic values** — use `.trParams({'param': value})` in code and `@param` placeholder in the locale JSON value.

```dart
// ✅ Correct
Text('chatbot_title'.tr)
Get.snackbar('notice_title'.tr, 'profile_update_success'.tr)
CustomDialog.showConfirm(title: 'chatbot_open_link_title'.tr, message: 'chatbot_open_link_message'.trParams({'href': url}))

// ❌ Wrong — never do this
Text('Trợ lý Giao thông AI')
Get.snackbar('Thông báo', 'Cập nhật thành công')
```

Service initialized in [main.dart](../lib/main.dart) before app start.

## Icon & Asset Usage

**SVG Icons**: Stored in `assets/icons/`, named in snake_case (e.g., `home_bottom_navbar.svg`)

```dart
SvgPicture.asset('assets/icons/notification.svg')
```

**Lottie Animations**: Preloaded in [services/assets_service.dart](../lib/services/assets_service.dart):

```dart
AssetsService.to.loadingComposition.value // Access preloaded animations
```

## Common Pitfalls

1. **Don't hardcode sizes** - Always use `.w/.h/.r/.sp` extensions for responsiveness
2. **Don't create controllers manually** - Use Bindings and `Get.lazyPut()` or `Get.put()`
3. **Don't forget Obx()** - Wrap widgets accessing `.obs` variables in `Obx()`
4. **Don't bypass ApiService** - All API calls must go through `ApiService` for token management
5. **Check .env file** - App requires `.env` with `BASE_URL` and `GOOGLE_MAPS_API_KEY`

## Testing

Currently minimal test coverage. When adding tests:

- Widget tests in `test/`
- Use `flutter test` to run
- Mock `ApiService` and GetX controllers for unit tests

---

**Design System Details**: See [Agents.md](../Agents.md) for comprehensive token definitions, component library, and project structure.
