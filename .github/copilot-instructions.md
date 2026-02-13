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

## Widget Library

Reusable widgets in [lib/widgets/](../lib/widgets/):

- `PrimaryButton` - Standard action button with loading state
- `CustomTextField` - Styled text input
- `CustomDialog` - Modal dialogs
- `LoadingWidget` - Uses preloaded Lottie animations from `AssetsService`

**Always check existing widgets** before creating new ones.

## Localization

Uses GetX translations - keys stored in `assets/json/locales/`. Access via:

```dart
'key_name'.tr // In code
Text('welcome_message'.tr)
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
