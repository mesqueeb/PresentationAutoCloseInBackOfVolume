# visionOS PresentationComponent loses gaze targeting based on hand position in a volumetric window

On visionOS 26, SwiftUI buttons presented from RealityKit with `PresentationComponent` can stop receiving gaze targeting in a particular region of a volumetric window. Direct touch continues to work.

The attached minimal project contains only:

- One volumetric `WindowGroup`
- One thin `ModelEntity` with an `InputTargetComponent`
- One `PresentationComponent` containing ordinary SwiftUI buttons

## Steps to reproduce

1. Run the project on Apple Vision Pro.
2. View the volume from behind it.
3. Look at **Test Action** and confirm that it normally receives a gaze highlight.
4. Move the right hand near the lower region of the volume while continuing to look at the button.
5. Move the hand away and back again.

## Actual result

Depending on hand position, the button stops receiving a gaze highlight and gaze-and-pinch does not invoke its action. Directly touching the same button works. Moving the hand away can restore gaze targeting. Moving it back can also dismiss the presentation without invoking either button.

The console repeatedly reports:

```text
Trying to convert coordinates between views that are in different UIWindows, which isn't supported. Use convertPoint:fromCoordinateSpace: instead.
Instructed to remove hit test redirection, but it was already removed
```

When the presentation dismisses itself, its bound `isPresented` value changes to `false`, and the menu's `onDisappear` runs without a button action.

## Expected result

The presented buttons should continue receiving gaze targeting regardless of the user's hand position, and the presentation should not dismiss unless the user activates a control or intentionally dismisses it.

## Isolation performed

The behavior remains in this standalone project with no game content, ornaments, drag handles, baseplate, `BillboardComponent`, or additional input targets. Removing `preferredWindowClippingMargins` does not change it. Raising the presentation from `y = -0.44 m` to `y = -0.25 m` does not eliminate it. The behavior is more sensitive in the minimal project than in the production app.

The apparent general slowness seen during early testing was caused by Xcode's **Debug executable** option and is separate from this report.
