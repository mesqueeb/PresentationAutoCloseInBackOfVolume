# PresentationComponent hand-proximity reproduction

Disposable visionOS 26 & 27 prototype for testing a `PresentationComponent` near the lower-back region of an otherwise empty volumetric window.

Open `PresentationComponentRepro.xcodeproj`, select a connected Apple Vision Pro, and run. The menu opens automatically. If visionOS dismisses it, tap the blue cube to reopen it.

Test from behind the volume:

1. Lower the right hand and confirm that **Test Action** receives gaze highlight and fires.
2. Raise the right hand near the lower-right/floor region without touching the menu.
3. Record whether gaze highlight disappears or the menu dismisses.

Relevant console lines begin with `[Repro]`.

## Demo video

Both videos show:
- hand prevents button gaze
- moving hand away restores button gaze
- moving hand back force closes the presentation

First video uses this prototype.

![](https://github.com/user-attachments/assets/759d3767-e8ab-40fc-a639-3a67f7968f7f)

Second video uses custom app code based on the same concepts, the issue is more clearly visible.

![](https://github.com/user-attachments/assets/4c98640b-e90c-4774-b576-11727efcfa6e)
