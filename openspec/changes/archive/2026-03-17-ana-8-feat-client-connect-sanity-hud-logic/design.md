## ANA-8 Sanity HUD design

### Responsibilities

- Observe the local player's `Sanity` attribute and convert it into a normalized progress value in \[0, 1].
- Locate and cache `SanityGui.Background.ProgressBar` inside the player's `PlayerGui`.
- Animate the progress bar's X-scale using `TweenService` when sanity changes.
- Recover gracefully when the GUI or character reloads (e.g., on respawn).

### Data flow

1. Server owns and updates `Player.Sanity` according to the shared `SanityConfig`.
2. Client-side visuals (sanity VFX and HUD) read `Player.Sanity` but never write to it.
3. `SanityHUD.client.luau`:
   - Reads `SanityConfig` from `ReplicatedStorage.Shared.SanityConfig`.
   - Treats any missing or invalid attribute value as `SanityMax`.
   - Maps the clamped value to a bar scale via `scale = sanity / SanityMax`.
   - Tweens the `Size` property of the `ProgressBar` frame (X scale only).

### GUI lookup and lifecycle

- Use `Players.LocalPlayer:WaitForChild("PlayerGui")`.
- Inside `PlayerGui`, use `WaitForChild("SanityGui")`.
- Within `SanityGui`, resolve `Background` then `ProgressBar` via `WaitForChild`.
- Re-resolve this chain whenever the `PlayerGui` reloads (e.g., character respawn or GUI reset).

### Attribute binding

- Listen to `LocalPlayer:GetAttributeChangedSignal(SanityAttributeName)`.
- On each change:
  - Read and clamp the sanity value using `SanityConfig` min/max.
  - Compute a safe scale in \[0, 1].
  - Tween from the current bar size to the new scale over a short duration.
- On startup:
  - Perform an initial update using the current attribute (or `SanityMax` if missing).

