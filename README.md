# PresentationComponent hand-proximity reproduction

Disposable visionOS 26 prototype for testing a `PresentationComponent` near the lower-back region of an otherwise empty volumetric window.

Open `PresentationComponentRepro.xcodeproj`, select a connected Apple Vision Pro, and run. The menu opens automatically. If visionOS dismisses it, tap the blue cube to reopen it.

Test from behind the volume:

1. Lower the right hand and confirm that **Test Action** receives gaze highlight and fires.
2. Raise the right hand near the lower-right/floor region without touching the menu.
3. Record whether gaze highlight disappears or the menu dismisses.

Relevant console lines begin with `[Repro]`.

## Demo video

[▶ Watch the repro video](PresentationComponentRepro_00-28_to_01-44.mp4)
