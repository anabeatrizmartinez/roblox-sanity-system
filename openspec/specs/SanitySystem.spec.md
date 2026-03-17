# Specification: Darkness Sanity System

## 1. Context
- **Environment:** Roblox Studio.
- **Requirement:** The player loses "Sanity" when in darkness and recovers it near light.

## 2. Technical Data
- **Attribute:** A Number attribute named "Sanity" stored in the Player object.
- **Max Value:** 100.
- **Min Value:** 0.

## 3. World Objects
- **LightSources:** A Folder in `Workspace` containing Parts or Models with light.
- **Detection Range:** 15 studs.
- **VFX:** A `BlurEffect` in `Lighting` named "SanityBlur".
- **UI:** A `ScreenGui` in `StarterGui` named "SanityGui".

## 4. Logic Rules
- **Drain:** If distance to the nearest object in 'LightSources' is > 15 studs, decrease Sanity by 5 per second.
- **Recovery:** If distance is < 15 studs, increase Sanity by 10 per second until it reaches 100 (gradual recovery).

## 5. Visual Feedback
- **Blur Effect:** SanityBlur.Size = (100 - Sanity) / 5;
- **Camera Distortion:** Camera.FieldOfView = 70 + (100 - Sanity) / 4;
- **Screen Shake:** If Sanity < 30, apply a slight random camera shake every 0.1s;

## 6. User Interface (HUD)
- **Sanity Bar:** In `SanityGui`: Background.ProgressBar`.
- **Animation:** Use `TweenService` to change the `Size` of `ProgressBar`. The X-Scale should match `Sanity/100`.