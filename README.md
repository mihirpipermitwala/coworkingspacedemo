## CoWorking Space App

Discover and book coworking spaces, view them on a map, manage your bookings, and receive push notifications.

### Features

- **Search & filter**: Search by name/city/location; filter by city, amenity, and max price
- **Spaces list & details**: Rich card list, detailed screen with images, amenities, hours
- **Interactive map**: Google Map with markers; shows current location (permission-based)
- **Bookings**: Create bookings with date/time selection, price calculation, upcoming/past tabs, cancel booking
- **Notifications**: Local and push notifications; mark-as-read and mark-all-read

## Setup

### Prerequisites

- Flutter SDK installed and configured
- Firebase project (for push notifications)
- Google Maps keys (Android and iOS)

### Install dependencies

```bash
flutter pub get
```

### Configure Google Maps

- **Android**: Set your key in `android/app/src/main/AndroidManifest.xml` under the `meta-data` tag with name `com.google.android.geo.API_KEY`.
- **iOS**: Add the following in `ios/Runner/AppDelegate.swift` inside `didFinishLaunchingWithOptions` after `GeneratedPluginRegistrant.register(...)`:

```swift
import GoogleMaps

GMSServices.provideAPIKey("YOUR_IOS_MAPS_API_KEY")
```

Add the `GoogleMaps` SDK to your iOS Podfile if prompted by `google_maps_flutter`.

### Configure Firebase (Push Notifications)

1. Create a Firebase project and add iOS and Android apps
2. Download and place files:
   - Android: `google-services.json` → `android/app/`
   - iOS: `GoogleService-Info.plist` → `ios/Runner/`
3. iOS capabilities in Xcode (Runner target → Signing & Capabilities):
   - Add **Push Notifications**
   - Add **Background Modes** → enable **Remote notifications**
4. APNs: Upload your APNs key in Firebase Console for iOS
5. The app initializes Firebase and notifications in `lib/main.dart` and `lib/services/notification_service.dart`

### Location Permissions

- **Android**: Uses `ACCESS_FINE_LOCATION`/`ACCESS_COARSE_LOCATION` in `AndroidManifest.xml`
- **iOS**: Adds `NSLocationWhenInUseUsageDescription` to `Info.plist`
  Runtime permission is handled in `lib/screens/map_screen.dart` using `geolocator`.

### Generate JSON code (if needed)

The project uses `json_serializable` for some models. If you add new models:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Running

```bash
flutter run
```

Select your target device. On first launch, the app prints the FCM token in logs.

## Architecture

### State management

- **Provider**: `SpaceProvider`, `BookingProvider`, `NotificationProvider`
  - UI uses `Consumer` to react to changes

### Data layer

- **Mock API** via `SharedPreferences`: `ApiService` persists spaces, bookings, notifications
- Models: `CoworkingSpace`, `Booking`, `NotificationModel`

### UI structure

- Screens: `HomeScreen`, `MapScreen`, `SpaceDetailScreen`, `BookingScreen`, `MyBookingsScreen`, `NotificationsScreen`
- Widgets: `SpaceCard`, `CustomSearchBar`, `FilterBottomSheet`

### Notifications

- Initialization and permission requests in `NotificationService.initialize()`
- Foreground messages show local notifications; taps are handled to navigate
- Background handler: `onBackgroundMessage` with a top-level entry-point function that initializes Firebase and delegates to `NotificationService`

## Time Spent

- Core UI (list/map/detail): ~10–12 hours
- Bookings flow (date/time, pricing, provider wiring): ~4 hours
- Notifications (local + FCM integration): ~3 hours
- Filters & search (city/amenity/price): ~2.5 hour
- Platform setup & polishing: ~1.5 hour

## Challenges Faced

- **FCM on iOS**: Ensuring APNs is correctly configured and foreground presentation works
- **Background messaging**: Implementing a proper background handler that initializes Firebase in a background isolate
- **Maps keys**: Coordinating API keys across Android manifest and iOS AppDelegate
- **Permissions UX**: Balancing runtime permission prompts and graceful fallbacks on the map

## Useful Commands

- Analyze and format

```bash
flutter analyze
flutter format .
```

- Run build runner (json)

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Tech Stack

- Flutter, Dart
- State: Provider
- Maps: `google_maps_flutter`
- Location: `geolocator`
- Storage: `shared_preferences`
- Images: `cached_network_image`
- Notifications: `firebase_messaging`, `flutter_local_notifications`
