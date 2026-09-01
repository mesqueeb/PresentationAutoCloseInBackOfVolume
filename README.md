# Demo video

- hand prevents button gaze
- moving hand away restores button gaze
- moving hand back force closes the presentation

https://github.com/user-attachments/assets/481a0178-a4b4-4c91-badc-faaa11ad91d3



# PresentationComponent hand-proximity reproduction

Disposable visionOS 26 & 27 prototype for testing a `PresentationComponent` near the lower-back region of an otherwise empty volumetric window.

Open `PresentationComponentRepro.xcodeproj`, select a connected Apple Vision Pro, and run. The menu opens automatically. If visionOS dismisses it, tap the blue cube to reopen it.

Test from behind the volume:

1. Lower the right hand and confirm that **Test Action** receives gaze highlight and fires.
2. Raise the right hand near the lower-right/floor region without touching the menu.
3. Record whether gaze highlight disappears or the menu dismisses.

Relevant console lines begin with `[Repro]`.

