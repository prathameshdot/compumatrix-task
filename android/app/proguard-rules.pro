# Firebase / Play Services use reflection to (de)serialize models.
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# flutter_local_notifications uses reflection for scheduled-notification receivers.
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# flutter_local_notifications caches scheduled notifications as JSON via Gson,
# reading them back with `new TypeToken<List<...>>(){}`. Gson resolves that
# generic type at runtime via TypeToken's own generic superclass, so if R8
# renames/merges TypeToken (even with Signature kept above), every call that
# touches the schedule cache — including cancel(), which runs on every
# mark-complete/mark-incomplete toggle — throws:
# "IllegalStateException: TypeToken must be created with a type argument".
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**

# Keep model classes that Firestore deserializes via reflection, if any are
# ever annotated for it (defensive — this app maps documents manually).
-keepattributes Signature
-keepattributes *Annotation*
