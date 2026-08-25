{
  "_comment": "ملف proguard — قواعد منع التحسين",
  "_comment_2": "للنسخة الحالية نتركه فارغاً — يمكن إضافة قواعد حسب الحاجة"
}

# Flutter
-keep class io.flutter.** { *; }
-dontwarn io.flutter.embedding.**

# Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Preserve Firestore
-keep class com.google.cloud.firestore.** { *; }
-keep class com.google.firebase.firestore.** { *; }
