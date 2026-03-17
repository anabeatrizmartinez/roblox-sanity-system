## Sanity System for Roblox

Roblox sanity management system that implements proximity-based sanity drain and recovery using player attributes, designed for darkness-based gameplay experiences.

### 🔑 Overview

The system tracks a numeric `Sanity` attribute on each `Player` and updates it based on the player’s distance to configured light sources in `Workspace`. When the player is in darkness (outside the detection radius), sanity drains over time; when close to light, sanity recovers up to a maximum cap. Client logic evaluates proximity to light sources and adjusts the attribute, while server logic guarantees that each player has a valid and initialized sanity value.

### ✨ Key Features

- **Proximity-based sanity drain**
  - Evaluates the distance between the player’s character and the nearest object in the `Workspace.LightSources` folder.
  - Applies sanity drain when no light is found or when the nearest light is beyond the configured detection range (15 studs).
  - Uses configurable per-second drain and recovery values to control game balancing.

- **Server-side attribute management**
  - Stores sanity as a `Number` attribute named `Sanity` directly on the `Player` instance.
  - Initializes sanity for all existing players and any new players that join after the system starts.
  - Clamps sanity between 0 and 100 on the client when applying changes, ensuring consistent bounds.

- **Visual feedback**
  - **Blur & camera effects:** Adjust `Lighting.SanityBlur.Size` and `Camera.FieldOfView` as sanity decreases to increase visual tension.
  - **Screen shake:** Trigger mild camera shake when sanity falls below a critical threshold (e.g., sanity < 30).
  - **HUD sanity bar:** Drive a `SanityGui` with a progress bar whose X-scale matches `Sanity / 100` via `TweenService` for smooth transitions.

### 🧰 Tech Stack

- **Luau** – Core gameplay and sanity logic for client and server.
- **Rojo** – Project–to–place synchronization and filesystem-based Roblox project structure.
- **OpenSpec** – Specification-driven development for the sanity system behavior and UX.
- **Linear** – Issue and project management for tracking changes and tasks.
- **Cursor** – AI-assisted development.

### 📦 Installation & Setup

- **Prerequisites**
  - Roblox Studio installed and configured.
  - Rojo installed on your machine (CLI) to sync the filesystem project with Roblox Studio.

- **Basic setup with Rojo**
  - Clone or download this repository to your local machine.
  - Open Roblox Studio and create/open the target place where you want the sanity system to run.
  - Start a Rojo server from the project root (for example: `rojo serve` using your Rojo project configuration).
  - Connect Roblox Studio to the Rojo server to sync the `src` folder into your game.

- **In-game configuration**
  - In `Workspace`, create a `Folder` named `LightSources` and populate it with `Parts` or `Models` representing light-emitting objects.
  - Ensure `Lighting` contains a `BlurEffect` named `SanityBlur` and `StarterGui` contains a `ScreenGui` named `SanityGui` with a progress bar as described in the spec.

Once synced and configured, playtest the experience in Roblox Studio to validate sanity drain and recovery behavior around light sources.