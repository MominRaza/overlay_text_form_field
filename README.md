<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

A Flutter package to add Overlay Text Form Field.

## Features

Overlay Text Form Field with Mention and Tags

## Getting started

```
import 'package:overlay_text_form_field/overlay_text_form_field.dart';
```

## Usage

```dart
final controller = TextEditingController();

Widget overlayMentionBuilder(query, onOverlaySelect) {
return FirestoreListView(
    query:
        FirebaseFirestore.instance.collection('users').orderBy('userHandle'),
    loadingBuilder: (context) => const SizedBox(),
    itemBuilder: (context, snap) {
    final user = MyUser.fromJson(snap);
    return user.handle.toLowerCase().contains(query)
        ? ListTile(
            visualDensity: VisualDensity.compact,
            leading: MyUserAvatar(user.image),
            title: Text(user.name),
            subtitle: Text('@${user.handle}'),
            onTap: () => onOverlaySelect(user.handle),
            )
        : const SizedBox();
    },
);
}

Widget overlayTagBuilder(query, onOverlaySelect) {
return FirestoreListView(
    padding: EdgeInsets.zero,
    query: FirebaseFirestore.instance.collection('tags').orderBy('tag'),
    loadingBuilder: (context) => const SizedBox(),
    itemBuilder: (context, snap) {
    return snap.data()['tag'].toLowerCase().contains(query)
        ? ListTile(
            visualDensity: VisualDensity.compact,
            title: Text('#${snap.data()['tag']}'),
            onTap: () => onOverlaySelect(snap.data()['tag']),
            )
        : const SizedBox();
    },
);
}

OverlayTextFormField(
    controller: controller,
    overlayMentionBuilder: overlayMentionBuilder,
    overlayTagBuilder: overlayTagBuilder,
);
```

## Additional information

Raise a [PR](https://github.com/MominRaza/overlay_text_form_field/pulls) to
contribute to the package, Go to [Issues](https://github.com/MominRaza/overlay_text_form_field/issues) to file issues
