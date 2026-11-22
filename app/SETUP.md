# CampusMart Flutter app (built from the CampusMart Mobile Prototype)

Every screen follows `CampusMart-Mobile-Prototype/index.html`: same dark theme and orange colour, same
texts, same six bottom tabs (Home, Saved, Sell, Orders, Inbox, Account), same sign-in and create-account
pages. The demo data is replaced by your FastAPI backend.

```
lib/
  main.dart                    AuthGate: splash, sign-in, or the marketplace
  config.dart                  API address (--dart-define=API_BASE_URL=...)
  theme.dart                   prototype colours and input style
  models/                      user, category, item, order, conversation, message
  services/                    api_client (all HTTP) + auth, category, item, favorite, order, message, user services
  providers/                   auth_provider, nav_provider (go('home') of the prototype), catalog_provider (feed, search, saved ids)
  screens/                     splash, auth_screen (login_screen + register_screen), main_shell,
                               home, favourites (Saved), item_details, post_item (Sell, also edit),
                               orders, messages (Inbox + chat), profile (Account)
  widgets/                     header, bottom_nav, product_card, chips, buttons, inputs, panel, toast ...
  utils/                       validators (mirror the backend rules), format (UGX, initials)
test/validators_test.dart
```

## 1. Backend

Start the backend as before (the app uses its 9 categories, with the emoji stored in the database):

```powershell
cd backend
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

## 2. Put the app in the repo

Ask the Flutter lead first. If `app/` does not exist yet:

```powershell
cd "D:\mubiru work\Student-Market-Place"
flutter create --org ug.campusmart --project-name campusmart app
cd app
flutter pub add http provider flutter_secure_storage image_picker
```

Delete `app\test\widget_test.dart`, replace `app\lib` with this `lib` folder, and copy `test\validators_test.dart`
into `app\test`. If `app/` already exists, copy `lib/` and `test/` over his files and add the four packages.

## 3. Android settings (once)

In `app\android\app\src\main\AndroidManifest.xml`:

1. Above `<application` add `<uses-permission android:name="android.permission.INTERNET"/>`
2. In the `<application` tag add `android:usesCleartextTraffic="true"` (the dev backend is http, not https).

If the build mentions `minSdkVersion`, set `minSdk = 23` in `app\android\app\build.gradle.kts`.

## 4. Run on the phone

USB cable (easiest):

```powershell
& "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe" reverse tcp:8000 tcp:8000
cd app
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

Same Wi-Fi: `flutter run --dart-define=API_BASE_URL=http://<laptop IPv4>:8000` (see the earlier guide for the
firewall rule). Plain `flutter run` is only for the Android emulator.

When a request fails, the real reason is printed in the terminal ("API request to ... failed: ...").

## 5. What to test

1. Create an account (name, email, university, phone like 0771234567, password of 8+ characters).
2. Sell: publish an item with a photo. It appears on Home, in Orders under "My listings".
3. Sign out, create a second account, find the item, Save it (Saved tab), Message the seller, Request to buy.
4. Sign back in as the seller: Orders shows the request. Tap it, then Accept, then Mark as completed.
5. Stop the backend and pull down on Home: a clear error with Retry appears.

## What differs from the prototype, and why

Layout, colours, spacing and every screen are the same. These are the only differences:

- Registration also needs a phone number and an 8-character password, and Sell needs a category from the
  server (the backend requires them). Errors appear as the same small toast the prototype uses.
- Texts that said "demo" are reworded because they are no longer demos, for example
  "Your listing is published in this demo" is now "Your listing is published".
- The photo field uploads one real photo (the backend stores one photo per item).
- Orders: tap a row to manage it (cancel a request, accept, reject or complete a request you received,
  edit, mark sold or delete a listing). The prototype had no way to do this, and the project guidelines
  require editing and deleting.
- The category chips and the Sell category list come from the backend, so they show its 9 categories instead of the prototype's 6. Items show their category emoji when they have no photo (the prototype used a different emoji per item).
- Chat bubbles belong to whoever sent them (the prototype alternated them), and the open chat refreshes
  every 5 seconds.
- Material icons replace the text symbols in the bottom bar so they display the same on every phone.
