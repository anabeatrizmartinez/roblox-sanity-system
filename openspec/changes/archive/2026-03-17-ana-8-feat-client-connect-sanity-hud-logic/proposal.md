## ANA-8: feat(client): Connect Sanity HUD logic

### What

- Connect the existing `SanityGui` HUD to the player's replicated `Sanity` attribute.
- Drive the `SanityGui.Background.ProgressBar` X-scale by the normalized sanity value.
- Keep the HUD in sync across respawns and GUI reloads without ever writing sanity from the client.

### Why

- Players need clear, immediate feedback about their current sanity level to understand the impact of light and darkness.
- The core sanity simulation and visual post-processing are already implemented; the HUD is the last missing feedback channel.
- A responsive, tweened bar improves readability and perceived polish over hard size jumps.

### Scope

- **In scope**
  - New client script `SanityHUD.client.luau` under `src/client`.
  - Read-only binding between the `Sanity` attribute and the HUD progress bar.
  - Basic error handling for missing GUI or attribute, treating missing sanity as full (100).
- **Out of scope**
  - Any changes to server-side sanity logic or state management.
  - Additional HUD widgets beyond the existing progress bar.
  - Non-sanity-related UI or camera changes.

