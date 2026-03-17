## ANA-8 implementation tasks – Sanity HUD

### 1. New client HUD script

- [x] Create `src/client/SanityHUD.client.luau`.
- [x] Require `SanityConfig` from `ReplicatedStorage.Shared.SanityConfig`.
- [x] Read sanity bounds and attribute name from `SanityConfig`.

### 2. Bind sanity to HUD

- [x] Locate `PlayerGui` using `LocalPlayer:WaitForChild("PlayerGui")`.
- [x] Inside `PlayerGui`, resolve `SanityGui.Background.ProgressBar` using `WaitForChild`.
- [x] Implement a helper to safely read and clamp the `Sanity` attribute, treating missing/invalid values as max sanity.
- [x] Implement an update function that:
  - Computes `scale = sanity / SanityMax`.
  - Clamps `scale` to the \[0, 1] range.
  - Tweens the X-scale of `ProgressBar.Size` to `UDim2.new(scale, 0, currentYScale, 0)`.

### 3. React to changes and respawns

- [x] Connect `LocalPlayer:GetAttributeChangedSignal(SanityAttributeName)` to update the bar.
- [x] Run an initial update on script start.
- [x] Listen for `PlayerGui` resets (e.g., `ChildAdded` or `AncestryChanged` on `SanityGui`) and re-resolve the HUD references before applying updates.

