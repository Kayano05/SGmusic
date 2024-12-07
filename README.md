# SGmusic

Bilibili music player for Android platform
Functions include

1 Use the BV number to download the audio to the local as the playback source

2 Automatically identify the cover

3 Create a custom playlist

4 kinds of theme switching

5 Batch import and download using FID

BugFix

1 Fixed theme being too dark

2 Fixed download progress bar not showing

3 Fixed the home page control component color being too close to the background

4 Fixed an issue where app ICONS are not displayed

5 Fixed an issue where custom playlists could not be deleted

6 Fixed an issue where auto playlists could not be deleted (including local)

The application supports the Apache 2.0 protocol, you can change the application and commercial activities.

If you have any questions, please give me feedback. May this friendship last forever!

## Getting Started

Download the Android package and open it directly

The local storage location of the audio is:

```dart
final directory = await getApplicationDocumentsDirectory();
final musicDir = Directory('${directory.path}/Music');
if (!await musicDir.exists()) {
  await musicDir.create();
}

final cleanTitle = title.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
final file = File('${musicDir.path}/$cleanTitle.mp3');
```
