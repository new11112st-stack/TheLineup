# التشكيلة — تطبيق Flutter لحجز مقاعد كرة القدم

تطبيق جوال مبني بـ Flutter يحوّل موقع "التشكيلة" إلى تطبيق Android أصلي، مع الحفاظ على نفس العمليات والألوان والوظائف، لكن بتجربة استخدام حديثة ومميزة.

## المميزات

### واجهة اللاعب
- **الرئيسية**: بطاقة المباراة مع العد التنازلي المباشر، حلقة المقاعد، نموذج الحجز الذكي
- **التشكيلة**: قائمة جميع اللاعبين مع أرقام قمصانهم وألوان حالاتهم
- **بطاقتي**: بطاقات الحجز الخاصة بك مع رفع إشعارات التحويل

### لوحة الأدمن
- **لوحة التحكم**: إحصائيات، إدارة الحجوزات (قبول/رفض/حذف)، الحجوزات السابقة
- **إضافة حجز**: نموذج إنشاء حجز جديد مع أرشفة الحالي
- **تسجيل الخروج**: إنهاء جلسة الأدمن بأمان

### التقنيات
- **Firebase Firestore**: مزامنة لحظية للبيانات (نفس مشروع Firebase للموقع)
- **Provider**: إدارة الحالة بشكل نظيف ومنظم
- **CustomPainter**: رسم القمصان والشعار والأيقونات يدوياً
- **دعم RTL**: واجهة عربية كاملة من اليمين لليسار
- **الخطوط**: Changa للعناوين و IBM Plex Sans Arabic للنصوص

## المتطلبات

- Flutter 3.13.0 أو أحدث
- Dart 3.0.0 أو أحدث
- Android Studio أو VS Code
- Java 17

## خطوات البناء

### 1. تثبيت Flutter

```bash
# تأكد من تثبيت Flutter
flutter --version

# إن لم يكن مثبتاً، اتبع التعليمات:
# https://docs.flutter.dev/get-started/install
```

### 2. نسخ المشروع

انسخ مجلد `takweela_app` إلى جهازك.

### 3. تثبيت الاعتماديات

```bash
cd takweela_app
flutter pub get
```

### 4. إعداد Firebase (مهم جداً)

التطبيق يستخدم نفس مشروع Firebase للموقع (`the-neup`). لكن ملف `google-services.json` الحالي نموذجي ويجب استبداله:

1. اذهب إلى [Firebase Console](https://console.firebase.google.com/)
2. اختر مشروع **the-neup**
3. من الإعدادات: ⚙️ → Project Settings → Your apps
4. أضف تطبيق Android جديد:
   - **Package name**: `com.takweela.app`
   - **App nickname**: التشكيلة (اختياري)
   - **SHA-1**: أضف SHA-1 الخاص بك (يُستخدم لتوقيع التطبيق)
5. حمّل ملف `google-services.json`
6. استبدل الملف الموجود في `android/app/google-services.json`

### 5. التحقق من إعدادات Firestore

في Firebase Console:
- Firestore → Rules: تأكد أن القواعد تسمح بالقراءة/الكتابة
- مثال للقواعد (للتطوير):

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;  // للإنتاج: استخدم قواعد أكثر صرامة
    }
  }
}
```

### 6. تشغيل التطبيق

```bash
# على محاكي أو جهاز متصل
flutter run

# للحصول على قائمة الأجهزة
flutter devices
```

### 7. بناء APK

```bash
# بناء APK للإصدار (release)
flutter build apk --release

# سيُنتج الملف في:
# build/app/outputs/flutter-apk/app-release.apk
```

### 8. بناء App Bundle (للنشر على Play Store)

```bash
flutter build appbundle --release

# سيُنتج الملف في:
# build/app/outputs/bundle/release/app-release.aab
```

## هيكل المشروع

```
takweela_app/
├── lib/
│   ├── main.dart                      # نقطة البداية
│   ├── models/                       # نماذج البيانات
│   │   ├── match.dart
│   │   ├── player.dart
│   │   └── app_config.dart
│   ├── services/                     # الخدمات
│   │   ├── firebase_service.dart     # عمليات Firestore
│   │   ├── storage_service.dart      # التخزين المحلي
│   │   └── image_service.dart        # ضغط الصور
│   ├── providers/
│   │   └── app_state.dart            # مزود الحالة الرئيسي
│   ├── utils/                        # الأدوات المساعدة
│   │   ├── constants.dart            # الألوان والثوابت
│   │   ├── theme.dart                 # ثيم Material 3
│   │   ├── arabic_helpers.dart        # الجمع والوقت بالعربية
│   │   └── validators.dart           # التحقق من المدخلات
│   ├── widgets/                      # الويدجتات القابلة لإعادة الاستخدام
│   │   ├── tshirt.dart                # رسم القميص
│   │   ├── match_card.dart            # بطاقة المباراة
│   │   ├── player_card.dart           # بطاقة اللاعب
│   │   ├── join_form.dart             # نموذج الحجز
│   │   ├── capacity_ring.dart         # حلقة المقاعد
│   │   ├── countdown_widget.dart      # العد التنازلي
│   │   ├── custom_app_bar.dart        # الشريط العلوي
│   │   ├── bottom_nav.dart            # التنقل السفلي
│   │   ├── app_button.dart            # الأزرار
│   │   └── status_badge.dart          # شارات الحالة
│   └── screens/                      # الشاشات
│       ├── root_screen.dart           # الشاشة الجذرية
│       ├── splash_screen.dart         # شاشة التحميل
│       ├── home_screen.dart           # الرئيسية (لاعب)
│       ├── squad_screen.dart          # التشكيلة (لاعب)
│       ├── my_cards_screen.dart       # بطاقتي (لاعب)
│       ├── admin_dashboard_screen.dart # لوحة التحكم (أدمن)
│       └── admin_new_match_screen.dart # إضافة حجز (أدمن)
├── android/                          # إعدادات Android
│   ├── app/
│   │   ├── build.gradle
│   │   ├── google-services.json       # إعداد Firebase (استبدله!)
│   │   └── src/main/
│   │       ├── AndroidManifest.xml
│   │       ├── kotlin/com/takweela/app/MainActivity.kt
│   │       └── res/                  # الموارد (أيقونات، ألوان، ثيمات)
│   ├── settings.gradle
│   ├── gradle.properties
│   └── gradle/wrapper/
├── pubspec.yaml                      # الاعتماديات
├── analysis_options.yaml
└── README.md
```

## الفروقات عن الموقع

| الميزة | الموقع | التطبيق |
|--------|--------|---------|
| التنقل | أزرار في الشريط العلوي | شريط تنقل سفلي بثلاث قوائم |
| الأدمن | زر "لوحة الأدمن" في الأعلى | شريط تنقل خاص بالأدمن (3 قوائم) |
| الشعار | SVG في الـ topbar | شعار مرسوم بـ CustomPainter |
| القميص | SVG string | CustomPainter للأداء الأفضل |
| التخزين | localStorage / sessionStorage | SharedPreferences |
| الصور | Canvas API | flutter_image_compress |
| الخطوط | Google Fonts (CDN) | google_fonts package |

## نفس المنطق البرمجي

- **نفس ألوان الحالة**: pending (أصفر فاتح)، review (كهرماني)، confirmed (أخضر)، rejected (أحمر)
- **نفس بنية Firestore**: config/app، matches/{id}/players، profiles/{code}
- **نفس منطق الرمز**: 4-8 أحرف إنجليزية/أرقام، بحث في الملفات المحفوظة
- **نفس منطق الأدمن**: كلمة مرور في config/app، جلسة في التخزين المحلي
- **نفس مراحل المباراة**: before / live / ended
- **نفس معالجة الأخطاء**: رسائل عربية واضحة لكل حالة

## استكشاف الأخطاء

### خطأ: Missing google-services.json
تأكد من تنزيل الملف من Firebase Console ووضعه في `android/app/`.

### خطأ: minSdkVersion
الحد الأدنى هو Android 6.0 (API 23). للتوافق مع إصدارات أقدم، عدّل `minSdk` في `android/app/build.gradle`.

### خطأ: لم تظهر البيانات
1. تأكد من اتصال الإنترنت
2. تحقق من قواعد Firestore
3. راجع سجل التطبيق: `flutter logs`

### خطأ: خط RTL غير صحيح
التطبيق مضبوط على RTL افتراضياً. للتأكد، افتح إعدادات الجهاز → Language → اختر العربية.

### خطأ: تعذّر بناء المشروع بعد flutter pub get
إذا واجهت أخطاء أثناء البناء، نفّذ الأوامر التالية:

```bash
# تنظيف ذاكرة Flutter
flutter clean

# تحديث الاعتماديات
flutter pub get

# بناء APK
flutter build apk --release
```

### خطأ: Plugin not found (image_picker)
أحياناً تتطلب إضافات الصور أذونات إضافية على Android. تأكد من أن `AndroidManifest.xml` يحتوي على:

```xml
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
```

### خطأ: FirebaseFirestoreException: permission-denied
تأكد من أن قواعد Firestore تسمح بالوصول. في Firebase Console:
1. Firestore Database → Rules
2. للتجربة، استخدم:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```
3. للإنتاج، استخدم قواعد أكثر صرامة حسب احتياجاتك.

## الترخيص

هذا التطبيق مبني لمشروع "التشكيلة" ويستخدم نفس قاعدة بيانات Firebase.

---

**ملاحظة**: قبل النشر على Play Store، أنشئ keystore خاص بك وحدّث `signingConfig` في `android/app/build.gradle`.
